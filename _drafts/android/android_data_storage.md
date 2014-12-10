###数据存储###
####Shared Preferences####
SharedPreferences 使用Key-Value的形式存储原始数据类型( booleans, floats, ints, longs, strings
    note: SharedPreferences 并不是用来用户配置信息的

getPreferencs() 得到当前Activity的preference file(只会有一个).
getSharedPreferences() 通过 preferences files 的名字标识来得到 preference file
调用 edit() 方法可以得到 SharedPreferences.Editor. 类似一个Map的操作可以通过 putBoolean()等方法写入值
commit() 方法提交.

####Internal Storage####
可以直接在内置存储设备中储存文件.默认存储的文件是私有的.程序卸载的时候文件也会随着被删除
使用openFileOutput(filename, mode),返回一个文件流