require File.join(File.expand_path(File.dirname(__FILE__)), "../enhancements/array_enhancements")

module Rules
  EMPTY    = 0
  WHITEMAN = 1
  BLACKMAN = 2
  MAX_SIZE = 8
  MIN_SIZE = 0
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
=begin rdoc
vraci true/false pokud hra skoncila (ma viteze)
=end
  def ended?
    !!winner
  end
=begin rdoc
vraci viteze hry (konstanty WHITE nebo BLACK), nebo nil pokud hra viteze nema
=end
  def winner
    return WHITEMAN unless board.has?(BLACKMAN)
    return BLACKMAN unless board.has?(WHITEMAN)
    return nil
  end

private
  def generate_for(x_in,y_in)
    start = [x_in, y_in]
    stone = self[x_in, y_in]
    if is_alone?(stone) then
      generate_without_jumps(x_in, y_in, stone)
    else
      if free_neighbours_count[start] == 4 then #vsechna pole okolo jsou prazdna, budeme moci brat pouze uveznenim, ne preskokem - stejne jako kdyby bylo figur na hraci desce vic. Ale pokud se to deje na kraji, je vsechna pole okolo budou volna ale bude jich mene nez 4 - nutno osetrit niz
        generate_without_jumps(x_in, y_in, stone)
      else
        neighbours = start.neighbours(MIN_SIZE,MAX_SIZE)
        start_move = [:remove, to_noted(x_in,y_in), stone]
        
        result = neighbours.map do |neighbour|
          if self[neighbour].empty? then #pripad kdy na policku nikdo neni a muzeme se na nej pohnout a pripadne nekoho zajmout
            generate_for_move_without_jumps(start_move, neighbour, stone)
          elsif self[neighbour].enemy_to?(stone) then
            generate_for_move_with_jumps(start, start_move, neighbour, stone)
          end
        end
        result.compact
      end
    end
  end
  
  def generate_for_move_with_jumps(from, from_move, jumped, stone)

    to = case jumped
    when from.up:
      jumped.up
    when from.down:
      jumped.down
    when from.left:
      jumped.left
    when from.right:
      jumped.right
    end
    # puts to.on_board?(MIN_SIZE, MAX_SIZE), to.empty?
    if to.on_board?(MIN_SIZE, MAX_SIZE) and self[to].empty? then
      [from_move, [:place, to_noted(to), stone], [:remove, to_noted(jumped), self[jumped]]]
    end
  end
  
  def is_alone?(stone)
    figures = 0
    board.each_with_keys do |x, y, figure|
      if figure == stone
        figures += 1
        if figures > 1
          break
        end
      end
    end
    figures > 1
  end
  
  def generate_without_jumps(x_in, y_in, stone)
    moves = empty_neighbours_for(x_in,y_in)
    from = [:remove, to_noted(x_in,y_in), stone]
    moves.map do |to|
      generate_for_move_without_jumps(from, to, stone)
    end
  end
  
  def generate_for_move_without_jumps(from, to, stone)
    to_part = [:place, to_noted(to), stone]
    this_move = [from, to_part]
    # je potreba obejit vsechny sousedy policka na ktere jsme tahli a zjistit,
    # jestli jejich jediny volny soused je policko na ktere jsme tahli.
    to.neighbours(MIN_SIZE,MAX_SIZE).each do |neighbour|
      #p free_neighbours_count
      if self[neighbour].enemy_to?(stone) and free_neighbours_count[[neighbour[0], neighbour[1]]] == 1
        this_move << [:remove, to_noted(neighbour), self[neighbour]]
      end
    end
    this_move
  end

  def can_move?(x,y)
    ![x,y].neighbours(MIN_SIZE, MAX_SIZE).all? do |coord|
      board[coord[0], coord[1]].full?
    end
  end
end