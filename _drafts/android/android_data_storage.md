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
ʹ��openFileOutput(filename, mode),����һ���ļ���