require File.join(File.expand_path(File.dirname(__FILE__)), "abstract_player")
WHITE = 1
BLACK = 2
class MinimaxPlayer < AbstractPlayer
  def pick_move(moves)
    moves[rand(moves.size)]
  end
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
  def minimax(board, depth)
    if board.ended? or depth == 0
      return score(board)
    else
      nodes = board.moves_for(board.on_move).map{|move|
        board.apply_move(move)
      }
      alpha = -100
      for child in nodes
        alpha = [alpha, -miminax(child, depth - 1)].max
      end
      return alpha
    end
  end
  
  def score(board)
    if board.ended?
      board.on_move == board.winner ? return 100 : return -100
    else
      figures = 0
      board.board.each_with_keys do |x, y, key|
        if key == board.on_move
          figures += 1
        end
      end
      return figures
    end
  end
end