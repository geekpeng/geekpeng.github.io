---
layout: post
title:  "源码分析 Struts2 执行的过程"
category: java
tags: [struts2]
keywords: Struts2初始化过程, Struts2执行过程, Struts2源码分析
description: 从Struts2的源代码分析了Struts2的初化过程跟 Struts2的执行过程 
---
###Struts2 执行流程###
StrutsPrepareAndExecuteFilter 的 doFilter 方法：

    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        try {
            if (excludedPatterns != null && prepare.isUrlExcluded(request, excludedPatterns)) {//排除的 URL struts2 不对它进行处理，直接调用下一个过滤器 
                chain.doFilter(request, response);
            } else {
                prepare.setEncodingAndLocale(request, response);//先对request 跟 response进行编码跟地理位置处理
                prepare.createActionContext(request, response);//创建 ActionContext
                prepare.assignDispatcherToThread();//将dispatcher 分配到当前线程
                request = prepare.wrapRequest(request); //对request进行封装(主要是对格式为multipart/form-data 请求的处理)
                ActionMapping mapping = prepare.findActionMapping(request, response, true);//将 request 与 Action 对应上
                if (mapping == null) {//找到不对应的 Action 执行静态资源 
                    boolean handled = execute.executeStaticResourceRequest(request, response);
                    if (!handled) {
                        chain.doFilter(request, response);
                    }
                } else {
                    execute.executeAction(request, response, mapping);//执行Action
                }
            }
        } finally {
            prepare.cleanupRequest(request);//执行完成之后清理请求
        }
    }

#### 预处理 request ####
首先会对字符编码跟国际化进行处理，然后将 request 进行封装, 再创建 ActionContext 这里主要看一下 ActionContext 的创建， ActionContext 会分配置到当前线程（也就是次请求对应一些线程),如果已经存在会在当前线程的 ActionContext 基础上创建 ActionContext

    public ActionContext createActionContext(HttpServletRequest request, HttpServletResponse response) {
        ActionContext ctx;
        Integer counter = 1;
        Integer oldCounter = (Integer) request.getAttribute(CLEANUP_RECURSION_COUNTER);
        if (oldCounter != null) {
            counter = oldCounter + 1;
        }
        
        ActionContext oldContext = ActionContext.getContext();
        if (oldContext != null) {
            // detected existing context, so we are probably in a forward
            ctx = new ActionContext(new HashMap<String, Object>(oldContext.getContextMap()));
        } else {
            ValueStack stack = dispatcher.getContainer().getInstance(ValueStackFactory.class).createValueStack();//创建ValueStack
            stack.getContext().putAll(dispatcher.createContextMap(request, response, null, servletContext));//在valueStack中放入重要封闭好request，等对象
            ctx = new ActionContext(stack.getContext());
        }
        request.setAttribute(CLEANUP_RECURSION_COUNTER, counter);
        ActionContext.setContext(ctx);
        return ctx;
    }
   
实际上ActionContext 跟 ValueStack 维护的是相同的上下文 跟 Ongl 上下文 关于 ActionContext 中放入的值的问题可以看 <a href="java/2014_09_20/struts_valuestack_ognl.html">这里</a>

#### Find ActionMapping ####
   
将请求跟 Action 映射起来, 得到ActionMapping 对象.

    public ActionMapping getMapping(HttpServletRequest request, ConfigurationManager configManager) {
        ActionMapping mapping = new ActionMapping();
        String uri = RequestUtils.getUri(request);//得到资源的路径

        //去掉分号后的;jsessionid
        int indexOfSemicolon = uri.indexOf(";");
        uri = (indexOfSemicolon > -1) ? uri.substring(0, indexOfSemicolon) : uri;

        uri = dropExtension(uri, mapping);//解释并去掉 uri 后扩展名(.action,.do)把扩展名set到mapping中
        if (uri == null) {
            return null;
        }

        parseNameAndNamespace(uri, mapping, configManager);//解析 nanem 跟 namespace
        handleSpecialParameters(request, mapping);//处理特殊的参数
        return parseActionName(mapping);//解析 actionname (如果是空返回null,再对action动态方法调用进行处理)
    }
    
