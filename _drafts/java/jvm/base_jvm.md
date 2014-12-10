JVM 基础
#### class 文件 ####
java 源代码被编译成可以让 JVM 执行的与平台无关的二进制文件
#### 数据类型 ####
跟 java 语言一样, JVM 操作的数据也有两种类型: 原始类型(primitive type)跟引用类型(reference type),跟数据类型对应值也有两种 primitive value 跟 reference type 

JVM 几乎所有的类型检查在运行之前由编译器完成,而不是 JVM 去完成. 原始数据类型的值不需要通过特殊的标记或者其他的额外的手段来确定它的实际类型,也不需要将原始类型的值跟引用类型的值区分开来.虚拟机字节码指令本身就可以确定操作数据的类型是什么.(比如说: iadd, ladd, fadd, dadd 这些指令用来处理对应的数据类型的操作,依次是 int, long, float, double)

JVM 直接支持对象的,虚拟机器使用 reference type 来表示某个对象的引用, reference type 的值可以看作指向对象的指针. 多个 reference type 可以指向同一个对象, 对象的操作 传递 检查 都是通过 reference type 的值来完成的.

#### 基本数据类型 ####
JVM 支持的基本数据类型, 
numerice type{
	integral type(
		type,
		short,
		int,
		long,
		char
	},
	floating-point{
		float,
		double
	}
},
boolean type, 
returnAddress type(returnAddress type 是指向 JVM 操作指令的操作码, 在所有的原始操作类型中只有 returnAddress type 不能跟 java 数据类型对应上).


