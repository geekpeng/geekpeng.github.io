---
layout: post
title:  "文件下载当前页面提示错误信息"
category: java
tags: [java, file download, jquery]
keywords: java,filedownload,file download,文件下载,ajax download,无跳转提示
description: 文件下载页面无跳转提示错误信息,使用iframe模拟ajax实现文件下载出错无跳转提示。
---

最近在做文件下载的时候,需求需要下载出错或者文件不存在时提示信息需要在当前页面显示。  

因为项目中使用了struts2,在action中直接返回的是 Inputstream, 如果文件不存在跳转到一个页面。  

	<action name="fileDownload" class="fileDownloadAction" method="fileDownload">
		<result name="fileNotFound">/filenotfound.jsp</result>
		<result type="stream" name="success">  
			<param name="contentType">application/octet-stream</param>  
			<param name="inputName">inputStream</param>  
			<param name="contentDisposition">attachment;filename="${fileName}"</param>  
			<param name="bufferSize">4096</param>
		</result>  
	</action>


	public class FileDownloadAction  extends BaseController{
		
		private static final long serialVersionUID = 1L;
		private String fileName;
		private String filePath;
		private InputStream inputStream;

		public String fileDownload() {
			
			InputStream inputStream = ServletActionContext.getServletContext().getResourceAsStream(filePath);
			
			if (inputStream == null) {
				request.setAttribute("fileName", fileName);
				request.setAttribute("errorInfo", "文件不存在");
				return "fileNotFound";
			} else {
				setInputStream(inputStream);
				return SUCCESS;
			}
		}
		
		public String getFileName() {
			return fileName;
		}
		
		public String getFilePath() {
			return filePath;
		}

		public void setFilePath(String filePath) {
			this.filePath = filePath;
		}

		public InputStream getInputStream() {
			return inputStream;
		}

		public void setInputStream(InputStream inputStream) {
			this.inputStream = inputStream;
		}
	}

在页面直接让下载链接放在\<a href="download......."\>下载\</a\>中,下载文件不存在时页面会跳转。  

在网上有找一个方法但是觉得太复杂了,大概的方法是,在一个form里提交请求,在后台下载的时候如果文件不存在会写入一个cookie信息,然后用js在前台不段的获取cookie数据,再给出提示,再删除cookie信息。  
可以参考他的实现DEMO：[http://jqueryfiledownload.apphb.com/](http://jqueryfiledownload.apphb.com/)    
源代码：[http://github.com/johnculviner/jquery.fileDownload/blob/master/src/Scripts/jquery.fileDownload.js](http://github.com/johnculviner/jquery.fileDownload/blob/master/src/Scripts/jquery.fileDownload.js)  

之前在使用jquery.from文件上传的时候,发现在IE中实现的方式,其实是使用一个隐藏的iframe提示的。其实文件下载也可以使用这样的方式去实现。  

于是最先想的方法是。  
创建一个iframe,添加到body中,再创建一个表单将表单添加到iframe中,再在iframe中将表单提交到下载地址,然后将表单移除,
如果文件不存在,返回一段js的脚本,执行js脚本,弹出提示信息。  
这样做似乎太过于繁琐。  

后面发现可以给form添加一个target属性,指定到页面中的iframe,直接提交就可以了。  
不是 \<a\> 标签也有一个target属性吗？直接指定到iframe中会怎样？果然也可以。这样就太简单了。  

	(function($){  
		
		var iframe = $("<iframe src='about:blank'></iframe>");
		var hidden = $("<div style='display:none'></div>");
		iframe.appendTo(hidden);
		
		$.fn.mockAjaxDownload = function() {
			var iframe_name = "iframe_file_download_"+randomName();
			initIframe(iframe_name);
			$(this).attr("target",iframe_name);
		}; 
		function initIframe(iframe_name) {    
			iframe.attr("name", iframe_name);
			hidden.appendTo("body");
		}; 
		function randomName(){
			return Math.floor(Math.random()*999+1);
		};
		
	})(jQuery);

然后页面中下载链接：
\<a href="downloadurl" class="download"\>download\</a\>  
加入一段js

	<script>
		$(".downloadurl").mockAjaxDownload();
	</script>

这样就可以了。如果文件不存在返回的页面(使用了struts标签)：filenotfound.jsp  

	<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
	<%@ taglib prefix="s" uri="/struts-tags" %>

	<script type="text/javascript">
		try{
		   var fileName = ""+'<s:property value="#request.fileName"/>';
		   var errorInfo = ""+'<s:property value="#request.errorInfo"/>';
		   alert(fileName+":"+errorInfo);
		} catch(err){
			 alert("下载文件不存在");
		}
	</script>

这里只是简单弹出提示。  

这样做有一个问题就是,如果页面中的文件下载链接\<a\>是通过js动态添加进来的,显示这种方法是不能处理的,对于这种情况,我的做法是阻止\<a\>的click事件,然后获取到他的href,将这个href更新到iframe的src上。







