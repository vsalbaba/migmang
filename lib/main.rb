require File.join(File.expand_path(File.dirname(__FILE__)), "require_farm")

app = Qt::Application.new(ARGV)

manager = Manager.new

game_board = View::Board.new
game_board.board = manager.board
game_board.show

app.exec