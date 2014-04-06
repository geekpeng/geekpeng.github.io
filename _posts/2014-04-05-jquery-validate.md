---
layout: post
title:  "jquery validate option 参数的使用"
category: java
tags: [js, jquery]
keywords: geek,geekeach,jquery validate, validate, 表单验证,js 验证,jquery validate验证,jquery 验证插件
description: jquery validate 一些参数的作用,及验证的一些示例
---
jquery .validate()方法的一些参数

<form id="form_1">
	<label>username:</label><input type="text" name="username" ><br/>
	<label>password:</label><input type="password" name="password"><br/>
	<label>email:</label><input type="text" name="email"><br/>
	<input type="submit" value="submit" >
	<input type="button" class="reset" value="reset"/>
</form>

普通的验证:

	var option = {
		debug:true,
		rules:{
			username:{required:true},
			password:{required:true},
			email:{required:true,email:true}
		},
		messages:{
			username:{required:'用户名不能为空'},
			password:{required:'密码不能为空'},
			email:{required:"邮箱不能为空",email:"邮箱格式不正确"}
		}
	}
	
options参数：  
**debug**:(类型:boolean,默认:false),如果为true,启用debug模式,表单不会提交,如果有错误会在控制台输出。  

	var option = {
		debug:true,
		rules:{
			username:{required:true},
			password:{required:true},
			email:{required:true,email:true}
		},
		messages:{
			username:{required:'用户名不能为空'},
			password:{required:'密码不能为空'},
			email:{required:"邮箱不能为空",email:"邮箱格式不正确"}
		}
	}

**submitHandler**:(类型:function,默认:表单正常的提交方法),表单验证通过后的一个回调方法,接收一个form(这个表单是一个DOM对象,不是jquery对象)的参数,可以通过这个回调方法来实现一个表单的ajax提交。或者表单提交之前的一些其他的操作。

	var option = {
		rules:{
			username:{required:true},
			password:{required:true},
			email:{required:true,email:true}
		},
		messages:{
			username:{required:'用户名不能为空'},
			password:{required:'密码不能为空'},
			email:{required:"邮箱不能为空",email:"邮箱格式不正确"}
		},
		submitHandler:function(form){
			//do something before submit
			alert("before submit");
			$(form).ajaxSubmit();
		}
	}

**invalidHandler**:(类型:function),表单提交验证不通过时的一个回调方法,接收两个参数,第一个参数event事件对象,第二个参数验证器。  
开打firefox的firebug 可以看到 event 跟 validator对象中的属性  
<form id="form_2">
	<label>username:</label><input type="text" name="username" ><br/>
	<label>password:</label><input type="password" name="password"><br/>
	<label>email:</label><input type="text" name="email"><br/>
	<input type="submit" value="submit" >
	<input type="button" class="reset" value="reset"/>
</form>

	var option1 = {
		rules:{
			username:{required:true},
			password:{required:true},
			email:{required:true,email:true}
		},
		messages:{
			username:{required:'用户名不能为空'},
			password:{required:'密码不能为空'},
			email:{required:"邮箱不能为空",email:"邮箱格式不正确"}
		},
		invalidHandler: function(event, validator) {
			console.log(event);
			console.log(validator);
			
			var errors = validator.numberOfInvalids();
			if (errors) {
				alert(errors + "fields invalid");
			} else{
				alert("valid")
			}
		}
	}

**ignore**:(默认:':hidden')验证的时候会被忽略的元素,默认隐藏的元素不会去验证。值得注意的是当你使用自己的忽略规则的时候,它会去验证hidden的元素。  
查看源代码中:  

	$(this.currentForm)
		.find("input, select, textarea")
		.not(":submit, :reset, :image, [disabled]")
		.not( this.settings.ignore ),

像下面的这个表单中有一个隐藏的 userId  
<form id="form_3">
	<input type="hidden" name="userId" value="">
	<label>username:</label><input type="text" name="username" class="ignore"><br/>
	<label>password:</label><input type="password" name="password"><br/>
	<label>email:</label><input type="text" name="email"><br/>
	<input type="submit" value="submit" >
	<input type="button" class="reset" value="reset"/>
</form>

	var option = {
		debug:true,
		ignore:".ignore",
		rules:{
			username:{required:true},
			password:{required:true},
			email:{required:true,email:true},
			userId:{required:true}
		},
		messages:{
			username:{required:'用户名不能为空'},
			password:{required:'密码不能为空'},
			email:{required:"邮箱不能为空",email:"邮箱格式不正确"},
			userId:{required:"用户id不能为空"}
		},
		invalidHandler: function(event, validator) {
			console.log(event);
			console.log(validator);
			
			var errors = validator.numberOfInvalids();
			if (errors) {
				alert(errors + "fields invalid");
			} else{
				alert("valid")
			}
		}
	}

**rules**:这个不用说了一些验证规则。还有一个地方需要的提到的是一个depends属性。只有满足每件的时候才会去验证。  

