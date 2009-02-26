class Board

  def initialize(x, y)
    @x = x
    @y = y
    # je potreba volat s blokem, volani Array.new(@x, Array.new(@y, 0)) 
    # by byly vsechny polozky jen odkazy na to stejne pole
    @inner_representation = Array.new(@x) {|index| Array.new(@y, 0)}
  end

  def each_with_keys(&block)
    width, height = @x, @y
    for x in 0..width-1
      for y in 0..height-1
        yield x,y,self[x,y]
      end
    end
  end

  def [](x, y)
    raise "OutOfIndexError" unless x.between?(0, @x) or y.between?(0, @y)
    @inner_representation[x][y]
  end

  def []=(x,y,value)
    raise "OutOfIndexError" unless x.between?(0, @x) or y.between?(0, @y)
    @inner_representation[x][y]= value
  end

  def clear!
    @inner_representation = Array.new(@x) {|index| Array.new(@y, 0)}
  end
  
  def dup
    copy = Board.new(@x, @y)
    self.each_with_keys do |x, y, value|
      copy[x,y] = value
    end
    copy
  end
  
  def has?(object)
    @inner_representation.any?{|element| element.include?(object)}    
  end
end