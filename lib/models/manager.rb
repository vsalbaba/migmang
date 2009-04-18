class Manager
  attr_accessor :players, :board, :historian
  def initialize
    initialize_board
    @players =  [nil, GuiPlayer.new(@board), GuiPlayer.new(@board)]
    observe_players
  end

  def initialize_board
    @board = MigMangBoard.new
    @board.populate!
    @historian = Historian.observe(@board)
  end

  def observe_players
    @players.each do |player|
      player.add_observer(self)
    end
  end
  
  def update(player, move)
    if @board.on_move == @players.index(player) then
      @board.apply_move! move
      @players[@board.on_move].pick_move(@board.moves_for(@board.on_move))
    end
  end
end