<form id="form_4">
	<label>choose</label><select id="choose_01" name="choose"><option value="true">validate</option><option value="false">no validate</option></select><br>
	<label>email:</label><input type="text" name="email"><br/>
	<input type="submit" value="submit" >
	<input type="button" class="reset" value="reset"/>
</form>

	var option4 = {
		debug:true,
		rules:{
			email:{
				required:true,
				email:{
					 depends: function(element) {
						console.log(element);
						return $("#choose").val() === "true" ? true : false;
					 }
				}
			},
		},
		messages:{
			email:{required:"邮箱不能为空",email:"邮箱格式不正确"},
		}
	}

**messages**:这个更加不用说了,验证的提示信息。同样需要提到的一点是,在提示信息中使用参数。  
<form id="form_5">
	<label>password:</label><input type="password" name="password"><br/>
	<input type="submit" value="submit" >
	<input type="button" class="reset" value="reset"/>
</form>

	var option5 = {
			debug:true,
			rules:{
				password:{
					required:true,
					rangelength:[6,16]
				}
			},
			messages:{
				password:{
					required:"不能为空",
					rangelength:jQuery.format("bettwen {0} and {1} characters")
				}
			}
		}

**onsubmit**:(类型:boolean,默认:true)表单提交的时候是否进行验证。如果是false表单也就不会验证。  

**onfocusout**:(类型:boolean 或者 function)在发生on blur事件的时候进行验证(checkboxes/radio除外)。
需要注意的是 onfocusout 要么是false,要么是一个function,并不能是一个true值。    
<form id="form_6">
	<label>username:</label><input type="text" name="username" ><br/>
	<label>password:</label><input type="password" name="password"><br/>
	<label>email:</label><input type="text" name="email"><br/>
	<input type="submit" value="submit" >
	<input type="button" class="reset" value="reset"/>
</form>

	var option6 = {
		debug:true,
		onfocusout:function(element, event) { $(element).valid(); },
		rules:{
			username:{required:true},
			password:{required:true},
			email:{required:true,email:true}
		},
		messages:{
			username:{required:'用户名不能为空'},
			password:{required:'密码不能为空'},
			email:{required:"邮箱不能为空",email:"邮箱格式不正确"}
		}
	}

**onkeyup**:(类型:boolean 或者 function)在发生keyup事件的时候调用验证。  
**onclick**:(类型:boolean 或者 function)checkboxes and radio 发生点击事件的时候调用验证。  
**focusInvalid**:(默认:false)点出提交的时候,如果有没有通过验证的元素,这个元素会获取焦点。  
**focusCleanup**: (默认: false)元素获取焦点时移除元素的 .error class 属性,并隐藏错误提示信息。  
**errorClass**: (默认:"error") 给错误提示加上一个标签,你可以给错误提示信息加上一个其他的class。  
**validClass**: (默认: "valid") 使用跟 errorClass 一样。  
**errorElement**: (默认: "label") 默认错误信息是入在一个label里面,你也可以改成其他的标签比如span。  
**wrapper**: (默认: window),**errorLabelContainer**,**errorContainer**,这三个常常一起使用。  
<form id="form_7">
	<div id="messageBox"><ul></ul></div>
	<label>username:</label><input type="text" name="username" ><br/>
	<label>password:</label><input type="password" name="password"><br/>
	<label>email:</label><input type="text" name="email"><br/>
	<input type="submit" value="submit" >
	<input type="button" class="reset" value="reset"/>
</form>

	var option7 = {
		debug:true,
		errorContainer: "#messageBox",
		errorLabelContainer: "#messageBox ul",
		wrapper: "li", debug:true,
		rules:{
			username:{required:true},
			password:{required:true},
			email:{required:true,email:true}
		},
		messages:{
			username:{required:'用户名不能为空'},
			password:{required:'密码不能为空'},
			email:{required:"邮箱不能为空",email:"邮箱格式不正确"}
		}
	}

**showErrors**:(function),错误信息显示处理的方法，默认会调用 defaultShowErrors 这个方法,你也可自定义一个方法去显示处理错误信息的显示。  
**showErrors**:这个回调的方法,接收两个参数,一个是errorMap,一个是errorList。errorMap是键值对的数据形式，key是未通过验证的元素的name值,value是错误提示信息。    
	* errorList是数据形式数据。有两个属性,一个是message(错误提示信息)别一个是element(对应的未通过验证的DOM元素)。  
	* errorPlacement (default: 在未通过验证的元素后面添加label标签显示错误信息)。可以自定义错误信息显示的位置。这个回调方法有两个参数一个是error(错误信息元素Jquery对象),element(未通过验证元素Jquery对象)。
**success**:(类型：string或者function),如果是一个string类型的值在通过验证后会给原来的错误提示信息的标签加一个给定的class,如果是一个方法的法,你可以通过个这方法对通过验证之后对错误提示信息加一些特定的操作。比如你在通过验证之后,将原来的提示改成"OK"。  
<form id="form_8">
	<label>username:</label><input type="text" name="username" ><br/>
	<label>password:</label><input type="password" name="password"><br/>
	<label>email:</label><input type="text" name="email"><br/>
	<input type="submit" value="submit" >
	<input type="button" class="reset" value="reset"/>
