---
layout: post
title:  "Ruby 中的编码问题"
category: ruby
tags: [ruby, encoding]
keywords: ruby, ruby encoding, external encoding, internal encoding, string encoding, GBK(argumenterror)
description: ruby 在处理文本时报, in 'split':invalid byte sequence in GBK(argumenterror) 错误,查看 ruby 文档, 了解ruby 对象字符串编码方案的处理, Ruby IO 对象 external encoding 跟 internal encoding 在处理字符串的作为.
---

最近在用ruby 读取文件 并用 split 来分割是, 提示: in 'split':invalid byte sequence in GBK(argumenterror)
这样的错误,花了一些时间整理一下 Ruby 关于对于字符串编码方式的处理的一些问题. (ruby 2.0)

### Changing an encoding ###
有两种不同的方式可以改变跟字符串关系的编码.

**String#force_encoding**, force_encoding 并不改变字符串内部的结构,只是改变处理字符串的方式.并没有实际改变字符串的编码方式

    #encoding: UTF-8

    str="te测"

    p str.encoding #=> <Encoding:UTF-8>
    p str.bytes #=> [116, 101, 230, 181, 139]

    str2 = str.force_encoding "GBK"

    p str.encoding  #=> <Encoding:GBK>
    p str2.encoding #=> <Encoding:GBK>

    p str.bytes #=> [116, 101, 230, 181, 139] #=> 字节数组并没有发生改变
    p str2.bytes #=> [116, 101, 230, 181, 139]


    p str.object_id #=> 15745460
    p str2.object_id #=> 15745460 #=> 同一个对象
    

**String#encode** , 使用新的编码方式创建一个新的字符串,原字符串还是没有发生变化.

    #encoding: UTF-8

    str="te测"

    p str.encoding #=> <Encoding:UTF-8>
    p str.bytes #=> [116, 101, 230, 181, 139]

    str2 = str.encode "GBK"

    p str.encoding  #=> <Encoding:UTF-8>
    p str2.encoding #=> <Encoding:GBK>

    p str.bytes #=> [116, 101, 230, 181, 139] #=>原字符串字节数组没有发生变化
    p str2.bytes #=> [116, 101, 178, 226] #=>新字符串字节数组没有发生了变化


    p str.object_id #=> 16114960
    p str2.object_id #=> 18212580 #=> 不同对象

**String#encode!** , 跟 String#encode 不同的是它直接在原字符串上进行编码,而不是在创建一个新的字符串.
    
    #encoding: UTF-8

    str="te测"

    p str.encoding #=> <Encoding:UTF-8>
    p str.bytes #=> [116, 101, 230, 181, 139]

    str2 = str.encode! "GBK"

    p str.encoding  #=> <Encoding:GBK>
    p str2.encoding #=> <Encoding:GBK>

    p str.bytes #=> [116, 101, 178, 226]  #=> 原字符串编码发生了改变
    p str2.bytes #=> [116, 101, 178, 226]


    p str.object_id #=> 17776460
    p str2.object_id #=> 17776460 #=> 同一个对象


在默认的情况下,
被转换的字符在目标字符中没有定义,会产生一个 Encoding::UndefinedConversionError 的异常.
如果原字符中有不能通过验证的byte序列,在转换过程中会出现 Encoding::InvalidByteSequenceError 异常.
使用字符串已经关联的编码方法进行 encode, 这个操作什么也不做(no-op), 所以就算字符串有不能过通验证的字符也不会产生异常

    #encoding: UTF-8

    str1 = "测试" #=> 在ASCII中不存在
    str2 = "\xc2" #=> 有不能通过验证的字符
    str3 = "\xc2\xa1" #=> 能通过验证的字符


    puts str1.valid_encoding? #=> true
    #str1.encode "ISO-8859-1" 
    #=> 'encode': U+6D4B from UTF-8 to ISO-8859-1 (Encoding::UndefinedConversionError)

    puts str2.valid_encoding? #=> false
    #str2.encode "ISO-8859-1"
    #=>  incomplete "\xC2" on UTF-8 (Encoding::InvalidByteSequenceError)

    puts str3.valid_encoding? #=> false
    str3.encode "ISO-8859-1" #=> ok

    str2.encode "UTF-8" #=> ok, 虽然, "\xc2" 中存在不能过通验证的字符,但是使用字符串本身关系的编码方式,重新编码也不会产生异常,因为这个操作什么也不会做
    

### Script encoding ###
Ruby 的脚本代码都有关联的 encoding, 脚本中所有的 字符串字面值都会使用这种 encoding.
默认 ruby script encoding 是 ASCII 编码(Encoding::US-ASCII), 但是可以在脚本的第一行通过 magic comment 进行修改(或者是第二行, 如果第一行是 shebang line ).
\#encoding: UTF-8
或者
\#coding: UTF-8

ruby -K 可以改变默认的本地编码(default locale encoding), 但是不推荐这样做.
使用 \_\_ENCODING\_\_ 关键字得到当前脚本的编码


### Locale encoding ###
本地编码,环境中默认的编码方式,通过从本地得到

### Filesystem encoding ###
默认的环境中文件系统的字符串编码,通常用于文件名跟文件路径.

