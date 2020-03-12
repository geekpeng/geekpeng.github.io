---
layout: post
title:  "struts2 IOC容器实现跟注入源码分析"
category: java
tags: [struts2, ioc, 依赖注入]
keywords: struts2,container，struts container,ioc,depend inject,struts ioc,struts容器,struts容器依赖注入
description: 从struts2源码分析struts2容器的实现原理，分析struts2 IOC容器的注入过程
---
在决定看struts容器的之前是因为在这之前有在看struts2的初始化过程，但是对struts2在初始化的时候为什么要初始化两人个容器非常的不理解(其中一个是bootstarp容器)，所以决定看一下struts2容器的实现，最后决定把这笔记放在bolg上，如果你在看的时候可以结合文章下面的几个图片可能会更好理解一些。  
####一，首先关注的几个接口/对象####

ContainerBuilder//容器创建对象  

Container//容器,定义的几个方法  

    void inject(Object o);  
    <T> T inject(Class<T> implementaction);  
    <T> T getInstance(Class<T> type, String name);  
    <T> T getInstance(Class<T> type);  

ContainerImpl//容器的实现  


####二，容器创建:####

	ContainerBuilder builder = new ContainerBuilder();
	Container c = builder.create(false);
	
####三，测试例子：####
下面是一个简单的注入的例子:  
  
  
  
	class Student{
		private String name;
		private Integer age;
		private Teacher teacher ;
		public String getUsername() {
			return name;
		}
		@Inject("student.name")
		public void setName(String name) {
			this.name = name;
		}
		public String getName() {
			return name;
		}
		public Integer getAge() {
			return age;
		}
		@Inject("student.age")
		public void setAge(int age) {
			this.age = age;
		}
		public Teacher getTeacher() {
			return teacher;
		}
		@Inject
		public void setTeacher(Teacher teacher) {
			this.teacher = teacher;
		}
	}
	public class Teacher {
		private String name;
		@Inject("teacher.name")
		public void setName(String name) {
			this.name = name;
		}
		public String getName() {
			return name;
		}
	}




