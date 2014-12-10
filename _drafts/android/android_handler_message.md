###android handler###
Handler 可以让你发送,处理Message并将Runnable对象与线程的消息队列进行关联.
每一个 Handler 实例与一个线程和这个线程消息队列的进行关联.
创建一个handler的时候,handler跟所处的线程(Thread)和这个线程的消息队列(message queue)进行关联.
Handler 发消息(messages)跟runnables到消息队列,并从消息队列中获取消息并执行.

Handler 两个主要的使用场景:
1, 在未来的某个时间点 调度 messages 和执行 runnables 
2, 将 action 放入到队列中并在另一个线程中执行

调度消息可以通过  
post(Runnable), 
postAtTime(Runnable, long), 
postDelayed(Runnable, long), 
sendEmptyMessage(int), 
sendMessage(Message), 
sendMessageAtTime(Message, long),
sendMessageDelayed(Message, long) 这些方法来完成.
post 方法可以将 Runnable 对象放入队列,在 message queue 接收到 runnables 的时候执行.
sendMessage 方法可以将一个 message 对象跟数据绑定放入队列,消息会被Handler的handlerMessage方法处理.

无论是使用 post 或者是 sendMessage 方法都可以让它们(runnables, messages)尽快或者延迟处理.

当应用程序的进程一创建后,main thread 就专注于负责维护消息队列(running a message queue),
管理程序的顶级对象(activities, broadcast ...).你可以创建自己的线程,通过Handler来与主线程通信(通过post,或者是sendMessage方法).
但是,main Thread 接收到的 messages 跟 runnables 会被调度到 Handler 的消息队列,并执行.



http://mindtherobot.com/blog/159/android-guts-intro-to-loopers-and-handlers/
http://stackoverflow.com/questions/14601730/how-handler-classes-work-in-android
http://stackoverflow.com/questions/5193913/handlers-messagequeue-looper-do-they-all-run-on-the-ui-thread/5193981#5193981

