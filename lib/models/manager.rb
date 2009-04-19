class Manager
  attr_accessor :players, :board, :historian, :game_board
  def initialize
    initialize_board
    initialize_board_widget
    @players =  [nil, 
                 GuiPlayer.new(WHITE, @game_board), 
                 MinimaxPlayer.new(BLACK)] 
    #pole nema 0ty prvek, protoze WHITE je 1 = eliminuje se prepocitavani indexu do pole
    set_players_to_game_board
    @game_board.show
    observe_players
  end
  
  def update(player, move)
    if @board.on_move == @players.index(player) then
      @board.apply_move! @board.moves_for(@board.on_move)[move]
      @players[@board.on_move].pick_move(@board,@board.moves_for(@board.on_move))
    end
  end

private
  def set_players_to_game_board
    @game_board.white_gui = @players[WHITE]
    @game_board.black_gui = @players[BLACK]
  end
  
  def initialize_board_widget
    @game_board = View::Board.new
    @game_board.board = @board
  end

  def initialize_board
    @board = MigMangBoard.new
    @board.populate!
    @historian = Historian.observe(@board)
  end

  def observe_players
    @players.tail.each do |player|
      player.add_observer(self)
    end
  end


end
