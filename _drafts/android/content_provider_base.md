###Content Providers###

Content Provider ��������ݵķ���.�����ݽ��з�װ,�ṩ��ȫ����. 
Content Provider ��һ�����̷�����һ���������ݵı�׼�ӿ�.
ʹ�� ContentResolver ������һ���ͻ����� Content Provider ����ͨ�� . 
provider object ���մӿͻ��˷��͵�����, ��������, ���ؽ��.
�������Ҫ���� Provider Ϊ�Լ��ĳ����ṩ���ݲ�ѯ�Ȳ���. 
���������ݲ���Ҫ�ṩ�������������, ������ provider ����Ҫȥʵ������������������ݵĹ���.

andorid �����ṩ��һЩ content provider ȥ���� ��Ƶ,����ͼƬ������. android.provider ���Կ����ṩ�� content provider

provider �ǳ����һ����,ͨ�� provider ���Լ��� UI �ṩ����, Content Porvider �����������ṩ���ݷ���.
content provider ͨ�� provider client object ���� provider �ṩ������. 
provider �� provider client �ṩ��һ�µĽӿ���������̼�ͨ�Ÿ���ȫ�����ݷ���.

content provider �������ڹ�ϵ�����ݿ�ı����ʽ���ⲿ�����ṩ����.

#### Access a provider ####
������� content provider ͨ��һ���ͻ��˶��� ContentResolver , 
ContentResolver ������� provider �����е�ͬ������, ContentResolver �� ContentProvider ������, ContentResolver �ṩ������ CRUD ����
ContentResolver ���ڿͻ��˳��������, ContentProvider ��������ӵ���߳��������. �����ܹ��Զ��ش������֮ǰ��ͨ��
ContentProvider ͬʱ��Ϊ���ݿ������ݳ���֮ǰ��һ�������.

##### Content URIs #####
content uri �� provider �����ݵ�һ�ֱ�ʶ.
URI (provider ��, table ��)
content://user_dictionary/words 
user_dictionary �� provider authority
words �Ǳ��·��

�ܶ�� provider ������ URI ��̨�� ID ��ʾ���ʱ��е�ĳ������

##### ��ѯ provider ������. #####
1. ��������ݵ�Ȩ��.
2. ������ѯ���뷢�͵� provider �Ĵ���.
ʹ�� query(Uri,projection,selection,selectionArgs,sortOrder) ������ѯ����
Uri: ��Դ·��.              ���ƶ�Ӧ ���ݿ� �еı�
projection: ͶӰ              ��Ӧ���е� column
selection: ��ѯ����             where ���� = ?
selectionArgs: ��ѯ��������      ��������
sortOrder: ����                   ordery
ʹ�ù� hibernate Ӧ�ö����ֲ�ѯ��ʽ�ǳ���Ϥ

##### �����ѯ��� #####
query ��������һ�� Cursor ����, Cursor ���ݰ�����ѯ��������ͶӰ,

##### Content Provider Permissions #####
һ�� Provider �������ָ��Ȩ��,�����ĳ�����Ҫ�������ݱ���Ҫ���ض���Ȩ�޲��ܷ���.
��ЩȨ�����û�֪����ĳ����������Щ����.
���һ�� Provider ����û��ָ���κ�Ȩ��, ��������Ͳ��ܷ������ Provider ���������.

##### CRUD #####
 ContentResolver.insert ContentResolver.query ContentResolver.udpate ContentResolver.delete
 ����鿴api
 
#####  #####
1. ������ѯ
2. �첽��ѯ: 
3. ͨ�� intents ��������

Batch ����ͨ�����ڴ����������ݲ��������ͬһ�������ж�����.
ִ����������, ���ȿ��Դ���һ��  ContentProviderOperation ����, Ȼ��ͨ��  ContentResolver.applyBatch()

Intents �����ṩֱ�ӷ��� content provider, ��ʹû�����ݷ���Ȩ��.























 




