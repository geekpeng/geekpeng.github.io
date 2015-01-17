Hash 是一个 key => value 的集合, key 唯一. Hash 也叫关联数组. Hash 跟 Array 非常相似.
Array 的 key 是一个数字类型, Hask 的 key 可以任何的 object 类型.
Hash 按 key 的顺序枚举 values
Hash 非常容易通过下面的表示式隐式创建:  
    grades = {"jane Doe" => 10, "jim Doe" => 6}
使用 符号表达式(symbols) 作为 key 创建 Hash:
    options = { :font_size => 10, :font_family => "Arial" },
然后它可以简写成: 
    options = { font_size: 10, font_family: "Arial" },
通过 symbols 访问 Hash 的 value
    options[:font_size]

通过 new 显示创建 Hash
    grades = Hash.new
    grades["Dorothy Doe"] = 9
    grades["Dorothy Doe"] # => 9
    grades["hello"] # => nil

默认情况下通过 Hash 通过 key 访问 value , 如果这个 key 没有与值关联, 默认返回 nil, 也可以创建 Hash 的时候指定默认值:
    grades = Hash.new(0)
    grades["hello"] # => 0
    #或者
    grades = Hash.new
    grades.default = 0
    grades["hello"] # => 0

Hash 也常用来作为方法的命名参数

    Person.create(name: "John Doe", age: 27) # => 这里等价于 Person.create({name: "john Doe", age: 27}).

    def self.create(params)
      @name = params[:name]
      @age  = params[:age]
    end


Hash Keys
两个对象引用同一个 hask key, 那么它们的 hask value 是相等的, 这两个对象 eql? 返回true

我们有可将自己定将的一个 class 作为一个 Hask 的 key, 重写 hash 跟 eql? 方法, 非常有用.

    class Book
      
      attr_reader :author, :title
      
      def initialize(author, title)
        @author = author
        @title = title
      end
      
      def ==(other)
        self.class === other and
          other.author == @author and
          other.title == @title
      end
      
      alias eql? ==
      
      def hash
        @author.hash ^ @title.hash
      end
      
    end

    book1 = Book.new 'matz', 'Ruby in a Nutshell'
    book2 = Book.new 'matz', 'Ruby in a Nutshell'

    reviews = {}

    reviews[book1] = 'Great reference!'
    reviews[book2] = 'Nice and compact!'

    puts(book1.eql? book2) # => true

    puts(reviews.length) #=> 1 Hask key 是唯一的

    puts(reviews[book1]) # => 'Nice and compact!'
    puts(reviews[book2]) # => 'Nice and compact!'


Hash 常用的方法:
1, 公共的类方法:
Hash[key,value,...]
Hash["a",2,"b",4] #=>创建一个hash, {"a"=>2, "b"=>4}
Hash[[[key,value],...]]
Hash[["a",2],["b",4]] #=>创建了一个Hash, {"a"=>2,"b"=>4}
Hash[Object]

try_convert(obj) # 转成 hash
