现在两个对象,Teacher对象的name属性,Student对象的name,age,teacher都通过容器进行依赖注入,下面写测试方法(可以先看后面的分析再回过头来看这个测试类):  
	
    /**
     * 测试两个外部对象是否可以通过inject注入
     * @author ipenglei
     *
     */
    public class ContainerImplTest2 extends TestCase{

	     private Container c;
	     private ContainerBuilder builder;
	     
	     
	     private final String STUDENT_NAME = "student";
	     private final int STUDENT_AGE = 15;
	     private final String TEACHER_NAME = "teacher";
	     
        @Override
        protected void setUp() throws Exception {
            super.setUp();
            builder = new ContainerBuilder();
        }
        
        /**
         * 在没做任何处理的情况下,直接注入肯定会失败,
         * 因为Teacher对象的name属性依赖注入
         * 没有对象依赖做处理的情况下 inject(Teacher.class) 失败
         */
        public void testInjectTeacher(){
        	Teacher t = null;
        	try{
        		c = builder.create(false);
            	t = c.inject(Teacher.class);
            	fail("test fail: teacher cannot inject, but injected");
        	}catch(DependencyException e){
        		e.printStackTrace();
        	}
        	assertNull(t);
        }
        
        /**
         * 处理好Teacher属性的依赖,使用ContainerBuilder的constant方法
         */
        public void testInjectTeacher2(){
        	Teacher t = null;
        	try{
        		builder.constant("teacher.name", TEACHER_NAME);
        		c = builder.create(false);
        		t = c.inject(Teacher.class);
        		assertNotNull(t);
        		assertEquals(TEACHER_NAME, t.getName());
        	}catch(DependencyException e){
        		e.printStackTrace();
        		fail("inject fail depende exception ");
        	}
        }
        
        /**
         * 测试通过Container的getInstance方法得到对象实例.
         * Teacher 对象不由容器管理，Teahcer的属性由容器管理
         * inject(Teacher.class)时成功
         * getInstance(Teahcer.class)时返回null
         * 
         * 方法返回的对象为null
         */
        public void testGetInstanceTeacher(){
        	Teacher t = null;
        	try{
        		builder.constant("teacher.name", TEACHER_NAME);
        		c = builder.create(false);
        		t = c.inject(Teacher.class);
        		assertNotNull(t);
        		assertEquals(TEACHER_NAME, t.getName());
        		
        		//通过 getInstance 返回 Teacher 对象为null
        		t = c.getInstance(Teacher.class);
        		assertNull(t);
        		
        	}catch(DependencyException e){
        		e.printStackTrace();
        		fail("inject fail depende exception ");
        	}
        }
        
        /**
         * Teacher 所有的属性都让容器管理
         */
        public void testGetInstanceTeacher2(){
        	Teacher t = null;
        	try{
        		builder.constant("teacher.name", TEACHER_NAME);
        		builder.factory(Teacher.class);
        		c = builder.create(false);
        		//通过 getInstance 返回 Teacher 对象为null
        		t = c.getInstance(Teacher.class);
        		assertNotNull(t);
        		assertEquals(TEACHER_NAME, t.getName());
        		
        	}catch(DependencyException e){
        		e.printStackTrace();
        		fail("inject fail depende exception ");
        	}

        }
        
        
	
        /**
         * 在测试的时候将对象student需要依赖注入的属性全部交给容器管理
         * 但是student 对象没有让容器管理，inject(Student.class) 是可以成功，
         * getInstance(Student.class)返回的是一个null
         */
        public void testInjectNoFactory() {
        	  builder.constant("student.name", STUDENT_NAME);
              builder.constant("student.age", STUDENT_AGE);
              builder.constant("teacher.name", TEACHER_NAME);
              builder.factory(Teacher.class);
        	  c = builder.create(false);
        	Student stu = null;
            try {
            	
            	c.inject(Teacher.class);
            	c.inject(Student.class);
            	c.inject(Student.class);
            	stu = c.getInstance(Student.class);
            	assertNull(stu);
            } catch (Exception expected) {
            	expected.printStackTrace();
            	fail();
            }
            
        }
        
        /**
         * 将Student对象Teacher对象交给容器处理，Teahcer对象的Scope为SINGLETON
         */
        public void testInjectSingleton(){
        	 builder.constant("student.name", STUDENT_NAME);
             builder.constant("student.age", STUDENT_AGE);
             builder.constant("teacher.name", TEACHER_NAME);
             builder.factory(Teacher.class, Scope.SINGLETON);
             builder.factory(Student.class);
       	  c = builder.create(false);
       	Student stu = null;
           try {
           	
           	stu = c.getInstance(Student.class);
           	Student stu2 = c.getInstance(Student.class);
           	
           	assertNotSame(stu, stu2); //返回的2个student对象并不同
           	assertEquals(true, stu.getTeacher() == stu2.getTeacher() && stu2.getTeacher() == c.getInstance(Teacher.class));//返回是同一个teacher对象
           	
           } catch (Exception expected) {
           	expected.printStackTrace();
           	fail();
           }
        }
    }



	
为什么inject(Teahcer.class)可以成功，但是getInstance(Teacher.class)返回的是null?之前我不理解,仔细看了源代码再想想也就知道为什么了:  

原来对struts2容器的依赖注入理解有误:  

1. **所谓的注入并不是说把对象注入到容器中,而是通过容器将对象依赖的其他对象注入进入**,比如上面提到的Student对象依赖Teacher对象,注入的意思是通过容器将teacher对象注入到student对象中,而不是说将teacher跟student对象注入到容器中.  
2. 容器并不管理或者说直接管理对象(这里的对象指类似上面说到的Student,Teacher这类依赖注入的对象),**容器中维护的是创建对象的工厂对象,跟对象的依赖关系.**  

所以 Container 的 inject 跟 getInstance 的功能是:  

1. inject(Class<T> implementaction);//创建对象并完成对象依赖属性的注入  
2. <T> T getInstance(Class<T> type);//通过对象的工厂方法创建对象,并完成对象依赖的注入  

