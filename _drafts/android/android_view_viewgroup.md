View 占据屏幕上的显示区域,负责绘制跟事件处理. View 是 Widget 的基础类. (Widget 用于创建UI组件)
ViewGroup 是 View 的一个子类. 是布局的基础类. 担当一个 hold 其他的 View 跟 ViewGroup 设置布局的任务.


创建一个View Tree 之后,有些基本的操作需要处理
Set properties
Set focus
Set up listeners
Set visibility

实现自定义的View
实现自定义的VIew并不需要重写所有的方法,可以只从重写onDraw()方法开始

creation 

layout

Drawing

Event process

Focus

Attaching

Position
得到相对于Parent View 的位置
getLeft()
getTop()
getRight() 相当于 getLeft() + getWidth()
getBottom() = 


Size, padding and margins
size通过width 跟 height 体现出来, 实际上 View 有两对 width 跟 height
一对measured width 跟 measured height(测量高度,宽度),它定义希望在parent中显示的大小.它的值可以通过getMeasuredWidth() and getMeasuredHeight()来得到
第二对就是通常意义上说的 (drawing)width 跟 (drawing)height. 它定义在屏幕上显示的实际大小.
它的值有可能但不一定跟 measured 值不相同

measured dimensoins 考虑到的 view 的 padding. padding 表现为 view 的四周边缘的距离.

View提供了 padding 但是没有提供 margins . ViewGroup 提供了 margins

Layout
Layout 是一个双向的处理过程. 一个是:measure pass(测量过程) 跟 layout pass(布局过程)
measure pass 通过 measure(int, int)方法来实现.按照 view tree 从上到下的过程. measure 过程完成之后, 每个view都保存自己的 measure dimension
layout pass 通过 layout(int, int, int, int) 实现,也是自上到下的过程. 过程中每一个 parent view 通过 measure pass 得到的 measure dimension 值定位所有 children view 的位置

Drawing
View tree 在绘制的时候按顺序进行的. parent view 在 children view 之前绘制. siblings 按顺序绘制. 
如果view有设置backgroud drawable, background drawable 先绘制. 
child view 绘制顺序可以通重写 ViewGroup 的绘制顺序 跟 setZ 值来改变.

Event Handling and Threading
View 的事件处理基本过程
事件开始,被派发到相应的 view. view 处理事件,并通知所有的监听器
如果在处理事件的过程中, View的边界可能需要改变,view 会调用 requestLayout() 方法
同样如果, view 的外观发生改变,调用 invalidate()方法 
如果 requestLayout 跟 invalidate 方法被调用, 会重新测量,布局,绘制.

Focus Handling
用户输入进程中处理焦点移动过程.
view 通过 isFocusable()  来判断是否能够得到焦点
通过 setFocusable() 来改变 view 是否能得到焦点. touch mode view 通过  isFocusableInTouchMode() 判断是能够得到焦点. 通过 setFocusableInTouchMode(boolean). 来改变焦点
焦点移动是基于给定方向最近的view来计算的.只有极少数的情况下默认的算法不符合开发者的预期.
这种情况下可通过 nextFocusDown nextFocusLeft nextFocusRight nextFocusUp 来设计
通过 requestFocus() 来得到焦点

Touch Mode
对于非触摸的设备,显示焦点是非常有必要的(想想在老式的诺基亚上浏览网页的时候),对于touch设置来说一直高亮是没有必要的.
在Touch mode 的时候只有 isFocusableInTouchMode() 为true的时候才会获取焦点.比如像 TextEdie 这样的view
像button并不会获取焦点
如果设置跟... 会退出Touch模式.

Scrolling
对view内部内容滚动提供了基本支持

Tags

Properties

Animation

Security


Custom View