</form>

	var option8 = {
		debug:true,
		rules:{
			username:{required:true},
			password:{required:true},
			email:{required:true,email:true}
		},
		messages:{
			username:{required:'用户名不能为空'},
			password:{required:'密码不能为空'},
			email:{required:"邮箱不能为空",email:"邮箱格式不正确"}
		},
		success: function(label) {
			label.addClass("valid").text("Ok!")
		},
	}

**highlight**:(默认:添加一个errorClass 给未通过验证的元素)回调方法有三个参数element,errorClass,validClass可以操作这三个元素对验证效果做一些处理。  


<script src="http://ajax.aspnetcdn.com/ajax/jquery.validate/1.11.1/jquery.validate.min.js"></script>
<script type="text/javascript">
	$(document).ready(function(){
		var option1 = {
			rules:{
				username:{required:true},
				password:{required:true},
				email:{required:true,email:true}
			},
			messages:{
				username:{required:'用户名不能为空'},
				password:{required:'密码不能为空'},
				email:{required:"邮箱不能为空",email:"邮箱格式不正确"}
			}
		}

		$("#form_1").validate(option1);

		var option2 = {
			debug:true,
			rules:{
				username:{required:true},
				password:{required:true},
				email:{required:true,email:true}
			},
			messages:{
				username:{required:'用户名不能为空'},
				password:{required:'密码不能为空'},
				email:{required:"邮箱不能为空",email:"邮箱格式不正确"}
			},
			invalidHandler: function(event, validator) {
				log(event);
				log(validator);
				
				var errors = validator.numberOfInvalids();
				if (errors) {
					alert(errors + "fields invalid");
				} else{
					alert("valid")
				}
			}
		}

		$("#form_2").validate(option2);
		
		
		var option3 = {
			debug:true,
			ignore:".ignore",
			rules:{
				username:{required:true},
				password:{required:true},
				email:{required:true,email:true},
				userId:{required:true}
			},
			messages:{
				username:{required:'用户名不能为空'},
				password:{required:'密码不能为空'},
				email:{required:"邮箱不能为空",email:"邮箱格式不正确"},
				userId:{required:"用户id不能为空"}
			},
			invalidHandler: function(event, validator) {
				log(event);
				log(validator);
				
				var errors = validator.numberOfInvalids();
				if (errors) {
					alert(errors + "fields invalid");
				} else{
					alert("valid")
				}
			}
		}

		$("#form_3").validate(option3);
		
		var option4 = {
			debug:true,
			rules:{
				email:{
					required:true,
					email:{
						 depends: function(element) {
							log(element);
							log($("#form_4 #choose_01").val());
						 	return ($("#form_4 #choose_01").val() === "true") ? true : false;
						 }
					}
				},
			},
			messages:{
				email:{required:"邮箱不能为空",email:"邮箱格式不正确"},
			}
		}

		$("#form_4").validate(option4);
		

		var option5 = {
			debug:true,
			rules:{
				password:{
					required:true,
					rangelength:[6,16]
				}
			},
			messages:{
				password:{
					required:"不能为空",
					rangelength:jQuery.format("bettwen {0} and {1} characters")
				}
			}
		}

		$("#form_5").validate(option5);

		var option6 = {
			debug:true,
			onfocusout:function(element, event) { $(element).valid(); },
			rules:{
				username:{required:true},
				password:{required:true},
				email:{required:true,email:true}
			},
			messages:{
				username:{required:'用户名不能为空'},
				password:{required:'密码不能为空'},
				email:{required:"邮箱不能为空",email:"邮箱格式不正确"}
			}
		}

		$("#form_6").validate(option6);
		
		var option7 = {
			debug:true,
			 errorContainer: "#messageBox",
			 errorLabelContainer: "#messageBox ul",
			 wrapper: "li", debug:true,
			rules:{
				username:{required:true},
				password:{required:true},
				email:{required:true,email:true}
			},
			messages:{
				username:{required:'用户名不能为空'},
				password:{required:'密码不能为空'},
				email:{required:"邮箱不能为空",email:"邮箱格式不正确"}
			}
		}

		$("#form_7").validate(option7);

		var option8 = {
			debug:true,
			rules:{
				username:{required:true},
				password:{required:true},
				email:{required:true,email:true}
			},
			messages:{
				username:{required:'用户名不能为空'},
				password:{required:'密码不能为空'},
				email:{required:"邮箱不能为空",email:"邮箱格式不正确"}
			},
			success: function(label) {
			 	label.addClass("valid").text("Ok!")
			},
		}

		$("#form_8").validate(option8);
		
		
		$(".reset").on(
			"click",function(){
				var form = $(this).closest("form");
				form[0].reset();
				form.find("label.error").css("display","hidden");
			}
		)
		
	});
	
	function log(infor){
		window.console || console.log(infor);
	}
</script>

