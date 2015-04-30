---
layout: post
title:  "character encoding, code points vs code unit"
category: other
tags: [code points, code unit]
keywords: code points,code unit, unicode, character encoding
description: code unit,code points, character encoding
---
其实对于编码一种很通俗的解释,比如说,你点头也是一种编码,用点头来表示"是的"意思.

摩斯电码,布莱叶盲文都是一种编码的方式.

字符编码(character encoding),是通过某种编码系统用来表示字符集.
依据抽象级别跟内容的不同,相应的代码点(code point)组成代码空间(code space)结果可以用位模式(bit patterns),八位模式(octets),自然数(natural numbers),电脉冲(electrical pulses)...表示

比如说我现在要 'C' 这个字符进行编码,通过16进制,10进制,2进制,...等形式表示出来
(ps. 我只是说我要对 'C' 字符进行编码,这只是说一个例子,并不是按照 ASCII 编码跟或者其他已经存在的编码方式来进行编码)

| char | dec | hex| bit |
| ----- | ----- | ---- | ---- |
| 'C' | 11 | B | 1011 |
| 'D' | 12 | C | 1100 |
| 'E' | 13 | D | 1101 |
| 'F' | 14 | E | 1110 |
| 'E' | 15 | F | 1111 |
| 'G' | 16 | 10 | 00010000 |

好了,上面的这种将字符'C'对应到十进制的11,十六进制的B,二进制1011的过程就叫编码了.
我们把一个种编码方式叫做XXX编码.'C','D'...'G'构成了字符集,与它对应的编码叫做**代码点**,每个点代码都会有一个数值与他对应,这个数值叫做代码点的**标量值**.这些代码点的标量是有范围的(11~16)/(B~10).这些代码点所在范围构成了**代码空间**.'G'明明是可是用10000来表示的吧,为什么使用了 00010000 来表示呢,我们就是假设用4位的二进制来表示,但是4位的二进制已经不够用了,那我们就用二个4位(8位)的二进制来表示它.

有了一个例子再来理解 **code unit**, **code points**, **code space** 这些概念就很容易了.

code unit,code points,code space 之间的关系:

**可以描述为,一个 code points 由一个或者多个 code unit 来表示, code unit 是构成 code points 的单元, code 
space 是一个抽象的概念. 类似一个集合,包含了所有的 code points.**

#####code points#####
每一个"code point"有一个特定的数值.称为标量值(scalar value). 通常用 16 进制来表示.通常来说一个 code points 代表一个字符.一个code points 由一个或者多个 code unit 构成.

#####code unit#####
编码单元(code unit), 用来表示编码字符的比特序列. 比如说 US-ASCII, 的code unit 是 7 个 bit, 7个bit构成 code unit


比如说 ASCII 编码:  
ASCII 每个 code unit 有 7 个 bit位,每个 code points由一个 code unit 构成, 所以它有 code points 只是 128 个,每个code points 都有一个标量值, code space 由(0hex 到 7fhex).

而Unicode编码:  
**UTF-8**, code unit 是 8 个bit, 而 code points 对应的code units 是可变的,有些对应 1 个 code units, 有些对应 2 个 code unit, 有些对应 3 个code unit,有些对应4个code unit.这样做是为了节省空间.

**UTF-16**, code unit 是 16 个bit, code points 标量值在 U+10000 以下的,一个code 对应一个代码单元；U+10000 以上的一个代码点对应2个代码单元.

**UTF-32**, code unit 是 32 个bit, code points 对应一个code unit,因为其一个code unit为32个bit位,有足够的空间来表示任意的code points.

###参考:###
http://en.wikipedia.org/wiki/Character_encoding  
http://msdn.microsoft.com/en-us/library/ms225454(v=vs.80).aspx  
https://www.altamiracorp.com/blog/employee-posts/unicode-code-points-vs-code  





