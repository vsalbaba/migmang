require File.join(File.expand_path(File.dirname(__FILE__)), "abstract_player")

class GuiPlayer < AbstractPlayer
  attr_accessor :picked_move

  def initialize
  end
  
  def pick_move
    
  end
  
  def move_picked
    changed
    notify_observers(self, @picked_move)
  end
  
end