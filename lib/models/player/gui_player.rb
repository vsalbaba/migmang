require File.join(File.expand_path(File.dirname(__FILE__)), "abstract_player")

class GuiPlayer < AbstractPlayer
  attr_accessor :picked_move

  def initialize(color, board)
    super(color)
    @board = board
    @board.add_observer(self)
  end
  
  def pick_move(moves)
  end
  
  def update(who, move)
    if (who == @board) and (who.board.on_move == @color)
      move_picked move
    end
  end

  def move_picked(move)
    changed
    notify_observers(self, move)
  end
end