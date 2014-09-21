---
layout: post
title:  "Ognl 跟 struts2 ValueStack"
category: java
tags: [struts2, ValueStack, Ognl]
keywords: struts,ValueStack, Ognl, struts2 ognl 表达式
description: 分析Ognl的使用, 分析 Ognl 表达式在 Struts2 中的使用
---
Ognl: Object Graph Navigation Language, 对象图导航语言. 

在 Struts2 开发的时候， 经常会使用在 Ognl 表达式，但是并没有直接去接触到 Ognl 相关的一些类， 这里会看一下 Ognl 工作的一些类， 这样可能更好的理解 Ognl. Ognl 里一个重要的对象 OgnlContext 跟 Ognl, Ognl 相关的求值都是在 OgnlContext 上展开的. OgnlContext 实际上是一个 Map 对象. Ognl 中可以说是包含了一些方便的静态方法。下面看一小段代码: 

一个简单的 Person 对象:

    public class Person {

	    private String name;
	    private String age;
	    public String getName() {
		    return name;
	    }
	    public void setName(String name) {
		    this.name = name;
	    }
	    public String getAge() {
		    return age;
	    }
	    public void setAge(String age) {
		    this.age = age;
	    }
	    public static String staicMethod(){
		    return "static";
	    }
	
    }


我觉得**其实 Ognl 说白了就是你给我一些对象跟表达式，我就可以通过解析这个表达式，从对象中找到对应的值**

先看一个简单的例子: 

	Person p = new Person();
	p.setName("zhang");
	
	String name  = (String) Ognl.getValue("name", p);//value is 'zhang'

创建一个 Person 对象, 通过 Ognl 的静态方法 getValue, 最后从 Person 对象中得到了 name 属性的值. 但是不要小看了这一行简单的代码, 其实里面做的事情可多了.

1. 首先将 "name" 这个 Ognl 表达式做出解析: **Ognl.parseExpression("name")**. 别怀疑这就是一个 Ognl 表达式， 虽然有些简单).
2. 以给出的 Person 对象 p 以根对象, 创建 OgnlContext 上下文.**createDefaultContext(root)** 
3. 从以 Person 对象为根对象 OgnleContext 上下文中, 寻找表达式 "name" 对应的值


OgnlContext 本身是一个 Map 除了根对象, 你也可以将其他的对象放在 OgnlContxt 不同的命名空间中, 怎么放? 其实也就是 map 的 put 方法而已啦. 下面我们将一些对象放在 OgnlContext 不同的命名空间里

    Person p = new Person();
	p.setName("zhang");

	Person p1 = new Person();
	p1.setName("zhang1");
	
	Person p2 = new Person();
	p2.setName("zhang2");
	
	Person p3 = new Person();
	p3.setName("zhang3");
	
	OgnlContext context = new OgnlContext(); // 创建 OgnlContext
	context.put("p", p);
	context.put("p1", p1);
	context.put("p2", p2);
	context.put("p3", p3);//将对象放入 context 的不同 namespace
	context.setRoot(p);//设置 context 的根对象
	
	Object expr = Ognl.parseExpression("name"); //这里自己写代码去解释一下 Ognl 表达式
	String name = (String) Ognl.getValue(expr, context, context.getRoot());// 从 Ognl 上下文中得到表达式的值 最后返回 name 的值是 "zhang"

上面的代码，确实是将多个 Person 对象放入了 OgnlContext 中, 通过表达式返回的值还是 "zhang", 这里就涉及到了 OgnlContext 的**根对象**跟**命名空间**, 因为我们的 Ognl 表达式的语法就是规定 "name" 这样的表达式是去根对象中找值, 如果你把根对象设置成 P1 那么也会从 p1 对象中找值,返回来的值就是 "zhang1"了, 那么怎么去其他命名空间找值呢, 你可以将表达式改成 "#p2.name"

	Object expr = Ognl.parseExpression("#p2.name");
	String name = (String) Ognl.getValue(expr, context, context.getRoot());//name is zhang2

