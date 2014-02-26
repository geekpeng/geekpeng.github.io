---
layout: post
title:  "stackoverflow上java关于paresInt跟valueof的问题"
category: java
tags: java
keywords: java,Integer缓存,Integer.passInt(),Integer.valueOf(),auto-box,int跟Integer转换
description: 因为IntegerCahche的存在导致java.paresInt()跟java.ValueOf()转换后比较的区别,java的自己装箱跟拆箱
---
Stackoverflow 上关于parseInt 跟 valueOf 的问题  

	System.out.println(Integer.valueOf("127")==Integer.valueOf("127")); // output is true
	System.out.println(Integer.valueOf("128")==Integer.valueOf("128")); // output is false
	System.out.println(Integer.parseInt("128")==Integer.valueOf("128")); // output is true

为什么第二条语句输出的是 ture, 第二个输入 false ? 这两个的不同就在于第一个的值是 127 第二个的值是 128， 而第三个输出的是true  

咋一看可能觉得这个问题很简单，但是里内可能隐藏的东西可能很多。  

- Integer.valueOf(),跟Integer.parseInt()
- java 的 IntegerCache 在对 Integer 对象的处理
- auto-unbox

Integer.valueOf() 返回的是一个 Integer 对象， Integer.parseInt() 返回原始数据类型 int 值。
值得注意的是 valueOf() 先会将 String 类型的数字先转换成原始的 int 类型值再转成Integer对象，
valueOf(),跟 parseInt() 调用同一个方法将 String 转换成 int 数值。(这么也就是 valueOf() 之前会有一个 parseInt() 的操作 虽然不是直接调用 paseInt() 方法)  

看一下 valueOf() 最终的调用：

	public static Integer valueOf(String s) throws NumberFormatException {
		return Integer.valueOf(parseInt(s, 10));
    }
	
    public static Integer valueOf(int i) {
        if(i >= -128 && i <= IntegerCache.high)
            return IntegerCache.cache[i + 128];
        else
            return new Integer(i);
    }
	
parseInt() 方法：  

	public static int parseInt(String s) throws NumberFormatException {
		return parseInt(s,10);
    }
	

IntegerCache 是 Integer 的一个内部类：  
	
	private static class IntegerCache {
        static final int high;
        static final Integer cache[];

        static {
            final int low = -128;

            // high value may be configured by property
            int h = 127;
            if (integerCacheHighPropValue != null) {
                // Use Long.decode here to avoid invoking methods that
                // require Integer's autoboxing cache to be initialized
                int i = Long.decode(integerCacheHighPropValue).intValue();
                i = Math.max(i, 127);
                // Maximum array size is Integer.MAX_VALUE
                h = Math.min(i, Integer.MAX_VALUE - -low);
            }
            high = h;

            cache = new Integer[(high - low) + 1];
            int j = low;
            for(int k = 0; k < cache.length; k++)
                cache[k] = new Integer(j++);
        }

        private IntegerCache() {}
    }
	
如果值在 -128 跟 IntegerCache.hight 也就是 127 之间，valueOf 返回的是 缓存中的对象  

所以语句： 
 
	Integer.valueOf("127")==Integer.valueOf("127"));
实际上是通过 == 来比较的同一个对象。   

	Integer.valueOf("128") == Integer.valueOf("128");  
int 128 的封装类型 Integer 对象并不在 IntegerCache 的缓存范围内，
这样在使用valueOf()方法时创建了两个不一样的对象，所以使用 == 比较返回的是一个 false  

	Integer.parseInt("128")==Integer.valueOf("128")
为什么 Integer.parseInt("128")==Integer.valueOf("128") 也返回 true 呢。左边是一个原始数据类型 int 值，而右边是一个封装类型，java会自动拆箱(auto-unbox),比较的是两个原始的 int 值，所以返回 true  

另外：有一点直接 new 的 Integer 对象不会有缓存，使用 new 创建的是两个不同的对象。




	







	
