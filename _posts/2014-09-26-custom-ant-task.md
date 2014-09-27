---
layout: post
title:  "ant 自定义 task"
category: java
tags: [ant, notes]
keywords: ant, ant task, ant 自定义task, 自动化构建
description: ant 使用创建自定义task
---

###ant custom task: hello###
最简单的 task, 只需要一个对象, 其中有一个 execute 方法, 之后在 build.xml 通过 deskdef 定义 task, 指定 task 名字, task 对象路径, 以及 task 对象的完整名称

task对象:

    public class Hello {
	    public void execute() {
		    System.out.println("hello");
	    }
    }

ant 配置:

	<!-- build.xml 配置 -->
	<target name="hello" description="hello">
		<taskdef name="hello" classname="com.test.tools.ant.Hello" classpath="${classes.dir}" />
		<hello />
	</target>

输出:
	
	hello:
        [hello] hello
	
###ant custom task: attr###
带属性的 ant task, 在 task 对象中添加与 task 对应的属性字段, 并提供 set 方法

task 对象:

    /*
     * ant custom, 带有两人个属性的 Ant task
     */
    public class SplicerAttr {
	    private String hello;
	    private String world;
	    public void setHello(String hello) {
		    this.hello = hello;
	    }
	    public void setWorld(String world) {
		    this.world = world;
	    }
	    public void execute() {
		    System.out.println(hello + world);
	    }
    }

ant 配置:
	
    <!-- 现在想给 task 加上两个属性, hello, world -->
	<target name="splicerAtr">
		<taskdef name="splicerAttr" classname="com.test.tools.ant.SplicerAttr" classpath="${classes.dir}" />
		<splicerAttr hello="hello" world="world" /> 
	</target>	

输出:	

	splicerAtr:
        [splicerAttr] helloworld

###ant custom task: text###
跟 ant 有 echo 一样, 可以标签中使用文本<echo>hello world</echo>

task 对象:
    
    /**
     * 可以带文本的 ant task
     */
    public class SplicerText {
	    private String hello;
	    private String world;
	    private String text;
	    public void addText(String text){
		    this.text = text;
	    }
	    public void setHello(String hello) {
		    this.hello = hello;
	    }
	    public void setWorld(String world) {
		    this.world = world;
	    }
	
	    public void execute() {
		    System.out.println(hello + world + text);
	    }
    }
 
 ant 配置:
    
    <taskdef name="splicerText" classname="com.test.tools.ant.SplicerText" classpath="${classes.dir}" />
	
	<!-- 给 task 加上 test -->
	<target name="splicerText">
			<splicerText hello="hello" world="world" >text</splicerText> 
	</target>
	
	<!-- ${classes.dir} 在这里只是被当做了一个普通文本去处理 -->
    <target name="splicerText2">
    	<splicerText hello="hello" world="world" >${classes.dir}</splicerText> 
    </target>

输出:

    splicerText:
    [splicerText] helloworldtext	
        
    splicerText2:
    [splicerText] helloworld${classes.dir}

上面对 text 的输出并不会去处理 ${} 点位符, 需要改进一下,使用 project.replaceProperties() 方法对占位符进行处理

task 对象:

    public class SplicerTextHold {
	    private String hello;
	    private String world;
	    private String text;
	    private Project project;
	
	    public void setProject(Project project) {
		    this.project = project;
	    }
	    public void addText(String text){
		    this.text = project.replaceProperties(text);
	    }
	    public void setHello(String hello) {
		    this.hello = hello;
	    }
	    public void setWorld(String world) {
		    this.world = world;
	    }
	    public void execute() {
		    System.out.println(hello + world + text);
	    }
    }
    
ant 配置:

    <!-- ${classes.dir} 在这里只是被当做了占位符去处理 -->
	<target name="splicerTextHold">
		<taskdef name="splicerTextHold" classname="com.test.tools.ant.SplicerTextHold" classpath="${classes.dir}" />
		<splicerTextHold hello="hello" world="world" >${classes.dir}</splicerTextHold> 
	</target>
	
输出:

    splicerTextHold:
    [splicerTextHold] helloworldbin
    
