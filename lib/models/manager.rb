class Manager
  attr_accessor :board, :historian, :game_board
  def initialize()
    initialize_board
    @inner_players = []
    #pole nema 0ty prvek, protoze WHITE je 1 = eliminuje se prepocitavani indexu do pole
  end
  
  def update(player, move)
    puts "hi"
    if @board.on_move == @inner_players.index(player) then
      @board.apply_move! @board.moves_for(@board.on_move)[move]
      @inner_players[@board.on_move].pick_move(@board,@board.moves_for(@board.on_move))
    end
  end
  
  def players
    @inner_players.tail || []
  end
  
  def players=(players_in)
    deobserve_players
    @inner_players[1] = players_in[0]
    @inner_players[2] = players_in[1]
    set_players_to_game_board
    observe_players
    players
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
      delete_observer(player)
    end
  end

  def observe_players
    players.each do |player|
      player.add_observer(self)
    end
  end
end
