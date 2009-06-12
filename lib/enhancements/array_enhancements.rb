class Array

  def up;    copy = self.dup; copy[1] += 1; copy;end

  def down;  copy = self.dup; copy[1] -= 1; copy end

  def left;  copy = self.dup; copy[0] -= 1; copy end

  def right; copy = self.dup; copy[0] += 1; copy end

  # vyhazi prvky ktere nemaji vsechny souradnice mezi min a max.
  def only_those_on_board(min,max)
    self.reject do |position| 
      not position.on_board?(min, max)
    end
  end
  
  def on_board?(min, max)
    all?{|coord| coord.between?(min,max)}
  end
  def neighbours(min, max)
    [ self.up, self.down, self.left, self.right ].only_those_on_board(min, max)
  end
  
  def tail
    self[1..-1]
  end
end