###android search###

####创建search界面####
android 已经提供了两种用户搜索交到的界面:search dialog 跟 search widget
search dialog 跟 search widget 的一区别:
search dialog 是一种UI组件完全受android系统的控制.search dialog被用户激活后会在Activity的顶部.
android系统控制所有事件.
search widget 是 SearchView 的实例,可以在任何地方添加. 默认 search widget 就像 TextEdit 一样,不会处理任何事件
用户需要自己去处理事件.

用户从 search dialog 跟 search widget 执行搜索的时候,系统创建 Intent 储存用户查询信息. 
系统启动定义了处理搜索的 Activity , 为了支持处理搜索, 你需要做以下的事情:
1. 配置 searchable
 一个XMl的配置
2. searchable Activity
 接收搜索请求,执行搜索显示搜索结果.
3. search interface(search dialog / search widget)

#####创建search configuration #####
res/xml 目录中创建searchable.xml 控制 search dialog 或者 search widget
#####定义searchable activity#####
定义<intent-filter> 接收 ACTION_SEARCH Intent
定义 meta-data 指定 search configuration 文件

    <intent-filter>
        <action android:name="android.intent.action.SEARCH" />
    </intent-filter>
    <meta-data android:name="android.app.searchable" android:resource="@xml/searchable"/>
#####处理搜索#####
1. 接收query
2. 搜索数据
3. 显示结果
    

