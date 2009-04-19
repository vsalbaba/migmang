class Manager
  attr_accessor :players, :board, :historian, :game_board
  def initialize
    initialize_board
    initialize_board_widget
    @players =  [nil, GuiPlayer.new(WHITE, @game_board), GuiPlayer.new(BLACK, @game_board)] #protoze WHITE je 1 = eliminuje se prepocitavani indexu do pole
    @game_board.show
    observe_players
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

  def update(player, move)
    if @board.on_move == @players.index(player) then
      @board.apply_move! @board.moves_for(@board.on_move)[move]
      @players[@board.on_move].pick_move(@board.moves_for(@board.on_move))
    end
  end
end