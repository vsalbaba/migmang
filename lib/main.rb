require 'rubygems'
require 'Qt4'
require File.join(File.expand_path(File.dirname(__FILE__)), "views/mig_mang_board")
require File.join(File.expand_path(File.dirname(__FILE__)), "models/mig_mang_board")
app = Qt::Application.new(ARGV)
board = MigMangBoard.new
board.populate!
game_board = View::Board.new
game_board.board = board
game_board.show
app.exec