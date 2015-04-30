app 通常都会有多个 Activity. 每一个 Activity 为某种特定的操作来设置. 
比如一个 email app, 可能有一个 Activity 用来显示邮件列表, 选择一个邮件打开一个新的 Activity 来显示邮件内容.

一个 activity 也可以启动其他 app 中的 Activity , 比如你可以在你的 app 中调用发送 email app 发送 email, 或者调用短信 app 发送信息
这些 activity 不属于你的 app, 但看起来就像在你的 app 中一样. Android 将这些Activity 放在同一个 task 中来提供这种无逢的体验.

task: 是用户处理某一工作的 Activity 的集合. 这些 Activity 被放置在一个 stack 中.
1. Collection of activities
2. Organized in stack 
3. Task have at least on activity
4. new activities placed on top, LIFO Queue
5. Each task has a "name" call Affinity




http://www.slideshare.net/RanNachmany/manipulating-android-tasks-and-back-stack
http://stackoverflow.com/questions/18611543/android-task-and-process-singletask-and-singleinstance
