require File.join(File.expand_path(File.dirname(__FILE__)), "../controllers/dama_board_controller")

class DamaBoardController
  attr_accessor :dama_board
  def new_game!
    @dama_board = Board.new
    @dama_board.new_game!
  end
end