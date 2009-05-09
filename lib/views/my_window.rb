module View
  class MyWindow < Qt::MainWindow
    signals 'new_game()', 'load_game(const QString&)', 'save_game(const QString&)', 'undo()', 'redo()'
    slots 'save()', 'load()', 'white_computer_1()', 'white_human()' 'white_computer_2()', 'black_computer_1()', 'black_human()' 'black_computer_2()'
    attr_reader :game_board
    def initialize
      super
      @game_board = View::Board.new
      setCentralWidget(@game_board)

      create_actions
      create_menus
    end

    def save
      if filename = Qt::FileDialog.getSaveFileName(self) then
        emit save_game(filename)
      end
    end

    def load
      if filename = Qt::FileDialog.getOpenFileName(self) then
        emit load_game(filename)
      end
    end

    def white_human
    end

    def white_computer_1
    end

    def white_computer_2

    end

    def white_human
    end


    def black_human

    end

    def black_computer_1
    end

    def black_computer_2

    end
private
    def create_actions
      @new_action = Qt::Action.new("New", self)
      Qt::Object.connect(@new_action, SIGNAL('triggered()'), self, SIGNAL('new_game()'))

      @load_action = Qt::Action.new("Load", self)
      Qt::Object.connect(@load_action, SIGNAL('triggered()'), self, SLOT('load()'))

      @save_action = Qt::Action.new("Save", self)
      Qt::Object.connect(@save_action, SIGNAL('triggered()'), self, SLOT('save()'))

      @quit_action = Qt::Action.new("Quit", self)
      Qt::Object.connect(@quit_action, SIGNAL('triggered()'), self, SIGNAL('quit()'))

      @undo_action = Qt::Action.new("Undo", self)
      Qt::Object.connect(@undo_action, SIGNAL('triggered()'), self, SIGNAL('undo()'))

      @redo_action = Qt::Action.new("Redo", self)
      Qt::Object.connect(@redo_action, SIGNAL('triggered()'), self, SIGNAL('redo()'))

      @white_human_action = Qt::Action.new("Human", self)
      Qt::Object.connect(@white_human_action, SIGNAL('triggered()'), self, SLOT('white_human()'))

      @white_computer_action_1 = Qt::Action.new("Computer - easy", self)
      Qt::Object.connect(@white_computer_action_1, SIGNAL('triggered()'), self, SLOT('white_computer_1()'))

      @white_computer_action_2 = Qt::Action.new("Computer - hard", self)
      Qt::Object.connect(@white_computer_action_2, SIGNAL('triggered()'), self, SLOT('white_computer_2()'))

      @black_human_action = Qt::Action.new("Human", self)
      Qt::Object.connect(@black_human_action, SIGNAL('triggered()'), self, SLOT('black_human()'))

      @black_computer_action_1 = Qt::Action.new("Computer - easy", self)
      Qt::Object.connect(@black_computer_action_1, SIGNAL('triggered()'), self, SLOT('black_computer_1()'))

      @black_computer_action_2 = Qt::Action.new("Computer - hard", self)
      Qt::Object.connect(@black_computer_action_2, SIGNAL('triggered()'), self, SLOT('black_computer_2()'))
    end

    def create_menus
      create_file_menu
      create_edit_menu
      create_players_menu
      create_help_menu
    end

    def create_file_menu
      @file_menu = menuBar.addMenu("File")
        @file_menu.addAction(@new_action)
        @file_menu.addAction(@save_action)
        @file_menu.addAction(@load_action)
        @file_menu.addAction(@quit_action)
    end

    def create_edit_menu
      @edit_menu = menuBar.addMenu("Edit")
        @edit_menu.addAction(@undo_action)
        @edit_menu.addAction(@redo_action)
    end

    def create_help_menu
      @helpMenu = menuBar.addMenu("Help")
    end

    def create_players_menu
      @players_menu = menuBar.addMenu("Players")
        @white_player_menu = @players_menu.addMenu("White")
          @white_player_menu.addAction(@white_human_action)
          @white_player_menu.addAction(@white_computer_action_1)
          @white_player_menu.addAction(@white_computer_action_2)
        @black_player_menu = @players_menu.addMenu("Black")
          @black_player_menu.addAction(@black_human_action)
          @black_player_menu.addAction(@black_computer_action_1)
          @black_player_menu.addAction(@black_computer_action_2)
    end
  end
end