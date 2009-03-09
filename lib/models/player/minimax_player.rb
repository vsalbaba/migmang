require File.join(File.expand_path(File.dirname(__FILE__)), "abstract_player")

class MinimaxPlayer < AbstractPlayer
  def pick_move(moves)
    moves[rand(moves.size)]
  end
=begin rdoc
pseudocode
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
      leafs = board.moves_for(board.on_move).map{|move|
        board.apply_move(move)
      }
      alpha = -100
      for leaf in leafs
        alpha = [alpha, -miminax(leaf, depth - 1)].max
      end
      return alpha
    end
  end
end