### External encoding ###
Ruby 的每一个 IO 对象都有一个外部编码. 表示 Ruby 将使用这种编码方式来读取数据.   
默认情况下 Ruby 使用默认的内部编码设置给 IO 对象, 而 Ruby 的默认内部编码又是由 Local encoding 决定的,(或者是可以通过 ruby -E ISO-8859-1 来设置).  
使用 Encoding::default_external 得到查看 Ruby 默认的内部编码,Encoding::default_external 也可以设置 Ruby 默认内部编码. 最好不要这样做,这样做会导致使用 Encoding::default_external 设置编码之前的创建的字符串跟设置编码之后创建的字符串编码不一致(这里说的创建的字符串是把通过IO对象创建的字符串).
    
    #encoding: UTF-8

    file = File.open("en.rb");

    file.each{|line|
      
      puts line
      puts line.encoding #=> 在没有设置 default_external 这里是 utf-8(跟环境相关),
      
    }

    Encoding.default_external = "ISO-8859-1"

    file.each{|line|
      
      puts line
      puts line.encoding #=> 设置 default_external 得到 ISO-8859-1
      
    }

当你知道 IO 对象读取文件数据的实际编码 跟 Ruby 的 default_external 的编码方式不一样时, 你可以在创建 IO 对象创建的时候设置编码方式. 使用IO#set_encoding,或者创建 IO 对象时给定编码.
    
    #encoding: UTF-8


    file = File.open("en.rb", "r:ISO-8859-1")

    file.each{|line|
      
      puts line
      puts line.encoding #=> ISO-8859-1
      
    }


### Internal encoding ###
需要处理的 IO 对象的数据跟IO对象的 external encoding 不一致时. 你可以设置 IO 对象的 internal encoding.  
当 Ruby 从 IO 对象中读取数据时候, 将使用给定的 internal encoding 对读取数据进行转码. 反过来, 向 IO 对象写数据时, 将数据从 internal encoding 转成 external encoding.

IO 对象的 internal encoding 是可以选的. 如果没有设置,默认使用 Ruby 的 defualt internal encoding . 如果 Ruby 的 default internal encoding 也没有设置, 那么就是 nil 了. 这也意味着向 IO 写数据时不会转码了
    
    #encoding: UTF-8

    puts Encoding.default_internal #=> nil (我的机器上没有设置 default_internal).
    
跟 external encoding 一样, default external encoding 也可以使用 Encoding::default_internal 来设置 . 或者使用 ruby -E


### 一个例子 ###

    #encoding: UTF-8

    #=> 这里字符串的实际编码方式是 "UTF-8"
    string = "R\u00E9sum\u00E9"

    #=> 在将字符串输出时,指定了 IO 对象的 external encoding 为 ISO-8859-1
    #=> 这样 UTF-8 的字符串被当作 ISO-8895-1 的编码方式输出, 
    #=> 所以打开 transcoded.txt 文件时看到内容是有问题的
    open("transcoded.txt", "w:ISO-8859-1") do |io|
      io.write(string)
    end

    puts "raw text:"
    p File.binread("transcoded.txt")
    puts

    # 以 ISO-8859-1 的编码方式读取数据,并转换成 UTF-8 的编码方式.
    open("transcoded.txt", "r:ISO-8859-1:UTF-8") do |io|
      puts "transcoded text:"
      p io.read
    end

### 总结  ###

1. 在没有设置的情况下 IO Object 的 external encoding 被设置为 Encoding::default_external 的值, 而默认 Encoding::default_external 又是由 Locale encoding 决定.
2. 可以通过 ruby -E ;或者在代码中使用 Encoding.default_external = "UTF-8" 进行修改; 或者在创建 IO Object 的时候,可以手动指定 external encoding.
4. internal encoding 的值是可选的, 在没有手动设置的情况下 IO Object 的 internal encoding 被设置为 Encoding::default_internal 的值, 如果 Encoding::default_internal 为 nil, internal encoding 也为 nil.
5. 同样 Encoding::default_internal 设置的方式与 Encoding::default_external 类似.

6. IO 读写时,对编码的处理(重点).
 1. 简单的说, IO 操作读操作时: 会以 IO 对象的 external encoding 的编码方式读取数据,然后转换成 IO 对象的 internal encoding. 如果 internal encoding 为 nil, 不作转化.
 2. IO 写操作时, 会把数据从 IO 对象的 internal encoding 编码方式转化成 external encoding 方式. 如果 internal encoding 为 nil ,不作转化.
 3. IO 对象的 internal encdoing 跟 enternal encoding 就是决定的 IO 对象以什么样的编码方式去处理字符串的编码.而并不在乎字符串的实际编码. 也可以这样说 Ruby IO 对字符串用什么样的编码方式去处理并不是根本字符串的实际编码方式来处理的,而是以 IO 对象的 internal encoding 跟 enternal encoding 值来进行处理, 就算事实上你的字符串实际编码是 "UTF-8", 当你指定 IO 对象的 internal encoding 是 "ISO-8859-1", 那么IO 对象就也将处理的字符串当成 "ISO-8859-1" 来处理.
 
现在知道为什么会报错了, 因为当时的需要处理的文件是 UTF-8 的编码方式, ruby 脚本也是 UTF-8 编码方式, 但是当时在一台 windows 机器上, Encoding::default_external 根本 local encoding 被设置成 GBK, 而在读取文件的时候并没有指定, IO 对象的 external encoding值, 所以读取的文件内容被当成 GBK, 编码方式, 传给 split 方法的参数却是 utf-8, 所以会出错.
 
 
### 参考 ###
http://ruby-doc.org/core-2.1.4/Encoding.html  
http://www.mojidong.com/ruby/2013/05/18/ruby-encoding/  
http://www.jianshu.com/p/90475f44cc95