这就解释了为什么上面的测试代码中 testGetInstanceTeacher 方法为什么能够通过 inject 方法得到Teacher的实例, getInstance 返回的却是null,因为容器中并没有创建Teacher对象的工厂方法.  



上面代码中使用了 ContainerBuilder 的 constant 跟 factory 方法,这两个方法的作用就是创建工厂对象.  

####创建并绑定工厂对象####
分析ContainerBuilde的factory方法,factory方法有很多的重载,这里主要看下面三个,其他的方法最终都会调用到这三个方法上面，(<a href="#factory_object">工厂对象创建简单图解,可以结构图看代码分析</a>)  
	
#####通过给定的对象类型创建内部工厂对象#####




	/**
	 * type 类型可能是 implementaction 实现的一个接口或者是继续的父类
	 * 
	 * @param type 创建对象类型
	 * @param name 对象名称
	 * @param implementation 创建对象具体实现
	 * @param Scope 对象的范围
	 **/
	public <T> ContainerBuilder factory(final Class<T> type, 
	final String name,final Class<? extends T> implementation, final Scope scope)
	{
	     //创建工厂对象,这个工厂对象使用构造方法创建对象实例
        InternalFactory<? extends T> factory = new InternalFactory<T>() {
		    //对象构造方法注入器
          volatile ContainerImpl.ConstructorInjector<? extends T> constructor;

          @SuppressWarnings("unchecked")
          public T create(InternalContext context) {
            if (constructor == null) {//如果构造方法注入器不存在从容器中得到
              this.constructor =
                  context.getContainerImpl().getConstructor(implementation);
            }
            return (T) constructor.construct(context, type);
          }

          @Override
          public String toString() {
            return new LinkedHashMap<String, Object>() { {
              put("type", type);
              put("name", name);
              put("implementation", implementation);
              put("scope", scope);
            }}.toString();
          }
        };

        return factory(Key.newInstance(type, name), factory, scope);
    }

 
 
  
#####给定对象类型并给工厂对象#####
 
 
  
	/**
	 * 方法将 自己定义的工厂对象封装成 InternalFactory 对象
	 *
	 *
	 * @param type 创建对象类型
	 * @param name 对象名称
	 * @param implementation 创建对象的工厂对象
	 * @param Scope 对象的范围
	 **/
	public <T> ContainerBuilder factory(final Class<T> type, final String name,final Factory<? extends T> factory, Scope scope){
        //将自己定义的工厂对象进行封装
	    InternalFactory<T> internalFactory =
            new InternalFactory<T>() {

          public T create(InternalContext context) {
            try {
              Context externalContext = context.getExternalContext();
              return factory.create(externalContext);
            } catch (Exception e) {
              throw new RuntimeException(e);
            }
          }

          @Override
          public String toString() {
            return new LinkedHashMap<String, Object>() { {
              put("type", type);
              put("name", name);
              put("factory", factory);
            }}.toString();
          }
        };
	
        return factory(Key.newInstance(type, name), internalFactory, scope);
    }
  
  
  
  
#####封装内部工厂对象#####
这个方法将工厂方法跟 scope 关联起来



	/**
	 * 所有的 factory 方法最终都会调用这个方法,方法必需在容器创建之前调用
	 * 
	 * 1, 将对象的范围跟对象工厂关联上,
	 * 
	 * A对象设置的scope 为 scope.SINGLETON,那么工厂对象只会创建一个A对象的实例;
	 * B对象设置的scope 为 scope.REQUEST, 那么会为一次请求创建一个B对象实例;
	 * C默认情况是 scope.DEFAULT, 那么工厂对象会为每依赖 C 的对象创建不同的 C 对象的实例
	 * 
	 * 2, Scope.SINGLETION 的对象, 会将创建这个对象的工厂对象放到 singletonFactories 的List中,以便在有必要的情况下创建容器的就创建所有的单例对象
	 *
	 * @param key Key值,由对象的类型type 跟 key 生成,通过key值找到唯一相关的工厂对象
	 * @param factory 内部工厂对象
	 * @param Scope 对象的范围
	 **/
	private <T> ContainerBuilder factory(final Key<T> key, InternalFactory<? extends T> factory, Scope scope){
		ensureNotCreated();//确保容器还没有创建
		checkKey(key);//key 是否已经存在
		final InternalFactory<? extends T> scopedFactory =
			scope.scopeFactory(key.getType(), key.getName(), factory); //再将封装,将工厂对象与Scope关联上
		factories.put(key, scopedFactory);//工厂对象放到factories中
		if (scope == Scope.SINGLETON) {//如果Scope为SINGLETON,将封装好的工厂对象再次封装并 放入 singletonFactories 中 
		  singletonFactories.add(new InternalFactory<T>() {
			public T create(InternalContext context) {
			  try {
				context.setExternalContext(ExternalContext.newInstance(
					null, key, context.getContainerImpl()));
				return scopedFactory.create(context);
			  } finally {
				context.setExternalContext(null);
			  }
			}
		  });
		}
		return this;
	}




