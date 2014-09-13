struts2启动主线：

starts2配置的核心在
org.apache.struts2.dispatcher.ng.filter

web容器在启动时，初始化StrutsPrepareAndExecuteFilter
PrepareOperations
ExecuteOperations
InitOperations      //web容器启动时，初始化struts相关操作。


inti方法执行：
new InitOperations      //创建初始化操作对象，对象中大量初始化的方法
new FilterHostConfig    //StrutsPrepareAndExecuteFilter 过滤器参数配置封闭的一个对象
InitOperations->initLogging     //日志
init.initDispatcher             //初始化Dispatcher,Dispatcher也是struts工作的核心对象
    createDispatcher            //创建Disdpatcher
    dispatcher.init()           //初始化的一些工作
        createConfigurationManager  //创建ConfigurationManage, XWork配置管理的核心对象。包含confuguration,
        init_FileManager();
        init_DefaultProperties(); // [1]        加载默认的属性配置,通常是从 struts.properties
        init_TraditionalXmlConfigurations(); // [2]//读取XML配置如果没有在Filter配置中特别指定，默认会读取：struts-default.xml,struts-plugin.xml,struts.xml，
        init_LegacyStrutsProperties(); // [3]   
        init_CustomConfigurationProviders(); // [5]
        init_FilterInitParameters() ; // [6]
        init_AliasStandardObjects() ; // [7]
        
         Container container = init_PreloadConfiguration();
            ConfigurationManager->getConfiguration      //得到封闭好的XWork配置对象。
            ConfigurationManager->reloadContainer   Calls the ConfigurationProviderFactory.getConfig() to tell it to reload the configuration and then calls* buildRuntimeConfiguration().
                ContainerProperties props = new ContainerProperties();
                ContainerBuilder builder = new ContainerBuilder();
                Container bootstrap = createBootstrapContainer(providers);  创建各种工厂对象方法(ObjectFactory,ActionFactory,)
            bootstrap.inject(containerProvider)     //将窗口的提供者注入到窗口中
            containerProvider.init(this);//初始化各种配置
                 
            
  
