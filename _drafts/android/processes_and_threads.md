android 程序启动的时候如果这个程序没有其他正在运行的组件,andorid 系统会启动一个新的进程(process),在新进程中单独启动一个线程执行程序.默认情况下,同一个程序的所有组件在同一个进程的同一个线程(main thread)中运行.
反过来,如果程序组件启动的时候已经存在这个程序的其他组件正在运行,那么这个组件会跟其他组件在同一个进程的线程下运行.
然而,你也可以指定不同在组件在不同的进程中运行.为每一个进程创建额外的线程.

默认情况下,同一个application的所有 components 在同一个 process 中运行,而且大多数的 application 不需要去改变它. 如果你觉得你有必要必须控制某个 component 在其他 process 运行时,可以通过修改 mainfest file 要实现.

mainfest file 每个组件元素(<activity>,<service>,<receiver>,<provider>)都支持通过 android:process 属性来指定一个特定进程来运行 component

andorid 在内存过低情况下,如果用户请求执行一个即时的操作(immediately serving),可以直接中止一个process(运行在这个 process 中的 components 也会被killed).
android 系统通过衡量 process 对进户的重要程序(importance) 来决定哪个进程被 killed .比如说, 保持(hosting activities that are no longer visible on screen)了一个当前对用户不可以见的 Activity 的进程更容易被中止掉. 是否中止一个进程取决于一这个进程中组件的状态

####Process 生命周期 ####
android 系统尽可能长的维护一个 process . 但是需中止掉旧的 process 来释放内存(reclaim memory), 为新的 process 或者更重要的 process 来提供资源. 系统根据运行在 process 中的 component 跟 组件的状态(component state)来标识进程的重要程度.

process 的 5 种级别

Foreground process 
用户正在处理中的 process , 在下面任何条件成立的情况下
1. 保持了一个正在跟用户交互的 Activity (Activity 的 onResume() method 调用))
2. 保持了一个跟正在与用户交互的 Activity 绑定的 service
3. 保持了一个正在前台运行的 serivce (调用了 startForeground() 方法)
4. 保持了一个正在调用生命同期回调方法的 service (onCreate(), onStart(), or onDestroy()).
5. 保持了一个正在执行 onReceive() 方法的 BroadcastReceiver
通常中会有少量的前台进程(foreground processes)在运行.kill 掉 poreground process 只是作为最后的手段,也就是只有在万不得已的情况下(内存过低,导致foreground process 也无法继续运行,通常是在内存达到 paging state 的时候)才会去 kill foreground process. 

Visible process
一个进程不包含任何的前台组件,但仍会对用户屏幕有影响的进程. 包含一面这些情况
1. 保持了一个 Activity , 这个 Activity 虽然不是在前台,但是仍然对用户来说是可见的. ( onPause() 被调用,比如说被一个对话框遮挡了)
2. 保持了跟一个 visible Activity 绑定的 service

Service process
一个进程中正在运行一个服务,调用了 startService 方法,但是这一个进程还没有被标识为更高的级别(也是说还没有被樯为 visible process 跟 foreground process 这两种级别).虽然 serivce process 不直接被用户所看见,但是他所做的事是用户关心的,比如在后台播放音乐,在后台下载,因为系统会让维护它们运行的状态,除非没有足够的内存提供给 Visible process 跟 foreground process

Background process
一个进程保存了对用记不可见的 Activity (onStop() 方法被调用)这些进程对用户体验没有直接的影响.系统可以在任何时候kill掉它们回收内存为 foreground , visible, service process 提供资源.通常会有很多的 background process 所以它们被放在一个LRU(least recently used 最近使用) list中为了确保最近运行的最后被kill掉.如果Activity 实现了生命同期的回调方法,并保存了当前的状态值, kill 它的进程对用户来说不会产生任何的影响.因为在 Activity 恢复可状态时会恢复所有的值.

Empty process
一个进程没有保持任何活动的组件,保留这种 process 的唯一目的是为了缓存. 为了提高组件的下一次启动时间.系统通常是在为了平衡系统缓存资源跟内核缓存资源时kill掉这些 process

android 系统会通过进程中重要级别最高的组件来作为进程的标识,比如说一个进程中有一个 services 跟一个 visible activity , 进程会被提升为一个 visible process 而不是 service process