看了这三个 factory 方法后其他的方法理解就比较解决了, 最终都会调用到上面的第三个方法.
其他的方法只不过是一些 Conserver 方法 


####创建容器####
下面看一下通过源代码分析一下 Struts2 的 Container 原理.

ContainerBuilder的构造方法:  




    public ContainerBuilder() {
        // In the current container as the default Container implementation.
        factories.put(Key.newInstance(Container.class, Container.DEFAULT_NAME),CONTAINER_FACTORY);

        // Inject the logger for the injected member's declaring class.
        factories.put(Key.newInstance(Logger.class, Container.DEFAULT_NAME),LOGGER_FACTORY);
    }




重点看:  




	factories.put(Key.newInstance(Container.class, Container.DEFAULT_NAME),CONTAINER_FACTORY);




- factories 是一个Map类型存入工厂对象,Map<Key<?>, InternalFactory<?>>  
- key是通过**Key.newINstance(Class<T> type, String name)生成的Key对象实例,type为对象类型,name对象名(似乎这里说对象名不太准确,),默认为"default",重写了hashCode 跟 equalse 方法,确保相同类型相同name会有相同的key值**  
- value为用来创建对象对应的**工厂对象**.  

ContainerBuilder 构造方法中重点是将 Container 的工厂对象入 factories 中.**但是 Container 的工厂对象并不创建容器,而且从上下文中将已经创建的容器返回,容器的创建在ContainerBuilder的create 方法中 new 出来的**  

ContainerBuilder.create 方法:  




    public Container create(boolean loadSingletons) {
    ensureNotCreated();//确保容器没有创建过
    created = true;
    final ContainerImpl container = new ContainerImpl(new HashMap<Key<?>, InternalFactory<?>>(factories)); //创建容器
    if (loadSingletons) {//创建singleton对象实例,如果需要的话
      container.callInContext(new ContainerImpl.ContextualCallable<Void>() {
	    public Void call(InternalContext context) {
	      for (InternalFactory<?> factory : singletonFactories) {
		    factory.create(context);
	      }
	      return null;
	    }
      });
    }
    container.injectStatics(staticInjections);//注入类的静态属性
    return container;
    }



  
这样容器就创建好了,容器创建好后只是hold了创建对象的工厂对象(<a href="#struts_container">可以结合容器结构的一个简单示意图来看</a>).

####通过容器得到对象实例####
下面开始看从容器中得到对象(<a href="#inject_process">这里是注入的一个过程图</a>)  
Container.getInstance(Class<T> type);



	/**
	 * callIncontxt是一个模板方法确保在容器上下文环境中调用
	 * ContextualCallable 是一回调,执行具体的创建对象的过程
	 **/
	public <T> T getInstance( final Class<T> type ) {
		return callInContext(new ContextualCallable<T>() {
			public T call( InternalContext context ) {
				return getInstance(type, context);
			}
		});
	}