note:

    上面的 Project 为 org.apache.tools.ant.Project 对象, 如果 task 继承了 ant 对象可以不需要 setProject 方法, 显示是因为 Ant 对象已经实现了 set 方法
    

###ant custom: NestedElemetn###
带元素的 task, 下面一个 task 带有带有一个 <Message msg="msg"></message> 的内嵌元素. 实现的关键在于,在 task 对象中需要有 create, add, addConfigured + NestedElement 方法中一个方法或者多个都可以, 如果这三个方法都存在 ant 实际会调用哪一个并不确定, 这取决于 java 虚拟机.

task 对象:

    public class WithNestedElement extends Ant {
	    @Override
	    public void execute() {
		    System.out.println(messages.size());
		    for (Iterator it = messages.iterator(); it.hasNext();) { // 4
			    Message msg = (Message) it.next();
			    log(msg.getMsg());
		    }
	    }
	    Vector<Message> messages = new Vector<Message>();
	    //使用createElement() 方法
	    public Message createMessage() {
		    Message m = new Message();
		    messages.add(m);
		    return m;
	    }
	    //使用 addMessage 方法
	    public void addMessage(Message message){
		    messages.add(message);
	    }
        //使用 addConfiguredMessage 方法
	    public void addConfiguredMessage(Message anInner){
		    messages.add(anInner);
	    }
    }
    
    /**
     * 内嵌元素
     */ 
    public class Message {
	    public Message() {
	    }
	    String msg;

	    public void setMsg(String msg) {
		    this.msg = msg;
	    }
	    public String getMsg() {
		    return msg;
	    }
    }

ant 配置:

    <!-- 定义一个 task 这个 task 可以内嵌多个 message 的元素 -->
	<target name="withNestedElement" description="user my task">
		<taskdef name="withNestedElement" classname="com.test.tools.ant.WithNestedElement" classpath="${classes.dir}" />
		<withNestedElement>
			<message msg="aaaa"/>
			<message msg="bbbb"/>
		</withNestedElement>
	</target>
    
输出:

    withNestedElement:
    [withNestedElement] aaaa
    [withNestedElement] bbbb
    
###ant custom task: type###
带自定义类型的 task

task 对象:
    
    public class WithNestedConditions extends Ant {
	    private List<Condition> conditions = new ArrayList<Condition>();
	    @Override
	    public void execute() {
		    Iterator<Condition> iter = conditions.iterator();
		    while(iter.hasNext()){
			    Condition c = iter.next();
			    log(String.valueOf(c.eval()));
		    }
	    }
	    public void add(Condition c) {
		    conditions.add(c);
	    }
    }

ant 配置:

    <!-- 定义类型 -->
    <typedef name="condition.equals" classname="org.apache.tools.ant.taskdefs.condition.Equals"/>
    
    <target name="withNestedConditions" description="user my task">
		<taskdef name="withNestedConditions" classname="com.test.tools.ant.WithNestedConditions" classpath="${classes.dir}" />
		<withNestedConditions>
			<condition.equals arg1="false" arg2="true"/>
			<condition.equals arg1="true" arg2="true"/>
		</withNestedConditions>
	</target>
	
输出:

    [withNestedConditions] false
    [withNestedConditions] true

###总结:###
ant 自定义 task 还是使用简单:

1. 创建一个 task 对象, 一个普通的 java 对象, 你也可以继承 ant 对象. 但是不必须的(继承 ant 会带来一些方便)
2. 给 task 的属性, 文本创建 set 方法
3. 给 task 添加内嵌元素添加一个 create 或者 add , addConfigured + NestedElement 方法
4. 给 task 添加自定义 type , 使用 add 方法
5. 使用 public void execute 方法处理任务

当然这只是一些玩具代码, 要处理实际问题, 还是要在 execute 方法中做复杂的逻辑处理.

参考:

<a href="http://ant.apache.org/manual/index.html">http://ant.apache.org/manual/index.html</a>  
<a href="http://ant.apache.org/manual/develop.html#writingowntask">http://ant.apache.org/manual/develop.html#writingowntask</a>

