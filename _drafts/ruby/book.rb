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