回调中调用的 getInstance 方法:  




	//在没有name的情况下会使用 DEFAULT_NAME
	<T> T getInstance( Class<T> type, InternalContext context ) {
		return getInstance(type, DEFAULT_NAME, context);
	}
	
	//我们先忽略掉方法中 各种 context , 方法就是根据key得到创建对象的工厂对象,调用工厂对象的createy方法
	<T> T getInstance( Class<T> type, String name, InternalContext context ) {
		ExternalContext<?> previous = context.getExternalContext();
		Key<T> key = Key.newInstance(type, name);
		context.setExternalContext(ExternalContext.newInstance(null, key, this));
		try {
			InternalFactory o = getFactory(key);
			if (o != null) {
				return getFactory(key).create(context);
			} else {
				return null;
			}
		} finally {
			context.setExternalContext(previous);
		}
	}




这个工厂对象创建对象的方法在哪里实现的呢?当然不同的对象对应的工厂对象是有不同而我们通过 
在我们没有自己提供工厂对象的时候通过 ContainerBuilder.factory(Class<T> type) 方法创建并绑定的工厂对象有一默认的**通过构造方法来创建对象的工厂对象.**  
其中 create 方法的实现:  



	
	InternalFactory<? extends T> factory = new InternalFactory<T>() {
		//对象构造方法注入器
      volatile ContainerImpl.ConstructorInjector<? extends T> constructor;

      @SuppressWarnings("unchecked")
      public T create(InternalContext context) {
        if (constructor == null) {//如果构造方法注入器不存在从容器中得到
          this.constructor =
              context.getContainerImpl().getConstructor(implementation);
        }
        return (T) constructor.construct(context, type);
      }

      @Override
      public String toString() {
        return new LinkedHashMap<String, Object>() { {
          put("type", type);
          put("name", name);
          put("implementation", implementation);
          put("scope", scope);
        }}.toString();
      }
    };




构造方法注入器 ConstructorInjector  
	通过调用 ContainerImpl 的 getConstrutctor 方法的调用，容器维护的构造方法注入器Map(constructors)中得到注入器,如果首次构造某个类型的对象,构造方法注入器还不存在。会去创建一个这样的构造器注入器,并将注入依赖对象的其他注入器也创建出来. 这些注入器会被缓存下来，下一次构造对象的时候直接使用。
	constructors 本质是一个 继承了 Map 的对象 ReferenceCache，通过get方法得到注入器
	ReferenceCache重写的get方法，  


	
	@SuppressWarnings("unchecked")
    @Override 
    public V get(final Object key) {
        V value = super.get(key);//首先是 Map 中来获取，如果不存在，那为对这个对象创建一个构造器注入器
        return (value == null)
          ? internalCreate((K) key)
          : value;
      }



      
先不管 internalCreate 方法复杂的实现，但有几行关键代码：



      
     V internalCreate(K key) {
      //创建任务，
      FutureTask<V> futureTask = new FutureTask<V>(new CallableCreate(key));
      //执行任务，执行 CallableCreate(key)中的call方法
      futureTask.run();
      //任务执行的结果
      V value = futureTask.get();
      //返回结果
      return value;
    }



	
ReferenceCache 内部类 CallableCreate 中的call方法，调用了创建 注入器的方法




	class CallableCreate implements Callable<V> {

        K key;

        public CallableCreate(K key) {
          this.key = key;
        }

        public V call() {
          // try one more time (a previous future could have come and gone.)
          V value = internalGet(key);
          if (value != null) {
            return value;
          }

          // create value.
          value = create(key);
          if (value == null) {
            throw new NullPointerException(
                "create(K) returned null for: " + key);
          }
          return value;
        }
      }



	
create 方法在哪里实现的呢？在new ReferenceCache 的时候，回到 Container 维护的 构造器注入器Map constructors 的创建，在创建这个Map的时候实现了create方法，create 方法创建构造器注入器:  



	
	Map<Class<?>, ConstructorInjector> constructors =
	    new ReferenceCache<Class<?>, ConstructorInjector>() {
		    @Override
		    @SuppressWarnings("unchecked")
		    protected ConstructorInjector<?> create( Class<?> implementation ) {
			    return new ConstructorInjector(ContainerImpl.this, implementation); //创建构造方法注入器，在创建构造方法注入器的时候会将对象依赖的其他注入器也创建好
		    }
	    };
	



