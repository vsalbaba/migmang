require 'Qt4'
require File.join(File.expand_path(File.dirname(__FILE__)), "views/dama_board")

app = Qt::Application.new(ARGV)

game_board = View::Board.new

game_board.show
app.exec