继承或View或者View子类
定义一个Custom Attribute
	在<declare-styleable></declare-styleable>资源文件中定义View的属性
	在 layout 布局文件中指定属性值
	运行时从 layout 布局文件中读取属性值
	将读取的属性值应用到View上
	
	如果View是在XML中定义,在创建View的时候属性值会收集在一个AttributeSet对象中
	虽然说可以从AttributeSet中直接读取属性值,但是这样做会有些缺点.
	1.属性值中的资源引用没有解释
	2.样式没有被应用
	所以,会把AttributeSet传给obtainStyledAttributes方法.返回这个TypedArray
	需要注意的是 TypedArray 是共享资源,使用后必需 recycled 

添加属性跟事件
	XML中提供的Attribute只能够在初始化的时候读取使用.为了提供动态行为(读取,改变Attribute).需要给每一个属性提供get set 方法
	
	set 方法中调用了invalidate() and requestLayout().两个方法. 
	如果属性的改变会改变View的呈现,那么应该调用 invalidate 方法.
	如果属性的改变会改变View的布局,应该调用 requestLayout 方法
	
	

创建 custom View 
重写 onDraw() 方法
最重要的是重写 onDraw(Canvas) 方法, Canvas 对象可以用来绘制View(text, lines, bitmaps, 等一些基本图形)
在调用绘图的方法之前,可以创建 Paint 对象.

创建Drawing对象
android.graphics 画图分为两方面.
画什么,由Canvas处理
怎么画,由Paint处理
比如说 Canvas 提供了画线的方法, Paint 提供了设置线颜色的方法.

提前创建绘图对象是很重要的,因为View重绘会非常的频繁,创建一些绘图对象是十分消耗资源的.如果在 onDraw() 方法中创建绘图对象可能会导致UI出现呆滞的情况

处理 Layout 事件
为了正确绘制自定义View.必须要知道它的Size大小.复杂的自定义View通常需要根据View在屏幕上的Size 跟 形状来计算布局/
你不应该假设你的View在屏幕上的大小.即使只有一个APP使用你的View,但是你的App需要处理在不同的屏幕大小,像素密度,屏幕比例.

虽然说View有多个方法可以处理测量.多数情况下需要重写.如果你认为并不需要特别控制它的大小,你只需要重写 onSizeChanged 方法

onSizeChanged 只是第一次分配大小跟大小发生变化的时候调用.在onSizeChanged中计算View的大小,位置,和其他的相关的值

如果想要控制View的布局参数.需要实现, onMeasure(View.MeasureSpec) 方法. View.MeasureSpec 值告诉你View的父类View希望View的大小是多少,是最大值,或者建议的值.

View.MeasureSpce 父类布局对子类布局的影响.
UNSPECIFIED 父类并不对子类进行约束,可以是任何大小
EXACTLY 父类决定子类的确切大小,不管子类自己的大小是多少.
AT_MOST 子类可以是它期望的任意大小

每一个View 的 onDraw 方法实现都不同,但是有些一通用的操作
使用drawText()绘制文本.使用setTypeface()指定字体,setColor()指定字体颜色
使用drawRect(), drawOval(), drawArc() 绘制基本形状.使用setStyle()填充跟指定开关边框的颜色
使用Path绘制其他复杂的形状.
使用 LinearGradient 进行渐变填充,使用setShader()设置渐变填充
使用drawBitmap()绘制bitMap


View 优化
消除频繁调用不必要的代码
避免在 onDraw 方法中分配对象.因为分配对象时可能会导致垃圾回收器的调用
尽可能少的调用 onDraw 方法
多数情况下调用 invalidate() 方法的结果都会调用 onDraw() 方法,所以尽里少调用 invalidate() 方法
每次调用 requestLayout(), Android UI 都会遍历整个View Tree 去找出每个View应该的大小.如果发现有冲突的测量还需要多个遍历

UI 设计师有时为了得到想要的布局会对UI进行深层次的嵌套,这些深层次的嵌套会影响性能.

如果有一个复杂的UI需要编写自定义的ViewGroup来处理布局.而对于它的子view假定知道它们的大小,那不需要去测量它们,直接根据自己自定义布局算法设置他们的大小