在构造方法注入器的构造方法的时候 有一行代码：injectors = container.injectors.get(implementation);得到或者创建属性或者方法注入器，同得到对象构造方法注入器一样分析再看：  




    final Map<Class<?>, List<Injector>> injectors ＝ 
        new ReferenceCache<Class<?>, List<Injector>>() {
	        @Override
	        protected List<Injector> create( Class<?> key ) {//创建（属性，方法）构造器
		        List<Injector> injectors = new ArrayList<Injector>();
		        addInjectors(key, injectors);
		        return injectors;
	        }
        };




create 中的 addInjectors 方法：  




    void addInjectors( Class clazz, List<Injector> injectors ) {
		if (clazz == Object.class) {
			return;
		}

		addInjectors(clazz.getSuperclass(), injectors); //递归调用，创建类型的属性跟方法注入器

		addInjectorsForFields(clazz.getDeclaredFields(), false, injectors); //创建属性注入器
		addInjectorsForMethods(clazz.getDeclaredMethods(), false, injectors);//创建方法注入器
	}



	
创建属性注入器方法：  




    <M extends Member & AnnotatedElement> void addInjectorsForMembers(
			List<M> members, boolean statics, List<Injector> injectors,
			InjectorFactory<M> injectorFactory ) {
		for ( M member : members ) {
			if (isStatic(member) == statics) {
				Inject inject = member.getAnnotation(Inject.class);
				if (inject != null) {
					try {
						injectors.add(injectorFactory.create(this, member, inject.value()));
					} catch ( MissingDependencyException e ) {
						if (inject.required()) {
							throw new DependencyException(e);
						}
					}
				}
			}
		}
	}
	void addInjectorsForFields( Field[] fields, boolean statics,
								List<Injector> injectors ) {
		addInjectorsForMembers(Arrays.asList(fields), statics, injectors,
				new InjectorFactory<Field>() {
					public Injector create( ContainerImpl container, Field field,
											String name ) throws MissingDependencyException {
						return new FieldInjector(container, field, name);//创建属性注入器并
					}
				});
	}


####依赖对象注入器 Injector ####
1，构造器注入器：ConstrucortInject  

在创建构造器注入器时，会做下面一些工作：

1. 创建构造方法注入器
2. 创建构造方法参数注入器
3. 创建属性跟方法注入器
4. 创建方法参数注入器

为了更清晰分析，在这里给出 ConstrucorInject 对象的关键代码：  




    /**
     * 比如你在创建一个对象的时候：Teacher teacher = new Teacher("name", "gender");
     * 想一想这个就应该明白，为什么构造器注入器中需要这些字段，
     * 需要知道对象的类型，对象的构造方法，对象构造方法的参数，
     * 因为是依赖注入需要知道对象通过方法或者属性注入有哪些字段吧。
     * 
     * 
     *
     **/
    ConstrucorInject{

        final Class<T> implementation; //对象类型
	    final List<Injector> injectors; //对象的属性跟方法注入器
	    final Constructor<T> constructor; //对象的构造方法
	    final ParameterInjector<?>[] parameterInjectors; //参数注入器
	
	    /**
	     * @param container 容器
	     * @param implementation 对象类型
	     *
	     **/
	    ConstructorInjector( ContainerImpl container, Class<T> implementation ) {
		
		    this.implementation = implementation;

		    constructor = findConstructorIn(implementation); //得到构造方法
		    if (!constructor.isAccessible()) {//设置构造方法可访问
			    ... ...
		    }

		    try {
			    inject = constructor.getAnnotation(Inject.class);//得到构造方法上的Inject注解
			    parameters = constructParameterInjector(inject, container, constructor); //创建构造方法上的参数注入器
		    } catch ( MissingDependencyException e ) {
			    exception = e;
		    }
		    parameterInjectors = parameters;

		    if (exception != null) {
			    if (inject != null && inject.required()) {
				    throw new DependencyException(exception);
			    }
		    }
		    injectors = container.injectors.get(implementation);//得到或者创建属性或者方法注入器
	    }
	
	//  省略了一些方法
	
	//创建并注入对象
    Object construct( InternalContext context, Class<? super T> expectedType ) {
			ConstructionContext<T> constructionContext =
					context.getConstructionContext(this);
                   
                   ... ...
                   
				// First time through...
				constructionContext.startConstruction();
					Object[] parameters =
							getParameters(constructor, context, parameterInjectors);//通过参数注入器得到参数对象
					t = constructor.newInstance(parameters); //创建对象
					constructionContext.setProxyDelegates(t);

				// Store reference. If an injector re-enters this factory, they'll
				// get the same reference.
				constructionContext.setCurrentReference(t);

				// Inject fields and methods.
				for ( Injector injector : injectors ) { //方法跟属性注入
					injector.inject(context, t);
				}
                
                ... ...
                
				return t;
		}
    }	
	
    
	
