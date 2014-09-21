---
layout: post
title:  "源码分析 Struts2 的初始化过程"
category: java
tags: [struts2]
keywords: Struts2初始化过程, Struts2执行过程, Struts2源码分析
description: 从Struts2的源代码分析了Struts2的初化过程跟 Struts2的执行过程 
---
StrutsPrepareAndExecuteFilter 是 Struts2 的入口点，初始化跟执行处理 request 都是由这个过滤器开始
###Struts2初始化####
Struts2 初始化，StrutsPrepareAndExecuteFilter 中的init方法：
    
    public void init(FilterConfig filterConfig) throws ServletException {
        InitOperations init = new InitOperations();//创建InitOperations对象，对象中大量struts2初始化方法
        Dispatcher dispatcher = null;
        try {
            FilterHostConfig config = new FilterHostConfig(filterConfig);//封装过滤器的配置参数
            init.initLogging(config);//初始化日志输出
            dispatcher = init.initDispatcher(config);//创建并初始化Dispacher对象，对象负责 Struts2 对请求的处理， 是 Sturts2 的核心对象
            init.initStaticContentLoader(config, dispatcher);

            prepare = new PrepareOperations(filterConfig.getServletContext(), dispatcher);//初始化 PrepareOperations 对象，负责对请求的预处理操作
            execute = new ExecuteOperations(filterConfig.getServletContext(), dispatcher);//初始化 ExecuteOperations 负责执行请求
            this.excludedPatterns = init.buildExcludedPatternsList(dispatcher);

            postInit(dispatcher, filterConfig);
        } finally {
            if (dispatcher != null) {
                dispatcher.cleanUpAfterInit();
            }
            init.cleanup();
        }
    }
    
    
我们重要跟进这段代码 dispatcher = init.initDispatcher(config)

    public Dispatcher initDispatcher( HostConfig filterConfig ) {
        Dispatcher dispatcher = createDispatcher(filterConfig);//创建 Dispatcher 对象
        dispatcher.init();//初始化
        return dispatcher;
    }

在创建 Dispatcher 的时候，将封装好的 filterConfig 作为参数进来，将 filter 的配置参数跟 ServietContext 传给 Dispatcher 对象
    
    private Dispatcher createDispatcher( HostConfig filterConfig ) {
        Map<String, String> params = new HashMap<String, String>();
        for ( Iterator e = filterConfig.getInitParameterNames(); e.hasNext(); ) {
            String name = (String) e.next();
            String value = filterConfig.getInitParameter(name);
            params.put(name, value);
        }
        return new Dispatcher(filterConfig.getServletContext(), params);
    }
    
初始化 Dispacher, 加载 Sturts 配置文件(xml, 注解)

    public void init() {

    	if (configurationManager == null) { //如果不存在 configurationManger 对象，创建一个新的对象，configurationManger 是 Struts2 配置管理的核心，管理所有的配置信息
    		configurationManager = createConfigurationManager(DefaultBeanSelectionProvider.DEFAULT_BEAN_NAME);
    	}

        try {
            // 这几个 init 并没的直接马上去加载配置信息， 目前只是指定了配置信息要去什么地方加载，创建了相关的 ContainerProvider 对象
            init_FileManager();//初始化文件配置提供者
            init_DefaultProperties(); // 初始化默认属性配置提交者(确切地说加载 default.properties)
            init_TraditionalXmlConfigurations(); // 初始化传统的 XML 配置提交者(默认会加载 struts-default.xml,struts-plugin.xml,struts.xml )，除非别在 配置拦截器的时候指定要加载的配置文件
            init_LegacyStrutsProperties(); // 初始化自定义配置提供对象
            init_CustomConfigurationProviders(); // 
            init_FilterInitParameters() ; // [6]
            init_AliasStandardObjects() ; // 初始化标准的 Bean 提供者
            //这个方法才是真的去加载配置
            Container container = init_PreloadConfiguration(); //初始化并预加载配置
            container.inject(this);
            init_CheckWebLogicWorkaround(container);

            if (!dispatcherListeners.isEmpty()) {
                for (DispatcherListener l : dispatcherListeners) {
                    l.dispatcherInitialized(this);
                }
            }
        } catch (Exception ex) {
            if (LOG.isErrorEnabled())
                LOG.error("Dispatcher initialization failed", ex);
            throw new StrutsException(ex);
        }
    }
    
从上面的方法分析，下面进入到 init_PreloadConfiguration 方法，初始化并预加载配置信息

    private Container init_PreloadConfiguration() {
        Configuration config = configurationManager.getConfiguration();//加载配置
        Container container = config.getContainer();

        boolean reloadi18n = Boolean.valueOf(container.getInstance(String.class, StrutsConstants.STRUTS_I18N_RELOAD));
        LocalizedTextUtil.setReloadBundles(reloadi18n);

        ContainerHolder.store(container);

        return container;
    }

     public synchronized Configuration getConfiguration() {
        if (configuration == null) { //如果当前配置对象不存在创建一个并加载配置信息
            setConfiguration(createConfiguration(defaultFrameworkBeanName));
            try {
                configuration.reloadContainer(getContainerProviders());//重要加载容器
            } catch (ConfigurationException e) {
                setConfiguration(null);
                throw new ConfigurationException("Unable to load configuration.", e);
            }
        } else {//如果已经存在直接重要加载
            conditionalReload();
        }

        return configuration;
    }

