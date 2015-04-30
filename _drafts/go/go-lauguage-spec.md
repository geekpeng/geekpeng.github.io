
Go
go 语言是一种通用的系统设计语言. 强类型,垃圾自动回收.并发支持.通过 paceage 来组成代码结构.

###Source code repressentaion###
Go 的源码是UTF-8的Unicode文本, 例如,使用 

###Lexical elements###
####Comments####
// 单选注释
/* 多行注释
注释不能嵌套使用

####Tokens####
identifiers, keywords, operators and delimiters, literals.
空白符(whiter space),空格(U=0020), 水平制表符(U+009),回车(U+000D),换行(U+000A),被忽略,除非,
换行或者文件结束,可能会插入一个分号(semicolon).

####Semicolons####
下面两种情况可以省略 ';'
1) 这些情况下在非空白行的最后出现下列 token 自动插入分号.
1, identifier, 
2, integer, floating-point, imaginary, rune, string literal
3, 出现 beark, continue, fallthrough, return
4, 出现下面的操作符 ++, --, ), ], }
2) 一行复杂的语句,)或}之前的 ; 号的可省略

####Identifiers####
go 语言的 Identifiers 只能是字母跟数字或者下划线,并且只能以字母或者下划线开头.
一些 Identifiers 是预留的,这些 identifiers 在 universe block 声明
Types:
bool byte complex64 complex128 error float32 float64
	int int8 int16 int32 int64 rune string
	uint uint8 uint16 uint32 uint64 uintpt
Constants:
true false iota

Zero value:
nil

Functions:
append cap close complex copy delete imag len
	make new panic print println real recover
	
####Keywords####	
这些关键字不能用作identifiers
break        default      func         interface    select
case         defer        go           map          struct
chan         else         goto         package      switch
const        fallthrough  if           range        type
continue     for          import       return       var

#### Integer literal ####
Integer literal 有三种,十六进制(0X,0x),十进制(1...9),八进制(0).

#### Floating-ponit literals ####

#### Imaginary literals ####
在 Integer literal 或者是 Floating-point literals 后面加一个 'i'

#### Rune literal ####
Rune literal 单引号引用的一个或者多个字符.在单引号中可以出现除了单引号跟换行之外的所有字符.如果要出现单引号必须转义.
go 语言中的 Rune literal 类型以java语言中的 char 类型

#### String literals ####
"" 或者 ``, 其中 `` 引用的字符串可以换行


#### Constants ####
boolean , rune, integer, float-ponit, complex, string. (Rune, integer, float-point, complex)统称number 类型.

#### Variables ####

#### Type ####

#### Boolean type ####

#### Numerice types ####
uint8, uint16, uint32, uint64, 
int8, int16, int32, int64, 
float32, float64
complex64, complex128
byte alias for uint8
rune alias for int32

uint (32 or 64 bits)
int(32 or 64 bits)
uintptr 足够大的无符号integer类型,

为了避免移植的问题,所有的不同Numerice类型在运算时都需要进行转换.byte 跟 uint8 ,rune 跟 int32 不需要进行转换.int32 跟 int也不是同一种类型,虽然有可能他们的size是一样的.

#### String types ####
String value 是一个 bytes 序列.字符串是不可变的,一旦创建字符串的内容不可改变.

#### Array types ####
Slice 跟 Array 关系, 内存模型

#### Slice types ####
Slice 跟 Array 不同的是的 Slice 的长度是可变的.
Slice 一初始化,总是使用一个潜在的 Array 来保存元素.因为一个 Slice 是可以跟另一个 Slice 共用存储的如果他们使用了同一个 Array,但是不同的 Array 总是使用不同的存储.

Slice 的 Array 是可以扩展的. capacity 意味着: slice 长度的总和,跟属于这个Slice的Array的长度的总和.
Slice 的长度决定于
Slice 的 capacity 可以通过 cap(a) 来覆盖.


#### Struct types ####
Struct 中显式,隐式 Field 使用跟区别
Struct 是字段(Field)的序列.字段都有一个name跟type, 每个Field的名字可以是显式的也可以匿名的.

#### Pointer types ####

#### Function types ####

#### Interface types ####
Interface 是一个特别的方法的集合. 实现了 interface, 没有初始化的 interface 类型是 nil

Interface 使用是一个重点

#### map ####

#### Channel typs ####
并发编程相关


#### Properties of types and values ####

##### Type identity #####
类型比较.
如果两类型的类型名在同一个TypeSpace中,
命名的类型跟非命名的类型总是一个不同的类型.
两个非命名的类型是相同的,如果它们相应的字面值是一样的.































