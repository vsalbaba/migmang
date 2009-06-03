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
Qt::Object.connect(window, SIGNAL('start_replay()'), manager, SLOT('start_replay()'))
Qt::Object.connect(window, SIGNAL('stop_replay()'), manager, SLOT('stop_replay()'))
Qt::Object.connect(window, SIGNAL('save_game(const QString&)'), manager, SLOT('save_game(const QString&)'))
Qt::Object.connect(window, SIGNAL('load_game(const QString&)'), manager, SLOT('load_game(const QString&)'))
Qt::Object.connect(window, SIGNAL('change_player(int, int)'), manager, SLOT('change_player(int, int)'))
Qt::Object.connect(window, SIGNAL('show_best_move()'), manager, SLOT('show_best_move()'))

window.resize 550, 580
window.show

app.exec