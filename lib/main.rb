require File.join(File.expand_path(File.dirname(__FILE__)), "require_farm")

app                     = Qt::Application.new(ARGV)
manager                 = Manager.new()
window                  = View::MyWindow.new
window.game_board.board = manager.board
manager.game_board      = window.game_board
manager.players         = [GuiPlayer.new(WHITE, window.game_board), MinimaxPlayer.new(BLACK)]


window.show

app.exec