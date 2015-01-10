
Go
go 语言是一种通用的系统设计语言. 强类型,垃圾自动回收.并发支持.通过 paceage 来组成代码结构.

Source code repressentaion
Go 的源码是UTF-8的Unicode文本, 例如,使用 

Lexical elements
Comments
// 单选注释
/* 多行注释
注释不能嵌套使用

Tokens
identifiers, keywords, operators, delimiters, literals.
空白符(whiter space),空格(U=0020), 水平制表符(U+009),回车(U+000D),换行(U+000A),被忽略,同时,换行或者文件结束,可能会引入插入一个分号(semicolon).

Semicolons
下面两种情况可以省略 ';'
在非空白行的最后自动插入分号.

Constants:
boolean , rune, integer, float-ponit, complex, string. (Rune, integer, float-point, complex)统称number 类型.

