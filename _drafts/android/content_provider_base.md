###Content Providers###

Content Provider 管理对数据的访问.对数据进行封装,提供安全机制. 
Content Provider 是一个进程访问另一个进程数据的标准接口.
使用 ContentResolver 对象当做一个客户端与 Content Provider 进行通信 . 
provider object 接收从客户端发送的数据, 处理请求, 返回结果.
你可能需要开发 Provider 为自己的程序提供数据查询等操作. 
如果你的数据不需要提供给其他程序访问, 开发的 provider 不需要去实现与其他程序分享数据的功能.

andorid 自身提供了一些 content provider 去管理 视频,音乐图片等数据. android.provider 可以看到提供的 content provider

provider 是程序的一部分,通常 provider 给自己的 UI 提供数据, Content Porvider 给其他程序提供数据访问.
content provider 通过 provider client object 访问 provider 提供的数据. 
provider 跟 provider client 提供了一致的接口来处理进程间通信各安全的数据访问.

content provider 以类似于关系型数据库的表的形式向外部程序提供数据.

#### Access a provider ####
程序访问 content provider 通过一个客户端对象 ContentResolver , 
ContentResolver 对象调用 provider 对象中的同名方法, ContentResolver 是 ContentProvider 的子类, ContentResolver 提供基本的 CRUD 方法
ContentResolver 是在客户端程序进程中, ContentProvider 是在数据拥有者程序进程中. 两者能够自动地处理进程之前的通信
ContentProvider 同时作为数据库与数据呈现之前的一个抽象层.

##### Content URIs #####
content uri 是 provider 中数据的一种标识.
URI (provider 名, table 名)
content://user_dictionary/words 
user_dictionary 是 provider authority
words 是表的路径

很多的 provider 允许在 URI 后台加 ID 表示访问表中的某行数据

##### 查询 provider 的数据. #####
1. 请求读数据的权限.
2. 构建查询代码发送到 provider 的代码.
使用 query(Uri,projection,selection,selectionArgs,sortOrder) 方法查询数据
Uri: 资源路径.              类似对应 数据库 中的表
projection: 投影              对应表中的 column
selection: 查询条件             where 条件 = ?
selectionArgs: 查询条件参数      条件参数
sortOrder: 排序                   ordery
使用过 hibernate 应该对这种查询方式非常熟悉

##### 处理查询结果 #####
query 方法返回一个 Cursor 对象, Cursor 数据包括查询满足条件投影,

##### Content Provider Permissions #####
一个 Provider 程序可以指定权限,其他的程序需要访问数据必须要有特定的权限才能访问.
这些权限让用户知道你的程序访问了哪些数据.
如果一个 Provider 程序没有指定任何权限, 其他程序就不能访问这个 Provider 程序的数据.

##### CRUD #####
 ContentResolver.insert ContentResolver.query ContentResolver.udpate ContentResolver.delete
 详情查看api
 
#####  #####
1. 批量查询
2. 异步查询: 
3. 通过 intents 访问数据

Batch 访问通常用于大批量的数据插入或者在同一个访问中多表插入.
执行批量操作, 首先可以创建一个  ContentProviderOperation 对象, 然后通过  ContentResolver.applyBatch()

Intents 可以提供直接访问 content provider, 即使没有数据访问权限.























 




