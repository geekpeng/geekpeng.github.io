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
使用openFileOutput(filename, mode),返回一个文件流.

    private class SaveOnClickListener implements View.OnClickListener {
        @Override
        public void onClick(View v) {
            String input = inputEditText.getText().toString();
            FileOutputStream fos = null;
            try {
                fos = openFileOutput(FILE_NAME, Context.MODE_PRIVATE);
                fos.write(input.getBytes());

            } catch (FileNotFoundException e) {
                e.printStackTrace();
            } catch (IOException e) {
                e.printStackTrace();
            }finally {
                if(fos != null){
                    try {
                        fos.close();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }

            }
        }
    }

    private class loadOnClickListener implements View.OnClickListener{
        @Override
        public void onClick(View v) {
            FileInputStream fis = null;
            try {
                fis = openFileInput(FILE_NAME);
                byte[] buffer = new byte[1024];
                int len = fis.read(buffer);
                String content = "";
                while((len = fis.read(buffer)) != -1){
                    content += new String(buffer, 0, len);
                }
                content += new String(buffer, 0, buffer.length);
                displayTextView.setText(content);
            } catch (IOException e) {
                e.printStackTrace();
            }finally {
                if(fis != null){
                    try {
                        fis.close();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }

            }
        }
    }
    
#####保存缓存文件##### 
如果只是想把数据缓存起来,而不是永远存储.可以使用getCacheDir() 打开一个 file 将数据缓存起来.
如果android内存过低,系统可能会回收掉资源,但是你不应该依赖系统而是最好自己去维护缓存文件,让他在一个合理的大小范围.程序卸载的时候会自己将缓存文件删除.


####使用外部存储####
android 设备支持使用外部存储(SD卡,或者内置的外部存储),保存在外部存储上的文件用户可以修改.外部存储在用户移除,或者挂载在电脑上的时候对app来说变得不可用.

#####访问外部存储#####
访问外部存储需要添加权限: READ_EXTERNAL_STORAGE (读)| WRITE_EXTERNAL_STORAGE (读写)
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
NOTE: 从andorid 4.4 开始,读写程序自己的私有数据不需要请求操作权限.

##### 检查 media 是否可用 #####
前面说用移除SD卡或者,SD卡挂载到电脑上时,外部存储会变成不可用,所以每次操作外部存储的时候需要判断自问存储是否可用.  getExternalStorageState() 

    /* Checks if external storage is available for read and write */
    public boolean isExternalStorageWritable() {
        String state = Environment.getExternalStorageState();
        if (Environment.MEDIA_MOUNTED.equals(state)) {
            return true;
        }
        return false;
    }

    /* Checks if external storage is available to at least read */
    public boolean isExternalStorageReadable() {
        String state = Environment.getExternalStorageState();
        if (Environment.MEDIA_MOUNTED.equals(state) ||
            Environment.MEDIA_MOUNTED_READ_ONLY.equals(state)) {
            return true;
        }
        return false;
    }

##### 保存可以被共享的文件 #####   
通过 getExternalStoragePublicDirectory(), 得到公共的文件.其他对文件的操作完全同java操作文件一样.
NOTE: 测试中发现,没在添加 <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
请求代码时,访问某个文件比如,DIRECTORY_DOWNLOADS 文件时,虽然不会错也可以检测到目录存在,但是读不到目录中的文件信息.


##### 以app私有方式保存文件 ######
android 4.4 之后在外部存储上操作app的私有数据不需要请求权限,所以可以这么写:
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="18" />

通过 getExternalFilesDir(). 得一个以私有的存储空间.

当程序被卸载的时候,私有的目录跟目录中的文件都会被移除.系统的media scanner 不会扫描这些目录下的文件.所以像截图,音乐这样的文件,不应该以app私有的方式存储在外部存储上.而应该存储在公共目录中.
有些设备,分配了内部存储的一个分区作为外部存储,还提供了一个SD卡.在android4.3的时候 getExternalFilesDir() 
只会得到内部存储的一个分区,app不能读写SD卡,android 4.4 可以通过 getExternalFilesDirs() 得到一个数组.
第一个为主外部存储, 在android4.3上如果要同时访问SD卡.能以通过 ContextCompat.getExternalFilesDirs(). 获取.
NOTE: 虽然  getExternalFilesDir() and getExternalFilesDirs() 以私有方式操作文件,
这样 mediaStore content provider 不能访问,但是如果其他 APP 请求 READ_EXTERNAL_STORAGE 还是可以访问外部存储上的所有文件.
所以如果完全不被其他app访问,应该将文件写在内部存储中.

##### 在外部存储中缓存文件 #####
通过 getExternalCacheDir() 得到在外部存储的缓存目录. 
ContextCompat.getExternalFilesDirs() 的作用类似于 ContextCompat.getExternalFilesDirs()

#### 使用database ####
android 支持使用 sqlite 数据库, app 中所有的 class 中可以有通过 name 访问自己创建的数据库. 在自己的app之外无法访问.

推荐创建数据库的方法: 继承 SQLiteOpenHelper 对象, 重载 onCreate() 方法.在onCreate 通过sql命令创建表.







