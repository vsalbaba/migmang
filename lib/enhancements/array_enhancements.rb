class Array

  def up;    copy = self.dup; copy[1] += 1; copy;end

  def down;  copy = self.dup; copy[1] -= 1; copy end

  def left;  copy = self.dup; copy[0] -= 1; copy end

  def right; copy = self.dup; copy[0] += 1; copy end
  # vyhazi prvky ktere nemaji vsechny souradnice mezi min a max.
  def only_those_on_board(min,max)
    self.delete_if do |position| 
                     position.all? {|coord| coord.between?(min,max) }
                   end
  end
  
  def neighbours
    [ self.up, self.down, self.left, self.right ].only_those_on_board
  end
end