2，属性和方法注入器：Inject,FieldInjector,MethodInjector  




    FieldInjector 
    static class FieldInjector implements Injector {

		final Field field;
		final InternalFactory<?> factory;
		final ExternalContext<?> externalContext;

		public FieldInjector( ContainerImpl container, Field field, String name )
				throws MissingDependencyException {
			this.field = field;
			// ... 省去代码

			Key<?> key = Key.newInstance(field.getType(), name);
			factory = container.getFactory(key); //得到属性对象的工厂对象
			if (factory == null) {
				throw new MissingDependencyException(
						"No mapping found for dependency " + key + " in " + field + ".");
			}

			this.externalContext = ExternalContext.newInstance(field, key, container);
		}

		public void inject( InternalContext context, Object o ) {
			ExternalContext<?> previous = context.getExternalContext();
			context.setExternalContext(externalContext);
			try {
				field.set(o, factory.create(context)); //给属性赋上值完成注入
			} catch ( IllegalAccessException e ) {
				throw new AssertionError(e);
			} finally {
				context.setExternalContext(previous);
			}
		}
	}



    
MethodInject：   
 
 
    
    static class MethodInjector implements Injector {

		final Method method; //方法
		final ParameterInjector<?>[] parameterInjectors; //参数注入器
		
		/**
		 * 构造方法，创建参数注入器
		 **/
		public MethodInjector( ContainerImpl container, Method method, String name )
            // ... ...
            parameterInjectors = container.getParametersInjectors(
					method, method.getParameterAnnotations(), parameterTypes, name);
		}

		
		public void inject( InternalContext context, Object o ) {
			try {
				method.invoke(o, getParameters(method, context, parameterInjectors));//调用方法完成注入
			} catch ( Exception e ) {
				throw new RuntimeException(e);
			}
		}

	}
	

	
3，参数注入器：  




    static class ParameterInjector<T> {

		final ExternalContext<T> externalContext;
		final InternalFactory<? extends T> factory; //参数对象的工厂方法

		public ParameterInjector( ExternalContext<T> externalContext,
								  InternalFactory<? extends T> factory ) {
			this.externalContext = externalContext;
			this.factory = factory;
		}

		T inject( Member member, InternalContext context ) {
			ExternalContext<?> previous = context.getExternalContext();
			context.setExternalContext(externalContext);
			try {
				return factory.create(context);
			} finally {
				context.setExternalContext(previous);
			}
		}
	}




####总结####
经过上面源代码的分析总结：  

1. **所谓的注入并不是说把对象注入到容器中,而是通过容器将对象依赖的其他对象注入进入**,比如上面提到的Student对象依赖Teacher对象,注入的意思是通过容器将teacher对象注入到student对象中,而不是说将teacher跟student对象注入到容器中.  
2. **容器并不管理或者说直接管理对象**(这里的对象指类似上面说到的Student,Teacher这类依赖注入的对象),**容器中维护的是创建对象的工厂对象**(通过factory,或者是 constant 方法绑定的对象工厂),跟对象的依赖关系(窗口维护的各种注入器的集合> )。**factory 负责创建对象，Inject 负责处理对象的依赖关系。**  

