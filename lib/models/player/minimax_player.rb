class MinimaxPlayer < AbstractPlayer
  attr_reader :games, :depth
  include MoveEnhancements

  def initialize(color)
    super(color)
    @depth = 1
  end
  
  def pick_move(game,moves)
    puts "AI"
    @games = moves.map do |move|
      game.apply_move(move)
    end
    scores = @games.map do |game|
      alphabeta(game, @depth*2)
    end
    result = scores.index(scores.max)
    changed
    notify_observers self, result
    return result
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
      return score(node)
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
int AlfaBeta(Pozice p, int h, int alfa, int beta) {
  if (h <= 0 || KoncovaPozice(p)) /* pokud je to poslední nebo koncová pozice, */
    return OhodnotitPozici(p); /* tak ji ohodnoť */
  tahy = GenerujTahy(p); /* generuj tahy pro aktuální pozici */
  for i = 1 to size(tahy) do { /* cyklus pres všechny tahy */
    ProvedTah(p); /* zahraj tah */
/* propočtem do hloubky zjisti ohodnocení z hlediska soupeře */
    int hodnota = -AlfaBeta(p, h – 1, -beta, -alfa);
    ProvedTahZpet(tah[i], p); /* zahraj tah zpět */
    if (hodnota >= beta)
      return beta; /* při tomto návratu dojde k úspoře */
    if (hodnota > alfa) /* pokud je vrácená hodnota lepší, než dosud nalezená, tak si ji ulož */
      alfa = hodnota;
  }
  return alfa;
}
=end
  def alphabeta(node, depth, alpha = -100, beta = 100)
    if depth <= 0 or node.ended?
      return score(node)
    end
    moves = node.moves_for(node.on_move)
    for move in moves
      node.apply_move!(move)
      value = -alphabeta(node, depth-1, -beta, -alpha)
      node.apply_move!(reverse_move(move))
      if (value >= beta)
        return beta
      end
      alpha = value if (value > alpha)
    end
    return alpha
  end
  
#vraci cislo -100..100, cim vyssi, tim byl tah vedouci k teto desce lepsi
  def score(game)
    if game.on_move.white?
      evaluate_for = BLACK
    else
      evaluate_for = WHITE
    end
    
    if game.winner == evaluate_for
      return 100
    elsif game.winner == game.on_move
      return -100
    end
    #ohodnoceni desky
    enemy_figures = 0
    game.board.each_with_keys do |x,y,key|
      if key == game.on_move
        enemy_figures += 1
      end
    end
    return -enemy_figures
  end
end