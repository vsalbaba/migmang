require File.join(File.expand_path(File.dirname(__FILE__)), "require_farm")

app                     = Qt::Application.new(ARGV)
manager                 = Manager.new
window                  = View::MyWindow.new
window.game_board.board = manager.board
manager.game_board      = window.game_board
manager.players         = [GuiPlayer.new(WHITE, window.game_board), GuiPlayer.new(BLACK, window.game_board)]

Qt::Object.connect(window, SIGNAL('new_game()'), manager, SLOT('new_game()'))
Qt::Object.connect(window, SIGNAL('undo()'), manager, SLOT('undo()'))
Qt::Object.connect(window, SIGNAL('redo()'), manager, SLOT('redo()'))
Qt::Object.connect(window, SIGNAL('save_game(const QString&)'), manager, SLOT('save_game(const QString&)'))
Qt::Object.connect(window, SIGNAL('load_game(const QString&)'), manager, SLOT('load_game(const QString&)'))
window.show

app.exec