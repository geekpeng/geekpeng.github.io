#####创建Content Provider#####
在程序中创建一个或者多个 Provider, 创建一个类实现 ContentProvider 的子类. 
这个子类是程序程序访问你的程序数据的接口.

是否需要创建一个 content provider
1. 如果你想将数据提供给其他程序访问
2. 你允许用户将数据从你的程序拷贝到其他程序
3. 如果要使用搜索框架提供自定义的搜索提示
如果只是在程序内部访问直接通过SQLite就可以了

创建 provider
1.设置原始数据.
  1) File data , 数据存储在文件中,比如照片,视频...
  2) 结构数据. 通过存储在数据库中. 
2. 实现  ContentProvider 类.
3. 定义 provider's authority
4. 其他可选实现

##### 设置数据存储 #####
1) 使用 SQLite, SQLiteOpenHelper 创建并维护数据库, SQLiteDatabase 提供基本的数据库方法
2) 文件数据,参看 android 的文件存储
3) 网络数据
 
 数据设计
 1) provider 为每条记录维护唯一的数字作为数据库主键,主键的name最好使用BaseColumns._ID,方便结果ListView使用
 2) 如果是images文件或者其他的大数据块文件,最好存储在文件中,在数据库中存引用标识.
 3) 使用BLOB 类型储大文件
 
 Content URL 设计
 authority 使用 com.example.<appname>.provider. 形式
 path structure  com.example.<appname>.provider/table1 and com.example.<appname>.provider/table2. 
 IDs  com.example.<appname>.provider/table1/3
 
 patterns

content://com.example.app.provider/table1: A table called table1.
content://com.example.app.provider/table2/dataset1: A table called dataset1.
content://com.example.app.provider/table2/dataset2: A table called dataset2.
content://com.example.app.provider/table3: A table called table3.

    
 UriMatcher 将 URL 配置模式转化成数字,方便使用 switch 语句.
 sUriMatcher.addURI("com.example.app.provider", "table1", 1)
 sUriMatcher.addURI("com.example.app.provider", "table2", 2)
 sUriMatcher.addURI("com.example.app.provider", "table3", 3)
 
 Uri Uri.parse("content://com.example.app.provider/table3");
 sUriMatcher.match(uri) 返回的就是 3
 

继承 ContentProvider 对象, 并实现方法
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 