3. 容器创建：  
1) **创建，封建，绑定，管理**对象工厂：  
  在不给定对象工厂的情况下，通过factory自动创建出一个根据对象的构造方法来创建实例的工厂对象 InternalFactory 。或者自己可以给定工厂对象，ContainerBuilder 会将这个工厂对象封装成一个 InternalFactory 对象。  
    InternalFactory 最后再将被封装成能根据Scope值自动智能创建的 InternalFactory  
2) 在寻找某个对象的工厂对象时，是通过对象的 type, 跟 Inject("name") 依赖的名字,Inject的名字不存在默认为default, 生成唯一的key来寻找的。  
3) ContainerBuilder 构造方法中 会添加一个容器的 InternalFactory 工厂对象,但是他并不新建的容器，只是返回当前环境的这个已经创建好的容器  
4) 容器所有管理的工厂对象需要在容器创建之前创建好（见ContainerBuild的create方法）。  
5) 容器创建后并不会马上处理对象的依赖关系，而是在调用Container的inject跟getInstance的时候才会逐渐建立好依赖关系，并将依赖关系通过 ReferenceCache 缓存起来。  

4. ContainerImpl 的 inject 并不是把对象注入到容器中， inject 方法可以处理非容器创建的对象的依赖关系，但前提是，他所依赖的对象是容器能够创建的(见 inject 方法执行分析)，getInstance 方法返回对象的前提是对象必须在容器中有绑定工厂对象，如果有依赖所依赖的对象也必须是容器能创建的。  

1） 依赖关系处理过程(也是相关注入器创建过程):  
首先创建的是构造器注入器(同时为这个构造器注入器创建好参数注入器)，然后创建这个对象需要的方法注入器(同时创建好方法的参数注入器)跟属性注入器，这些注入器会缓存起来  

2） getInstance的过程：  
通过对象的类型跟Inject的name,如果name不存，默认为default,生成key来得到对象的工厂对象，如果不存在这样的工厂对象，返回null,存在的话调用工厂对象的 create 方法创建对象(这里的创建并非说一定会创建出一个新的对象)，而在绑定工厂对象没给定自己定义的工厂对象时默认创建出来的工厂对象会使用对象的构造方法来创建对象，通过对象类型得到这个对象方法的构造方法注入器，如果不存在会执行上页面的创建注入器的过程。注入对象的创建是通过注入对象的类型跟依赖Inject("name")的名称来得到工厂对象来创建的  

3）inject 过程：  
inject 过程相对于 getInstance 过程来说只是不需要得到这个对象的工厂对象来创建对象，而是直接通过这个通过的构造方法注入器创建，但是他所依赖的对象的创建依然是通过对象工厂创建的。  



####容器的factory跟injector####
<span id="struts_container">容器结构简图</span>
![容器内部工厂对象跟注入器]( {{site.imagePath}}14_09_13_struts_ioc/struts_container.png)

- Factories: HashMap<Key<?>, InternalFactory<?>>, key为对象类型跟注入名生成的唯一Key
- Singletonfatories: ArrayList<InternalFactory<?>>
- Injectors: ReferenceCache<Class<?>, List<Injector>>, key 对象类型
- Constructors: ReferenceCache<Class<?>, List<Injector>>，key 对象类型

####factory封装过程####
<span id="factory_object">factory 封装示意图</span>
![struts object factroy]( {{site.imagePath}}14_09_13_struts_ioc/factory_object.png)
####注入过程总结####
<span id="inject_process">从容器得到实例或注入过程</span>
![容器内部工厂对象跟注入器]( {{site.imagePath}}14_09_13_struts_ioc/inject.png)

- 如果找不到getInstance对象的工厂方法，返回一个null,
- 如果找到依赖对象的工厂方法会返回异常，
- 如果找不到构造器注入器,就会先创建，并缓存起来,
- 如果是 inject方法，则不需要create instance 过程，直接从inject开始



  
－ 很长的笔记也写过很多，但是要把事情都讲明白太难，对于struts2容器这些源码的分析的思路并不像整理出来的笔记这样的一种顺序，等我看完了代码之后，我觉得可能这样的一种顺序更好理解一些。  
－ **有什么错误的地方请指正**  
－ **写这样的笔记是一个费神的体力活，还有被喷的危险，转载请指明出处**







	
	