解析 Action 的名字跟命名空间

    protected void parseNameAndNamespace(String uri, ActionMapping mapping, ConfigurationManager configManager) {
        String namespace, name;
        int lastSlash = uri.lastIndexOf("/");
        if (lastSlash == -1) {
            namespace = "";
            name = uri;
        } else if (lastSlash == 0) {// '/'命名空间
            namespace = "/";
            name = uri.substring(lastSlash + 1);//Action 名字
        } else if (alwaysSelectFullNamespace) {//将 action 字之前的字符串当成一个完整的命名空间
            // Simply select the namespace as everything before the last slash
            namespace = uri.substring(0, lastSlash);
            name = uri.substring(lastSlash + 1);
        } else {// 跟所有的包的 namespace 去进行匹配
            Configuration config = configManager.getConfiguration();
            String prefix = uri.substring(0, lastSlash);
            namespace = "";
            boolean rootAvailable = false;
            // Find the longest matching namespace, defaulting to the default
            for (PackageConfig cfg : config.getPackageConfigs().values()) {
                String ns = cfg.getNamespace();
                if (ns != null && prefix.startsWith(ns) && (prefix.length() == ns.length() || prefix.charAt(ns.length()) == '/')) {
                    if (ns.length() > namespace.length()) {
                        namespace = ns;
                    }
                }
                if ("/".equals(ns)) {
                    rootAvailable = true;
                }
            }

            name = uri.substring(namespace.length() + 1);

            if (rootAvailable && "".equals(namespace)) {//还没找到使用 root namespace
                namespace = "/";
            }
        }

        if (!allowSlashesInActionNames) { 是否允许action的名字后面再 '/'
            int pos = name.lastIndexOf('/');
            if (pos > -1 && pos < name.length() - 1) {
                name = name.substring(pos + 1);
            }
        }

        mapping.setNamespace(namespace);
        mapping.setName(cleanupActionName(name));//对action name 进行清理，看是否有特殊字符
    }


#### 执行请求 Dispatcher.serviceAction ####

Dispatcher.serviceAction 方法中创建代理对象

     ActionProxy proxy = config.getContainer().getInstance(ActionProxyFactory.class).createActionProxy(
                    namespace, name, method, extraContext, true, false);// 创建 Action 代码对象


ActionProxy 的execute 方法中调用 ActionInvoke 执行代理对象

    public String invoke() throws Exception {
        String profileKey = "invoke: ";
        try {
            UtilTimerStack.push(profileKey);

            if (executed) {
                throw new IllegalStateException("Action has already executed");
            }

            if (interceptors.hasNext()) {//执行所有的拦截器直到最后一个
                final InterceptorMapping interceptor = interceptors.next();
                String interceptorMsg = "interceptor: " + interceptor.getName();
                UtilTimerStack.push(interceptorMsg);
                try {
                                resultCode = interceptor.getInterceptor().intercept(DefaultActionInvocation.this);
                            }
                finally {
                    UtilTimerStack.pop(interceptorMsg);
                }
            } else {//经过所有的拦截器后调用到action
                resultCode = invokeActionOnly();
            }

            // this is needed because the result will be executed, then control will return to the Interceptor, which will
            // return above and flow through again
            if (!executed) {
                if (preResultListeners != null) {//这是一些监听器的回调，在 result 还没有执行之前执行
                    for (Object preResultListener : preResultListeners) {
                        PreResultListener listener = (PreResultListener) preResultListener;

                        String _profileKey = "preResultListener: ";
                        try {
                            UtilTimerStack.push(_profileKey);
                            listener.beforeResult(this, resultCode);
                        }
                        finally {
                            UtilTimerStack.pop(_profileKey);
                        }
                    }
                }

                // now execute the result, if we're supposed to
                if (proxy.getExecuteResult()) {
                    executeResult();//执行result
                }

                executed = true;
            }

            return resultCode;
        }
        finally {
            UtilTimerStack.pop(profileKey);
        }
    }

经过了所的拦截器, 如果一地正常调用 Action 的方法执行

    protected String invokeAction(Object action, ActionConfig actionConfig) throws Exception {
        String methodName = proxy.getMethod();//Action 执行的方法

        if (LOG.isDebugEnabled()) {
            LOG.debug("Executing action method = " + actionConfig.getMethodName());
        }

        String timerKey = "invokeAction: " + proxy.getActionName();
        try {
            UtilTimerStack.push(timerKey);

            boolean methodCalled = false;
            Object methodResult = null;
            Method method = null;
            try {
                method = getAction().getClass().getMethod(methodName, EMPTY_CLASS_ARRAY);//通过反射得到方法
            } catch (NoSuchMethodException e) {//如果没有找这个方法，去找 doXxx 的方法
                // hmm -- OK, try doXxx instead
                try {
                    String altMethodName = "do" + methodName.substring(0, 1).toUpperCase() + methodName.substring(1);
                    method = getAction().getClass().getMethod(altMethodName, EMPTY_CLASS_ARRAY);
                } catch (NoSuchMethodException e1) {//如果还是没找到，抛出异常
                    // well, give the unknown handler a shot
                    if (unknownHandlerManager.hasUnknownHandlers()) {
                        try {
                            methodResult = unknownHandlerManager.handleUnknownMethod(action, methodName);
                            methodCalled = true;
                        } catch (NoSuchMethodException e2) {
                            // throw the original one
                            throw e;
                        }
                    } else {
                        throw e;
                    }
                }
            }

            if (!methodCalled) {
                methodResult = method.invoke(action, EMPTY_OBJECT_ARRAY);//执行Action 方法
            }

            return saveResult(actionConfig, methodResult);//保存方法执行后的结果
        } catch (NoSuchMethodException e) {
            throw new IllegalArgumentException("The " + methodName + "() is not defined in action " + getAction().getClass() + "");
        } catch (InvocationTargetException e) {
            // We try to return the source exception.
            Throwable t = e.getTargetException();

            if (actionEventListener != null) {
                String result = actionEventListener.handleException(t, getStack());
                if (result != null) {
                    return result;
                }
            }
            if (t instanceof Exception) {
                throw (Exception) t;
            } else {
                throw e;
            }
        } finally {
            UtilTimerStack.pop(timerKey);
        }
    }


