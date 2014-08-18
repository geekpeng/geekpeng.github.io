##Http Protocol Parameters##
###Http Version:###
first line of the message HTTP-Version = "HTTP" "/" 1*DIGIT "." 1*DIGIT  

###Uniform Resource Identifiers###
URI  
PS.URI,URL,URN
###Date/Time Formats###
###Character Sets###
###Content Codings###

##HTTP Message##

###Message Types###
HTTP-message = Request|Response;HTTP/1.1 messages
是一个 request message 还是 response message,每一个message都包含了 start-line,可选的header fields,和一个CRLF(回车换行)的来分开headers跟可能会有的message body  
generic-message = start-line					(start-line 起始行,Request-Line(request message)/Status-Line(response message))
					*(message-header CRLF)		(message header fields 是可选的使用CRLF分开)
					CRLF						(CRLF 分开message-header 跟 message-body)
					[message-body]				(message-body)
					
###Message Headers###
header fields 包含 general-header, request-header, reponse-header, entity-header fields.
每一个 header field 都是由 header name : header value 组成. header name 大小写不敏感
>LWS(Line White Space): HTTP/1.1的header field的值可以是可折叠的形式,只要下一行是以空格(SP)或者制表符(HT)开头.所有的LWS包括SP和HT都跟SP有相同的语义
message-header = field-name ":" [field-value]	
field-name = token								(field-name 标识)
field-value = *(field-content | LWS)			(field-value 可以是多个,每个field-value 的内容也可以使用LWS多行折叠)
field-content = <任意的八进制的字符跟标识组成>

###Message Body###
如果Message Body 用于携带跟请求或者响应关联的Entity-body
>Message Body 跟 Entiry Body区别
message-body = entity-body | <entity-body encoded as per Transfer-Encoding> (通过 Transfer-Encoding 编辑的 entity-body)
Transfer-Encoding 是message的属性而不是实体
###Message Length###

###General Header Fields###
一些header fields 可以在request跟 response 中通用,这些header field只能用于传送消息而不能用于传送实体

##Request##
request 从客户端到服务器端.包括 start-line,请求资源的方法,资源的标识,使用协议的版本
Request = Request-Line
			*((general-header|reponse-header|entity-header) CRLF)
			CRLF
			[message-body]
###Request-Line###
Request-Line = Method SP URI SP HTTP-Version CRLF 
Request-line 是以一个 方法标识开头,后面是一个Request-URl跟协议版本以一个 CRLF 结束,它们之前是以 SP(空格) 分隔
在最后结束的 CRLF 之前不能有 CR 或者 LF
###Method###
执行资源请求的方法
 Method = "OPTIONS"                
		  | "GET"                  
		  | "HEAD"                 
		  | "POST"                 
		  | "PUT"                  
		  | "DELETE"               
		  | "TRACE"                
		  | "CONNECT"             
		  | extension-method
       extension-method = token
	
