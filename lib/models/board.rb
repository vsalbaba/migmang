class Board

  def initialize(x_size, y_size)
    @x_size = x_size
    @y_size = y_size
    # je potreba volat s blokem, volani Array.new(@x, Array.new(@y_size, 0)) 
    # by byly vsechny polozky jen odkazy na to stejne pole
    @inner_representation = Array.new(@x_size) {|index| Array.new(@y_size, 0)}
  end

  def each_with_keys(&block)
    width, height = @x_size, @y_size
    for x_coord in 0..width-1
      for y_coord in 0..height-1
        yield x_coord,y_coord,self[x_coord,y_coord]
      end
    end
  end

  def [](x_coord, y_coord)
    raise "OutOfIndexError" unless x_coord.between?(0, @x_size) or y_coord.between?(0, @y_size)
    @inner_representation[x_coord][y_coord]
  end

  def []=(x_coord,y_coord,value)
    raise "OutOfIndexError" unless x_coord.between?(0, @x_size) or y_coord.between?(0, @y_size)
    @inner_representation[x_coord][y_coord]= value
  end

  def clear!
    @inner_representation = Array.new(@x_size) {|index| Array.new(@y_size, 0)}
  end
  
  def dup
    copy = Board.new(@x_size, @y_size)
    self.each_with_keys do |x_coord, y_coord, value|
      copy[x_coord,y_coord] = value
    end
    copy
  end
  
  def has?(object)
    @inner_representation.any?{|element| element.include?(object)}    
  end
end