android 的process会因为另他 process 依赖这个 process 而提供排名 -- 一个 process A 为另一个 process B 服务, process A 的级别永远不会低于 process B. 

因为一个正在运行一个 service 的 process 的排名会比一个处于后台的 activity 的 process 的级别要高. 所以一个activity 要启动一个长时间的操作相对于启用一个工作线程(worked thred)的来说最好是为这个操作启用一个service . 比如说 上传一个文件到 web 服务器上,最好是调用一个 service 来进程操作,这样即使你离开了 Activity 也会继续上传.


###Threads###
当程序启动后,系统创建一个main线程来执行程序,main 线程非常重要,分发所有改变用户界面部件的事件.包含绘画事件.所以说通常这个线程跟程序的 UI toolkit(android.widget 跟 android.view 包下的组件) 组件进程交互.所以main 线程通常也叫 UI 线程.
系统不会给每种组件的实例创建特别的线程.每种组件都在同一个进程的同一个 UI 线程的实例中运行.系统调用每一个组件都是通过 UI 线程分发的, 所以显示系统回调的方法通过在也这个进程的 UI 线程中.
例如.当用户触动(touch)一个按钮的时候,程序的UI 线程分线触动事件到这个部件(widget)上.部件设置它的按下状态(pressed state)发送一个无效的请求到事件队列(event queue), UI 线程从事件队列中取出请求,通过widget 重绘自己.
当程序处理密集的用户交响应的时候,单线程模式可能产生性能问题.需要特别说明,如果所有操作都在UI线程中执行(网络连接,操作数据组...)耗时的操作就会阻塞整个UI.

另外,android 的 UI toolkit 不是线程安全的. 所以一定不能在工作线程(worked thread, 也就是非 UI 线程,非 main 线程)中对UI进程操作.
对 android 的单线程模式来说有两个原则:
1. 不要阻塞UI线程
2. 不要在非 UI 线程中做更新UI的操作.

####worker threads####
基于android的这种单线程模式, 应该确保所有的非瞬时的操作都应该在其他的线程中进行("background" 跟 "worker" thread)

    //这种代码是不提倡的,加载图片是一个耗时的网络操作,会阻塞UI
    public void onClick(View v) {
        Bitmap b = loadImageFromNetwork("http://example.com/image.png");//加载图片
        mImageView.setImageBitmap(b);//更新ui
    }

    //这种代码不提倡,虽然将网络操作放在一个worker thread 中,但是在worker thread 中有更新ui的操作
    //
    public void onClick(View v) {
        new Thread(new Runnable() {
            public void run() {
                Bitmap b = loadImageFromNetwork("http://example.com/image.png");
                mImageView.setImageBitmap(b);
            }
        }).start();
    }
    
为了解决这种问题,android提供了几种方法.
1. Activity.runOnUiThread(Runnable)
2. View.post(Runnable)
3. View.postDelayed(Runnable, long)

    public void onClick(View v) {
        new Thread(new Runnable() {
            public void run() {
                final Bitmap bitmap = loadImageFromNetwork("http://example.com/image.png");
                mImageView.post(new Runnable() {
                    public void run() {
                        mImageView.setImageBitmap(bitmap);
                    }
                });
            }
        }).start();
    }
    
然而上面的代码过于的复杂. 更好的解决这种问题可以在worker thread 中使用 Handler 来处理来自UI线程的消息, AsyncTask 是Handler方式的一处简化方案. 使用AsyncTask 的时候必须实现 doInBackground() 方法来处理长时间操作,onPostExecute() 方法来更新UI

    public void onClick(View v) {
        new DownloadImageTask().execute("http://example.com/image.png");
    }

    private class DownloadImageTask extends AsyncTask<String, Void, Bitmap> {
        /** The system calls this to perform work in a worker thread and
          * delivers it the parameters given to AsyncTask.execute() */
        protected Bitmap doInBackground(String... urls) {
            return loadImageFromNetwork(urls[0]);
        }
        
        /** The system calls this to perform work in the UI thread and delivers
          * the result from doInBackground() */
        protected void onPostExecute(Bitmap result) {
            mImageView.setImageBitmap(result);
        }
    }



















