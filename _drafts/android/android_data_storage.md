###���ݴ洢###
####Shared Preferences####
SharedPreferences ʹ��Key-Value����ʽ�洢ԭʼ��������( booleans, floats, ints, longs, strings
    note: SharedPreferences �����������û�������Ϣ��

getPreferencs() �õ���ǰActivity��preference file(ֻ����һ��).
getSharedPreferences() ͨ�� preferences files �����ֱ�ʶ���õ� preference file
���� edit() �������Եõ� SharedPreferences.Editor. ����һ��Map�Ĳ�������ͨ�� putBoolean()�ȷ���д��ֵ
commit() �����ύ.

####Internal Storage####
����ֱ�������ô洢�豸�д����ļ�.Ĭ�ϴ洢���ļ���˽�е�.����ж�ص�ʱ���ļ�Ҳ�����ű�ɾ��
ʹ��openFileOutput(filename, mode),����һ���ļ���.

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
    
#####���滺���ļ�##### 
���ֻ��������ݻ�������,��������Զ�洢.����ʹ��getCacheDir() ��һ�� file �����ݻ�������.
���android�ڴ����,ϵͳ���ܻ���յ���Դ,�����㲻Ӧ������ϵͳ��������Լ�ȥά�������ļ�,������һ������Ĵ�С��Χ.����ж�ص�ʱ����Լ��������ļ�ɾ��.


####ʹ���ⲿ�洢####
android �豸֧��ʹ���ⲿ�洢(SD��,�������õ��ⲿ�洢),�������ⲿ�洢�ϵ��ļ��û������޸�.�ⲿ�洢���û��Ƴ�,���߹����ڵ����ϵ�ʱ���app��˵��ò�����.

#####�����ⲿ�洢#####
�����ⲿ�洢��Ҫ���Ȩ��: READ_EXTERNAL_STORAGE (��)| WRITE_EXTERNAL_STORAGE (��д)
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
NOTE: ��andorid 4.4 ��ʼ,��д�����Լ���˽�����ݲ���Ҫ�������Ȩ��.

##### ��� media �Ƿ���� #####
ǰ��˵���Ƴ�SD������,SD�����ص�������ʱ,�ⲿ�洢���ɲ�����,����ÿ�β����ⲿ�洢��ʱ����Ҫ�ж����ʴ洢�Ƿ����.  getExternalStorageState() 

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

##### ������Ա�������ļ� #####   
ͨ�� getExternalStoragePublicDirectory(), �õ��������ļ�.�������ļ��Ĳ�����ȫͬjava�����ļ�һ��.
NOTE: �����з���,û����� <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
�������ʱ,����ĳ���ļ�����,DIRECTORY_DOWNLOADS �ļ�ʱ,��Ȼ�����Ҳ���Լ�⵽Ŀ¼����,���Ƕ�����Ŀ¼�е��ļ���Ϣ.


##### ��app˽�з�ʽ�����ļ� ######
android 4.4 ֮�����ⲿ�洢�ϲ���app��˽�����ݲ���Ҫ����Ȩ��,���Կ�����ôд:
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="18" />

ͨ�� getExternalFilesDir(). ��һ����˽�еĴ洢�ռ�.

������ж�ص�ʱ��,˽�е�Ŀ¼��Ŀ¼�е��ļ����ᱻ�Ƴ�.ϵͳ��media scanner ����ɨ����ЩĿ¼�µ��ļ�.�������ͼ,�����������ļ�,��Ӧ����app˽�еķ�ʽ�洢���ⲿ�洢��.��Ӧ�ô洢�ڹ���Ŀ¼��.
��Щ�豸,�������ڲ��洢��һ��������Ϊ�ⲿ�洢,���ṩ��һ��SD��.��android4.3��ʱ�� getExternalFilesDir() 
ֻ��õ��ڲ��洢��һ������,app���ܶ�дSD��,android 4.4 ����ͨ�� getExternalFilesDirs() �õ�һ������.
��һ��Ϊ���ⲿ�洢, ��android4.3�����Ҫͬʱ����SD��.����ͨ�� ContextCompat.getExternalFilesDirs(). ��ȡ.
NOTE: ��Ȼ  getExternalFilesDir() and getExternalFilesDirs() ��˽�з�ʽ�����ļ�,
���� mediaStore content provider ���ܷ���,����������� APP ���� READ_EXTERNAL_STORAGE ���ǿ��Է����ⲿ�洢�ϵ������ļ�.
���������ȫ��������app����,Ӧ�ý��ļ�д���ڲ��洢��.

##### ���ⲿ�洢�л����ļ� #####
ͨ�� getExternalCacheDir() �õ����ⲿ�洢�Ļ���Ŀ¼. 
ContextCompat.getExternalFilesDirs() ������������ ContextCompat.getExternalFilesDirs()

#### ʹ��database ####
android ֧��ʹ�� sqlite ���ݿ�, app �����е� class �п�����ͨ�� name �����Լ����������ݿ�. ���Լ���app֮���޷�����.

�Ƽ��������ݿ�ķ���: �̳� SQLiteOpenHelper ����, ���� onCreate() ����.��onCreate ͨ��sql�������.