保存Action执行的结果，结果有可能是一个 ActionChainView SerlvetRedirectView ServletDispatcherView 等， 如果不是转换成 String 类型

    protected String saveResult(ActionConfig actionConfig, Object methodResult) {
        if (methodResult instanceof Result) {
            this.explicitResult = (Result) methodResult;

            container.inject(explicitResult);
            return null;
        } else {
            return (String) methodResult;
        }
    }
 
    private void executeResult() throws Exception {
        result = createResult(); //创建 result 对象

        String timerKey = "executeResult: " + getResultCode();
        try {
            UtilTimerStack.push(timerKey);
            if (result != null) {
                result.execute(this); //执行相关 result 对象的 result 方法
            } else if (resultCode != null && !Action.NONE.equals(resultCode)) {
                throw new ConfigurationException("No result defined for action " + getAction().getClass().getName()
                        + " and result " + getResultCode(), proxy.getConfig());
            } else {
                if (LOG.isDebugEnabled()) {
                    LOG.debug("No result returned for action " + getAction().getClass().getName() + " at " + proxy.getConfig().getLocation());
                }
            }
        } finally {
            UtilTimerStack.pop(timerKey);
        }
    }
    
    public Result createResult() throws Exception {

        if (explicitResult != null) {//如果Action 返回的已经是一个result对象直接返回
            Result ret = explicitResult;
            explicitResult = null;

            return ret;
        }
        
        //如果不是的 返回的是一个String，通过String 跟 Action 的配置得到 result 的配置，并创建 result 对象返回
        ActionConfig config = proxy.getConfig();//得到 action 中配置
        Map<String, ResultConfig> results = config.getResults();//得到 action 的所有 result 的配置

        ResultConfig resultConfig = null;

        try {
            resultConfig = results.get(resultCode);//得到匹配的配置
        } catch (NullPointerException e) {
            if (LOG.isDebugEnabled()) {
                LOG.debug("Got NPE trying to read result configuration for resultCode [#0]", resultCode);
            }
        }
        
        if (resultConfig == null) { //如果得不到匹配的配置，应该是返回全局的result配置
            // If no result is found for the given resultCode, try to get a wildcard '*' match.
            resultConfig = results.get("*");
        }

        if (resultConfig != null) {//如果已经到，创建result对象并返回
            try {
                return objectFactory.buildResult(resultConfig, invocationContext.getContextMap());
            } catch (Exception e) {
                if (LOG.isErrorEnabled()) {
                    LOG.error("There was an exception while instantiating the result of type #0", e, resultConfig.getClassName());
                }
                throw new XWorkException(e, resultConfig);
            }
        } else if (resultCode != null && !Action.NONE.equals(resultCode) && unknownHandlerManager.hasUnknownHandlers()) {//最后还是没有找到，抛出异常
            return unknownHandlerManager.handleUnknownResult(invocationContext, proxy.getActionName(), proxy.getConfig(), resultCode);
        }
        return null;
    }

#### 总结 ####
1. 预处理 request 请求
 1. 编码, 国际化处理
 2. 创建 ActionContext
 3. 给 Dispatcher 当前线程分配 Dispathcer 对象
 4. 封装 request 对象
 5. 寻找 ActionMapping
2. 执行 request 请求
 1. 创建 ActionProxy (Action代理对象)
 2. ActionProxy 执行, 调用 ActionInvocation 的invoke 方法
 3. 得到相关拦截器并执行
 4. Action 方法真正得到调用
 5. 处理 Action 执行结果(Chain, Redirect, Dispatcher)
3. 清理

<a href="{{ site.basePath }}java/2014_09_20/struts2_init.html" target="_blank">struts2 初始化过程</a>
