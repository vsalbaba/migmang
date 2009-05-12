class Manager < Qt::Object
  attr_accessor :board, :historian, :game_board
  slots 'new_game()', 'undo()', 'redo()', 'load_game(const QString&)', 'save_game(const QString&)', 'change_player(int, int)'
  
  def initialize
    super
    initialize_board
    @inner_players = []
    #pole nema 0ty prvek, protoze WHITE je 1 = eliminuje se prepocitavani indexu do pole
  end
  
  def update(player, move)
    if @board.on_move == @inner_players.index(player) then
      @board.apply_move! @board.moves_for(@board.on_move)[move]
      @inner_players[@board.on_move].pick_move(@board,@board.moves_for(@board.on_move))
    end
  end
  
  def players
    @inner_players.tail || []
  end
  
  def players=(players_in)
    self.white_player = players_in[0]
    self.black_player = players_in[1]
    p players
    players
  end
  
  def white_player=(player_in)
    p "youuuuu"
    set_player!(WHITE, player_in)
  end
  
  def black_player=(player_in)
    set_player!(BLACK, player_in)
  end
  
  def set_player!(color, player)
    deobserve_players
    @inner_players[color] = player
    set_players_to_game_board
    observe_players
    @inner_players[color]
  end

  def new_game
    initialize_board
    @game_board.board = @board
    @game_board.update
  end
  
  def undo
    begin
      @historian.undo!
    rescue
      puts "undo failed."
    end
    @game_board.board = @board
    @game_board.update
  end
  
  def redo
    begin
      @historian.redo!
    rescue
      puts "redo failed."
    end
    @game_board.board = @board
    @game_board.update
  end
  
  def load_game(filename)
    puts "yay, " + filename
    @historian.load!(filename)
    @actual_game_filename = filename
  end
  
  def save_game(filename)
    puts "yay, " + filename
    @historian.save!(filename)
    @actual_game_filename = filename
  end
  
  def change_player(color, difficulty)
    if difficulty == 0 then
      player = GuiPlayer.new(color, @game_board)
    else
      player = MinimaxPlayer.new(color, difficulty)
    end
    set_player!(color, player)
    player
  end

private
  def set_players_to_game_board
    @game_board.white_gui = @inner_players[WHITE]
    @game_board.black_gui = @inner_players[BLACK]
  end
  
  def initialize_board
    @board = MigMangBoard.new
    @board.populate!
    @historian = Historian.observe(@board)
  end
  
  def deobserve_players
    players.each do |player|
      player.delete_observer(self)
    end
  end

  def observe_players
    players.each do |player|
      player.add_observer(self)
    end
  end
end
