class Manager < Qt::Object
  COMPUTATION_TIME_QUANTUM = 300
  attr_accessor :board, :historian, :game_board
  slots 'new_game()', 'undo()', 'redo()', 'load_game(const QString&)', 'save_game(const QString&)', 'change_player(int, int)', 'start_replay()', 'stop_replay()', 'next_replay_step()', 'show_best_move()', 'compute_part()'
  signals 'lock_board(bool)'
  
  def initialize
    super
    initialize_board
    @inner_players = []
    #pole nema 0ty prvek, protoze WHITE je 1 = eliminuje se prepocitavani indexu do pole
  end
  
  def compute_part
    on_move = @board.on_move
    if @inner_players[on_move].class != GuiPlayer
      @inner_players[on_move].compute_part
    end
  end
  
  def update(player, move)
    @game_board.update
    reset_computation_timer
    on_move = @board.on_move
        
    if on_move == @inner_players.index(player) then
      @board.apply_move! @board.moves_for(on_move)[move]

      on_move = @board.on_move
      @inner_players[on_move].pick_move(@board,@board.moves_for(on_move))

      start_computations_if_necessary

    end
  end
  
  def start_computations_if_necessary
    run = computer_player?
    emit lock_board(run)
    if run
      @computation_timer.start(COMPUTATION_TIME_QUANTUM)
    end
  end
  
  def computer_player?
    @inner_players[@board.on_move].class != GuiPlayer
  end
  
  def reset_computation_timer
    @computation_timer ||= Qt::Timer.new(self)
    Qt::Object.connect(@computation_timer, SIGNAL('timeout()' ), self, SLOT('compute_part()'))
    @computation_timer.stop
  end
  
  def players
    @inner_players.tail || []
  end
  
  def players=(players_in)
    self.white_player = players_in[0]
    self.black_player = players_in[1]
    players
  end
  
  def white_player=(player_in)
    set_player!(WHITE, player_in)
  end
  
  def black_player=(player_in)
    set_player!(BLACK, player_in)
  end
  
  def set_player!(color, player)
    puts "settin_player"
    deobserve_players
    @inner_players[color] = player
    set_players_to_game_board
    observe_players
    if color == @board.on_move
      inform_player(player)
    end
    @inner_players[color]
  end
  
  def inform_player(player)
    puts "informing player"
    reset_computation_timer
    on_move = @board.on_move
    @inner_players[on_move].pick_move(@board,@board.moves_for(on_move))
    start_computations_if_necessary
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
    inform_player(@board.on_move)
  end
  
  def redo
    # begin
      @historian.redo!
    # rescue
    #   puts "redo failed."
    #   p $ERROR_INFO
    # end
    @game_board.board = @board
    @game_board.update
  end
  
  def load_game(filename)
    @historian.load!(filename)
    @actual_game_filename = filename
  end
  
  def save_game(filename)
    @historian.save!(filename)
    @actual_game_filename = filename
  end
  
  def change_player(color, difficulty)
    if difficulty == 0 then
      player = GuiPlayer.new(color, @game_board)
    else
      player = MinimaxPlayer.new(color, difficulty - 1)
    end
    set_player!(color, player)
    player
  end
  
  def start_replay
    @replay_to = @historian.index
    @historian.index = -1
    @board = MigMangBoard.new.populate!
    @historian.game = @board
    @game_board.board = @board
    @game_board.update
    unless @replay_timer
      @replay_timer = Qt::Timer.new
      Qt::Object.connect(@replay_timer, SIGNAL('timeout()'), self, SLOT('next_replay_step()'))
    end
    @replay_timer.start(1000)
  end
  
  def next_replay_step
    puts "next_replay, #{@historian.index}, #{@replay_to}"
    if @historian.index < @replay_to
      self.redo
    else
      stop_replay
    end
  end
  
  def stop_replay
    puts "stop timer"
    @replay_timer.stop
  end
  
  def show_best_move
    moves = @board.moves_for(@board.on_move)
    best_move = moves[MinimaxPlayer.new(@board.on_move).pick_move(@board,moves)]
    p best_move
    best_move = best_move[0..1]
    best_move.map! do |move|
      @board.from_noted(move[1])
    end
    p best_move
    @game_board.best_move_highlight = best_move
  end

private
#gameboard je widget
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
