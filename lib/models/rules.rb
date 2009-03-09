require File.join(File.expand_path(File.dirname(__FILE__)), "../enhancements/array_enhancements")

module Rules
  EMPTY    = 0
  WHITEMAN = 1
  BLACKMAN = 2
=begin rdoc
vygeneruje vsechny mozne tahy pro jednoho hrace
=end
  def moves_for(player_color)
    moves = Array.new
    board.each_with_keys do |x, y, value|
      if value.eql?(player_color)
        moves.concat generate_for(x,y)
      end
    end
    moves
  end

  def ended?
    !!winner
  end

  def winner
    return WHITEMAN unless board.has?(BLACKMAN)
    return BLACKMAN unless board.has?(WHITEMAN)
    return nil
  end

  def draw!

  end

private
  def generate_for(x,y)
    moves = empty_neighbours_for(x,y)
    moves.map{|move|
      this_move = [[:remove, to_noted(x,y), self[x, y]], [:place, to_noted(move), self[x,y]]]
      # je potreba obejit vsechny sousedy policka na ktere jsme tahli a zjistit,
      # jestli jejich jediny volny soused je policko na ktere jsme tahli.
      move.neighbours(0,9).each do |neighbour|
        if self[neighbour].enemy_to?(self[x, y]) and empty_neighbours_for(neighbour.first, neighbour.last) == [x,y]
          this_move << [:remove, to_noted(move), self[move]]
        end
      end
    }
  end

  def can_move?(x,y)
    ![x,y].neighbours(0,9).all? do |coord|
      board[coord[0], coord[1]].full?
    end
  end
end