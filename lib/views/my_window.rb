module View
  class MyWindow < Qt::MainWindow
    attr_reader :game_board
    def initialize
      super
      # menu = Qt::MenuBar.new
      # file_menu = menu.addMenu("Soubor")
      @game_board = View::Board.new
      setCentralWidget(@game_board)

      create_actions
      create_menus
    end
    
    def create_actions
    end
    
    def create_menus
      @fileMenu = menuBar.addMenu("File")
      @editMenu = menuBar.addMenu("Edit")
      @helpMenu = menuBar.addMenu("Help")
    end
  end
end