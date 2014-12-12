###android search###

#### Search Interface ####

android 已经提供了两种用户搜索交到的界面:search dialog 跟 search widget
search dialog 跟 search widget 的一区别:
search dialog 是一种UI组件完全受android系统的控制.search dialog被用户激活后会在Activity的顶部.
android系统控制所有事件.
search widget 是 SearchView 的实例,可以在任何地方添加. 默认 search widget 就像 TextEdit 一样,不会处理任何事件
用户需要自己去处理事件.

用户从 search dialog 跟 search widget 执行搜索的时候,系统创建 Intent 储存用户查询信息. 
系统启动定义了处理搜索的 Activity , 为了支持处理搜索, 你需要做以下的事情:
1. 配置 searchable 一个XMl的配置
2. searchable Activity 接收搜索请求,执行搜索显示搜索结果.
3. search interface(search dialog / search widget) 

##### 创建 searchable #####

res/xml 目录中创建searchable.xml , searchable.xml 主要是对定义搜索的一些特性的,
比如 默认点位符. 是否提供搜索建议 ... 

##### 创建searchable activity#####

searchable activiry 接收搜索请求, 搜索数据, 并显示结果.
在添加 intent-filter, 这样才能接收到搜索请求
<activity>
    <intent-filter>
        <action android:name="android.intent.action.SEARCH" />
    </intent-filter>
</activiry>

配置 meta-data 指定 searchable 的配置文件
<activity>
    <intent-filter>
        <action android:name="android.intent.action.SEARCH" />
    </intent-filter>
    <meta-data android:name="android.app.searchable" android:resource="@xml/searchable"/>
</activiry>



#####处理搜索#####
1. 接收query
2. 搜索数据
3. 显示结果

widget search for android 3.0...

#### Searchable Activiry ####
接收搜索请求, 搜索数据并显示结果
#### 搜索配置文件 ####
1. searchable.xml
2. menu_xxx.xml
3. androidManifest.xml 指定支持搜索的 Activiry 的 meta-data
4. androidManifest.xml 指定处理搜索的 Activiry 的 intent-filter
    

