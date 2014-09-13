struts2中容器，

interface Container

ContainerImpl{

    Map<Class<?>, List<Injector>> injectors

}

InternalContext//窗口内部上下文环境

ContainerBuilder{
    Map<Key<?>, InternalFactory<?>> factories;
    List<InternalFactory<?>> singletonFactories
    List<Class<?>> staticInjections
}


//依赖注入的key，通过类型跟类型名字可以标识唯一
Key<T>{
    Class<T> type;
    String name;
    int hashCode;
}

constant(String name, String value)