Configuration 加载容器
    public synchronized List<PackageProvider> reloadContainer(List<ContainerProvider> providers) throws ConfigurationException {
        packageContexts.clear();
        loadedFileNames.clear();
        List<PackageProvider> packageProviders = new ArrayList<PackageProvider>();

        ContainerProperties props = new ContainerProperties();
        ContainerBuilder builder = new ContainerBuilder();
        Container bootstrap = createBootstrapContainer(providers);//创建一个辅助引用容器
        for (final ContainerProvider containerProvider : providers)
        {
            bootstrap.inject(containerProvider);//解决容器提供者的依赖对象
            containerProvider.init(this);//初始化, xmlConfigurationProvider 开始加载配置文件(容器级别的配置在这里开始解释，package级别的配置未解释)
            containerProvider.register(builder, props);//为容器(Struts2容器)注册上 Bean 跟 属性
        }
        props.setConstants(builder);

        builder.factory(Configuration.class, new Factory<Configuration>() {
            public Configuration create(Context context) throws Exception {
                return DefaultConfiguration.this;
            }
        });

        ActionContext oldContext = ActionContext.getContext();
        try {
            // Set the bootstrap container for the purposes of factory creation

            setContext(bootstrap);
            container = builder.create(false);//创建容器,容器被 configuration 引用
            setContext(container);
            objectFactory = container.getInstance(ObjectFactory.class);//对象objectFacotry工厂对象, 工厂对象被 configuration 对象引用

            // 处理配置提交者对象
            for (final ContainerProvider containerProvider : providers)
            {
                if (containerProvider instanceof PackageProvider) {//如果容器提供者是一个包提供者
                    container.inject(containerProvider);
                    ((PackageProvider)containerProvider).loadPackages();//解释包提供者 解释加载包级别配置，(包名，名字空间，继承，拦截器，Action,默认Result 等)具体如果加载这里暂不分析
                    packageProviders.add((PackageProvider)containerProvider);
                }
            }

            // 处理插件的packageProvider
            Set<String> packageProviderNames = container.getInstanceNames(PackageProvider.class);
            for (String name : packageProviderNames) {
                PackageProvider provider = container.getInstance(PackageProvider.class, name);
                provider.init(this);
                provider.loadPackages();
                packageProviders.add(provider);
            }

            rebuildRuntimeConfiguration();//重建运行时候环境
        } finally {
            if (oldContext == null) {
                ActionContext.setContext(null);
            }
        }
        return packageProviders;
    }

至此 Struts2 初始化完成.
在这里点不是很明白的地方：

为什么在 Struts2 初始化的时候 会去对当前线程的 ActionContext 做处理，看上面的 reloadContainer 方法，到最后初始化完成后又 StrutsPrepareAndExecuteFilter 的 init 方法中调用了调用了 cleanup 方法将基设置为null我的理解是这种的：一个请求的同时容器的配置发生了变化，容器这个时候重启，这个时候就会导致 ActionContext 在容器 reload 前后会不一致，这个时候需要判断 ActionContext 是否已经存在，如果存在，在原来的基本上重建一个actionContext, 如果不存在那么 ActionContext 还是为null,在适当的时候再重建.
    

####总结####
1. 在 Servlet 容器初始化的时候，加载 web.xml 文件初始化过滤器
2. 初始化 StrutsPrepareAndExecuteFilter 调用 init 方法
3. 创建 InitOperations 对象, 负责 init 工作
4. 封闭 Filter 的配置信息, 初始化日志输入
5. 初始化 Dispatcher 对象
 1. 创建 DisPatcher 对象, Struts 对象请求控制的核心对象, 有点指挥调度中心的感觉
 2. 创建 ConfigurationManager 对象, Struts2 所有配置的核心管理对象
 3. 创建各种 containerProvider 对象
 4. 创建 congigura 对象, 并加载 Strust2 容器
  1. 创建引导启动容器
  2. 解决 configuraProvider 依赖 (containerProvider 级别)
  3. 初始化 containerPorvider, 容器级别配置开始加载
  4. 绑定 Bean 工厂对象, 常量工厂对象
  5. 创建 struts2 容器
  6. 处理 containerProvider 依赖 (packageProvider 级别)
  7. 初始化 并加载 packageConfig 
  8. 构建 RuntimeConfiguration
6. 初始化 PrepareOperations 对象. 在 struts2 对 request 请求处理过程中 负责对request进行顶处理
7. 初始化 ExecuteOperations 对象. 在 struts2 对 request 请求处理过程中 负责执行request请求
8. 清理资源

<a href="{{ site.basePath }}java/2014_09_20/struts2_process_request.html" target="_blank">struts2 请求处理过程</a>

