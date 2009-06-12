require 'ruby-prof'
require 'lazy'

class MinimaxPlayer < AbstractPlayer
  attr_reader :games, :function
  include MoveEnhancements

  def initialize(color, function = 0)
    super(color)
    @function = function
    @functions = [:score, :advanced_score]
  end
  
  def compute_part
    if @computation_step == @computations.size
      computation_completed
    else
      RubyProf.resume
        value = demand(@computations[@computation_step])
      RubyProf.pause
      result = [value, @computation_step]
      @results[@computation_step] = result
      @computation_step += 1
      result
    end
  end
  
  def computation_completed
    maximal_value = @results.max{|a,b| a.first <=> b.first }.first
    array_of_results = @results.find_all{|a| a.first == maximal_value}
    result = array_of_results[rand(array_of_results.size)].last
    puts @games_evaluated
    @games_evaluated = 0
    profile = RubyProf.stop
    printer = RubyProf::GraphHtmlPrinter.new(profile)
    File.open("negas.html", "wb") do |file|
      printer.print(file)
    end
    changed
    notify_observers self, result
  end
  
  def pick_move(game,moves)
    RubyProf.start
    RubyProf.pause
    @computation_step = 0
    @games = moves.map do |move|
      game.apply_move(move)
    end
    @computations = []
    @games.size.times do |i|
      @computations[i] = promise do
        #minimax(games[i], 2)
        alfabeta @games[i], 1
        #negascout @games[i], 2
      end
    end

    @results = []
  end

private
=begin rdoc
pseudocode:
 function minimax(node, depth)
    if node is a terminal node or depth = 0
        return the heuristic value of node
    else
        let α := -∞
        foreach child of node                       { evaluation is identical for both players }
            let α := max(α, -minimax(child, depth-1))
        return α
=end
  def minimax(node, depth)
    if node.ended? or depth == 0
      return self.send(@functions[@function], node)
    else
      nodes = node.moves_for(node.on_move).map{|move|
        node.apply_move(move)
      }
      alpha = -100
      for child in nodes
        alpha = [alpha, -minimax(child, depth-1)].max
      end
      return alpha
    end
  end


=begin
function alphabeta(node, depth, α, β)         
    (* β represents previous player best choice - doesn't want it if α would worsen it *)
    if node is a terminal node or depth = 0
        return the heuristic value of node
    foreach child of node
        α := max(α, -alphabeta(child, depth-1, -β, -α))     
        (* use symmetry, -β becomes subsequently pruned α *)
        if β≤α
            break                             (* Beta cut-off *)
    return α

(* Initial call *)
alphabeta(origin, depth, -infinity, +infinity)
=end
  def alfabeta(node, depth, alpha = -100, beta = 100)
    if depth <= 0 or node.ended?
      return self.send(@functions[@function], node)
    end
    moves = node.moves_for(node.on_move).sort_by(&:size).reverse
    for move in moves
      child = node.apply_move(move)
      alpha = [alpha, -alfabeta(child, depth-1, -beta, -alpha)].max
      if beta <= alpha
        break
      end
    end
    return alpha
  end
  
=begin
function negascout(node, depth, α, β)
    if node is a terminal node or depth = 0
        return the heuristic value of node
    b := β                                          (* initial window is (-β, -α) *)
    foreach child of node
        a := -negascout (child, depth-1, -b, -α)
        if a>α
            α := a
        if α≥β
            return α                                (* Beta cut-off *)
        if α≥b                                      (* check if null-window failed high*)
           α := -negascout(child, depth-1, -β, -α)  (* full re-search *)
           if α≥β
               return α                             (* Beta cut-off *)    
        b := α+1                                    (* set new null window *)             
    return α
=end
  def negascout(node, depth, alpha = -100, beta = 100)
    if depth <= 0 or node.ended?
      return self.send(@functions[@function], node)
    end
    b = beta
    moves = node.moves_for(node.on_move).sort_by(&:size).reverse
    
    moves.each do |move|
      child = node.apply_move(move)
      a = -negascout(child, depth-1, -b, -alpha)
      alpha = a if a > alpha
      return alpha if alpha >= beta
      if alpha >= b then
        alpha = -negascout(child, depth-1, -beta, -alpha)
        return alpha if alpha >= beta
      end
      b = alpha + 1
    end
    return alpha
  end


#vraci cislo -100..100, cim vyssi, tim byl tah vedouci k teto desce lepsi
  def advanced_score(game)
    count
    my_figures = 0
    my_free_spaces = 0
    enemy_figures = 0
    enemy_free_spaces = 0
    game.board.each_with_keys do |x,y,key|
      if key == game.on_move
        my_figures += 1
        my_free_spaces += game.free_neighbours_count[[x,y]]
      elsif key == game.on_move.enemy
        enemy_figures += 1
        enemy_free_spaces += game.free_neighbours_count[[x,y]]
      end
    end
    result = (enemy_figures*2 - my_figures) + (enemy_free_spaces - my_free_spaces)
    return result
  end
  
  # def advanced_score(game)
  #   count
  #   evaluate_for = game.on_move.enemy
  #   #ohodnoceni desky
  #   enemy_figures = 0
  #   game.board.each_with_keys do |x,y,key|
  #     if key == game.on_move
  #       enemy_figures += 1
  #     end
  #   end
  #   number_of_moves = game.moves_for(evaluate_for).size
  #   return number_of_moves - enemy_figures*2
  # end
  
  def score(game)
    count
    0
  end
  
  def count
    @games_evaluated ||= 0
    @games_evaluated += 1
  end
end