Ognl 操作集合对象(以List为例)

	List<Person> persons = new ArrayList<Person>();
	persons.add(p);
	persons.add(p1);
	persons.add(p2);
	persons.add(p3);
	
	Object obj = Ognl.getValue("[1].name", persons); //得到ArrayList中第二个元素的name属性
	Object obj2 = Ognl.getValue("size()", persons); //得到ArrayList元素个数
	Object obj1 = Ognl.getValue("size", persons); //得到ArrayList元素个数
	

上面的这些代码展示了 Ognl 表达式操作对象 ArrayList 的操作, 你会发现 Ognl 可以直接去调用方法,而实际上 "name" 这样的表达式也是调用了对象的 getName() 方法, 而 "name" 表达式也等价于表达式 "getName()"， 而且你也可以往方法里传参数, 但是很奇怪的事 ArrayList 并没有 size 这个属性为什么也可以得到值呢，而且返回的值还是跟调用 size(） 方法返回的值一样，这里涉及到**伪属性**

Ognl 还可以调用静态的方法, 表达式以 "@Class@Method" 这样的形式调用

    Object person = Ognl.getValue("@con.test.ognl.Person@staicMethod()", persons); //调用 Person 的静态方法 staicMethod()
    Object person = Ognl.getValue("@@min(4, 5)", persons); //调用 java.lang.Math的 min 方法

Ognl 调用 java.lang.Math 的静态方法的时候可以不写类名直接两个 @@+methodname, Ongl 默认的.但是为什么呢?我也不知道 

Ognl 集合过滤跟投影
OGNL过滤集合的语法为：collection.{? expression}

    Person p = new Person();
	p.setName("zhang");
	
	Person p1 = new Person();
	p1.setName("zhang1");
	
	Person p2 = new Person();
	p2.setName("zhang2");
	
	Person p3 = new Person();
	p3.setName("zhang3");
	
    List<Person> persons = new ArrayList<Person>();
	persons.add(p);
	persons.add(p1);
	persons.add(p2);
	persons.add(p3);
	
	context = new OgnlContext();
	context.put("persons", persons);
	System.out.println(Ognl.getValue("#persons.{? #this.name.length() > 5}", context, persons));
    
    //[com.test.ognl.Person@699a3d76, com.test.ognl.Person@d394424, com.test.ognl.Person@2aa89e44]

放入list中的 Person 对象本来是 4 个, 经过过滤(person的name长度大小5的对象)后只剩下了 3 个对象

OGNL投影集合的语法为：collection.{expression}
    
    System.out.println(Ognl.getValue("#persons.{name}", context, persons)); 
    //[zhang, zhang1, zhang2, zhang3]


当然 Ognl 表达式还可以做什么的事情, 新建对象, 构建一个集合对象,等... 这里并不是要介绍 Ognl 表达式的语法, 所以要知道 Ognl更多的语法怎么用可以去这里了解: <a href="http://commons.apache.org/proper/commons-ognl/language-guide.html">http://commons.apache.org/proper/commons-ognl/language-guide.html</a>

这里只是简单总结:
####属性####

| 表达式 |  |
| ----- | ----- |
| "name" | 根对象的name属性, 等于调用了 getName() 方法 |
| "person.name" | 根对象的person对象的name属性值
| "#person.name" | namespace 为 person 的对象的 name 属性值

####方法####

| 表达式 |  |
| ----- | ----- |
| "getName()" | 根对象的 getName() 方法 
| "#person.getName()" | namespace 为 person 的对象的 getName() 方法调用

####伪属性####

| 表达式 | 伪属性 | 方法 |
| ----- | ----- | ------ |
| Collection | size, isEmpty | size(), isEmpty |
| List | iterator | iterator() |
| Map | keys,values | keySet(), valueSet() |
| Set | iterator | iterator() |
| Iterator | next , hasNext | next(), hasNext() |
| Enumeration | next, hasNext, nextElement, hasMoreElements | next(), hasNext(), nextElement(), hasMoreElements() |

####静态属性和方法####

| 表达式 |
| ----- |
| "@@min(4, 5)" |
| "@java.lang.Math@min(44,56)" |
| "@java.lang.Math@PI" |

####new 对象####

| 表达式 |
| ----- |
| "new com.test.Person()" |

####过滤####

| 表达式 |  |
| ----- | ----- |
| collection.{? expression} | "#persons.{? #this.name.length() > 5}“ |

####投影####

| 表达式 |  |
| ----- | ----- |
| collection.{expression} | ""#persons.{name}" |

####满足条件元素####

| 表达式 |  |
| ----- | ----- |
| collection.{^ expression} | "#persons.{^ #this.name.length() > 5}" |

下面是看一下 Struts2 中 Ognl 的使用:

###Struts2对 Ognl 增强处理: ValueStack###
ValueStack 的说明, ValueStack 允许多个Bean被push到ValueStack中, 可以使用EL表达式按照**从上到下**的顺序跟ValueStack中的每一个Bean进行比较计算.

一个例子来说明:
现在有三个对象(伪代码),在ValueStack中

| 值栈 |
| ----- |
| person{name,age} |
| book{name,cagetory,price} |
| computer{type,price} |

"name" 返回来的是 Person.name
"type" 返回来的是 book.type

Ognl 有一个根对象, Sturts2 跟 Ognl 结合的时候也会有一个根对象, 而这个跟对象就是 ValueStack ，而ValueStack 中**最顶层对象就是 Action** 所以在页面里面直接写 <s:property value="name"> 的时候, 这个时候访问的就是 Action 中的 name 属性值, 除非 Action 对象中没有 name 属性, 这样就会顺着 ValueStack 找下去, 这样虽然说 Ognl 来说只有一个根对象, 但是 Struts 对将 Ognl 的根对象设置成 ValueStack 这样就好像让 Ognl 有了多个根对象一样.

查看 OgnlValueStack 中的源代码, 发现它的根元素是一个继承自 ArrayList 的 CompoundRoot 对象,CompoundRoot 的几个方法, 为 ValueStack 提供了所谓的 top , N 方法 
    
    public class CompoundRoot extends ArrayList {

        public CompoundRoot() {
        }

        public CompoundRoot(List list) {
            super(list);
        }


        public CompoundRoot cutStack(int index) {
            return new CompoundRoot(subList(index, size()));
        }

        public Object peek() {
            return get(0);
        }

        public Object pop() {
            return remove(0);
        }

        public void push(Object o) {
            add(0, o);
        }
    }

ValueStack 的 top 语法
    返回 ValueStack 中的第一个对象, 通过 CompoundRoot 的　peek 方法, 返回第一个元素
ValueStack 的 N 语法
    返回 ValueStack 中的索引为 N 及其以下的元素的子栈, 通CompoundRoot的 cutStack 方法得到子栈


在 Strust 的 Ognl 上下文中 除了 ValueStack 这个根对象外, 还有其他命名空间的对象(除了这些实际上还会有其他的对象,下面的代码会给出)


| namespace | 对应表达式意义 |
| ----- | ----- |
| action ｜ 当前的 Action 对象 ｜
| parameters | #parameters.name 相当于 request.getParameter("name") |
| request | #request.name 相当于 request.getAttribute("name") |
| session | #session.name 相当于 session.getAttribute("name") |
| application | #application.name 相当于 application.getAttribute("name") |
| attr | #attr.name, pageContext -> request -> session -> application 的顺序访问 attribute |
| value stack(root) | 跟对象,会按从上到下顺序来查看,顶层对象为当前的 Action |


####页面中的 Ognl 表达式####
1. 如果标签属性值是Ognl表达式, 无需加上 %{}， 比如 \<s:property value="#request.name"\> 是不需要加 %{} 的
2. 如果标签属性值是字符串类型出现在 %{} 会被解析成 OGNL 表达式 比如: \<a href="testAction?name=%{#request.name}"\>



###ActionContext,ServletActionContext, ValueStack###
实际上ActionContext,ServletActionContext, ValueStack,Ognl 维护的是相同的上下文
Ognl 提供处理 Ognl 表达式的能力.
ValueStack 提交一个值栈就好像可以让 Ognl 有多个根元素.
ActionContext 提供跟当前线程，也就是每一次请求绑定的机构, 通过 ThreadLocal 模式.
ServletActionContext 提供一些方法, 方便返回真实的与 Serlvet 容器依赖的 request　等对象

而这个 Struts Ognl 的 Context 正是 ActionContext 所引用的 Context, 可参考 ActionContext 的创建代码 

    public ActionContext createActionContext(HttpServletRequest request, HttpServletResponse response) {
        ActionContext ctx;
        Integer counter = 1;
        Integer oldCounter = (Integer) request.getAttribute(CLEANUP_RECURSION_COUNTER);
        if (oldCounter != null) {
            counter = oldCounter + 1;
        }
        
        ActionContext oldContext = ActionContext.getContext();
        if (oldContext != null) {
            // detected existing context, so we are probably in a forward
            ctx = new ActionContext(new HashMap<String, Object>(oldContext.getContextMap()));
        } else {
            ValueStack stack = dispatcher.getContainer().getInstance(ValueStackFactory.class).createValueStack();
            stack.getContext().putAll(dispatcher.createContextMap(request, response, null, servletContext));
            ctx = new ActionContext(stack.getContext());
        }
        request.setAttribute(CLEANUP_RECURSION_COUNTER, counter);
        ActionContext.setContext(ctx);
        return ctx;
    }


也可以随便写一个测试的代码,你会发现代码输出的结果都为 ture, 说明它确实引用的是同一个 Context　上下文:

    ActionContext actionContext = ActionContext.getContext();
    ValueStack valueStack = actionContext.getValueStack();
    
    Map actionContextMap = actionContext.getContextMap();
    Map valueStackMap = valueStack.getContext();

    System.out.println("valueStack Context Map and action Context map :" + valueStackMap.equals(actionContextMap));
    

ActionContext 上下文中有哪些对象(自己并没有额外添加的情况下), 输入看一下就知道了:

    System.out.println(actionContextMap.size());
    Iterator iter = actionContextMap.keySet().iterator();
	while(iter.hasNext()){
		Object key = iter.next();
		System.out.println("key ==> value: " + key +"==>"+ actionContextMap.get(key));
	}

输出结果 key,也可以说是 Ognl　上下文的 namesapce:

    key ==> value: com.opensymphony.xwork2.dispatcher.HttpServletRequest
    key ==> value: application
    key ==> value: com.opensymphony.xwork2.ActionContext.locale
    key ==> value: com.opensymphony.xwork2.dispatcher.HttpServletResponse
    key ==> value: xwork.NullHandler.createNullObjects
    key ==> value: com.opensymphony.xwork2.ActionContext.name
    key ==> value: com.opensymphony.xwork2.ActionContext.conversionErrors
    key ==> value: com.opensymphony.xwork2.ActionContext.application
    key ==> value: attr
    key ==> value: com.opensymphony.xwork2.ActionContext.container
    key ==> value: com.opensymphony.xwork2.dispatcher.ServletContext
    key ==> value: com.opensymphony.xwork2.ActionContext.session
    key ==> value: com.opensymphony.xwork2.ActionContext.actionInvocation
    key ==> value: xwork.MethodAccessor.denyMethodExecution
    key ==> value: report.conversion.errors
    key ==> value: session
    key ==> value: com.opensymphony.xwork2.util.ValueStack.ValueStack
    key ==> value: request
    key ==> value: action
    key ==> value: struts.actionMapping
    key ==> value: parameters
    key ==> value: com.opensymphony.xwork2.ActionContext.parameters

ValueStack 根对象中的元素呢(自己并没有额外添加的情况下):

    iter = actionContext.getValueStack().getRoot().iterator();
	while(iter.hasNext()){
		System.out.println(iter.next());
	}

输出的结果(这也像之前说的那句话,ValueStack会把当前Action在放值栈的顶层):

    com.jwgl.unit.action.UnitAction@1d1dfa6a
    com.opensymphony.xwork2.DefaultTextProvider@2a6ebfd7

###参考:###
<a href="http://commons.apache.org/proper/commons-ognl/language-guide.html" target="_blank" >http://commons.apache.org/proper/commons-ognl/language-guide.html</a> 

<a href="http://struts.apache.org/release/2.3.x/docs/ognl-basics.html" target="_blank" >http://struts.apache.org/release/2.3.x/docs/ognl-basics.html</a>

<a href="http://struts.apache.org/release/2.3.x/docs/ognl.html" target="_blank" >http://struts.apache.org/release/2.3.x/docs/ognl.html</a>


















