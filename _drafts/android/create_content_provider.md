#####����Content Provider#####
�ڳ����д���һ�����߶�� Provider, ����һ����ʵ�� ContentProvider ������. 
��������ǳ�����������ĳ������ݵĽӿ�.

�Ƿ���Ҫ����һ�� content provider
1. ������뽫�����ṩ�������������
2. �������û������ݴ���ĳ��򿽱�����������
3. ���Ҫʹ����������ṩ�Զ����������ʾ
���ֻ���ڳ����ڲ�����ֱ��ͨ��SQLite�Ϳ�����

���� provider
1.����ԭʼ����.
  1) File data , ���ݴ洢���ļ���,������Ƭ,��Ƶ...
  2) �ṹ����. ͨ���洢�����ݿ���. 
2. ʵ��  ContentProvider ��.
3. ���� provider's authority
4. ������ѡʵ��

##### �������ݴ洢 #####
1) ʹ�� SQLite, SQLiteOpenHelper ������ά�����ݿ�, SQLiteDatabase �ṩ���������ݿⷽ��
2) �ļ�����,�ο� android ���ļ��洢
3) ��������
 
 �������
 1) provider Ϊÿ����¼ά��Ψһ��������Ϊ���ݿ�����,������name���ʹ��BaseColumns._ID,������ListViewʹ��
 2) �����images�ļ����������Ĵ����ݿ��ļ�,��ô洢���ļ���,�����ݿ��д����ñ�ʶ.
 3) ʹ��BLOB ���ʹ����ļ�
 
 Content URL ���
 authority ʹ�� com.example.<appname>.provider. ��ʽ
 path structure  com.example.<appname>.provider/table1 and com.example.<appname>.provider/table2. 
 IDs  com.example.<appname>.provider/table1/3
 
 patterns

content://com.example.app.provider/table1: A table called table1.
content://com.example.app.provider/table2/dataset1: A table called dataset1.
content://com.example.app.provider/table2/dataset2: A table called dataset2.
content://com.example.app.provider/table3: A table called table3.

    
 UriMatcher �� URL ����ģʽת��������,����ʹ�� switch ���.
 sUriMatcher.addURI("com.example.app.provider", "table1", 1)
 sUriMatcher.addURI("com.example.app.provider", "table2", 2)
 sUriMatcher.addURI("com.example.app.provider", "table3", 3)
 
 Uri Uri.parse("content://com.example.app.provider/table3");
 sUriMatcher.match(uri) ���صľ��� 3
 

�̳� ContentProvider ����, ��ʵ�ַ���
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 