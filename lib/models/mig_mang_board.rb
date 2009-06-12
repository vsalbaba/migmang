require File.join(File.expand_path(File.dirname(__FILE__)), "../enhancements/mig_mang_board_helper")
=begin rdoc
Matice hraci desky. Policka jsou polozky v matici, jejich hodnota urcuje
jaka je na nich figurka.
* 0 - prazdne
* 1 - bila figura
* 2 - cerna figura
=end
class MigMangBoard
  include Observable
  include Rules
  include MigMangBoardHelper

  attr_accessor :board, :on_move, :free_neighbours_count

  def initialize
    @board = Board.new(9,9)
    @on_move = WHITE
    @free_neighbours_count = {}
  end

=begin rdoc
vlozi na  desku figury v zakladnim postaveni
=end
  def populate!
    @board.clear!
    2.times do #dvakrat pro spravny update free_neighbours_count
      %w(a1 a2 a3 a4 a5 a6 a7 a8 a9 b1 c1 d1 e1 f1 g1 h1).each do |man| #a1 a2 a3 a4 a5 a6 a7 a8 a9 b1 c1 d1 e1 f1 g1 h1
        self[man] = WHITE
      end
  
      %w(b9 c9 d9 e9 f9 g9 h9 i9 i8 i7 i6 i5 i4 i3 i2 i1).each do |man| #b9 c9 d9 e9 f9 g9 h9 i9 i8 i7 i6 i5 i4 i3 i2 i1
        self[man] = BLACK
      end
    end
    @on_move = WHITE
    self
  end

=begin rdoc
selector policka na desce. Je mozne selektovat napr. 0,0 (jako v poli poli) nebo stringem, napr. "a1" (jako v normalni notaci)
=end
  def [](key1, key2 = nil)
    if key1.kind_of?(String)
      normal = from_noted key1
      @board[normal.first, normal.last]
    elsif key1.kind_of?(Array)
      @board[key1.first, key1.last]
    elsif [key1, key2].all? {|key| key.kind_of?(Integer) }
      @board[key1, key2]
    end
  end

  def []=(key1, key2_or_value, value = nil)
    if key1.kind_of?(String)
      normal = from_noted key1
      x = normal.first
      y = normal.last
      stone_value = key2_or_value
    elsif [key1, key2_or_value].all? {|key| key.kind_of?(Integer) }
      x = key1
      y = key2_or_value
      stone_value = value
    end
    @board[x,y] = stone_value
    position = [x,y]
    up = position.up
    down = position.down
    left = position.left
    right = position.right
    
    @free_neighbours_count[ position ] = empty_neighbours_for(x,y).count
    @free_neighbours_count[ up ] = empty_neighbours_for(up[0], up[1]).count if up.on_board?(MIN_SIZE, MAX_SIZE)
    @free_neighbours_count[ down ] = empty_neighbours_for(down[0], down[1]).count if down.on_board?(MIN_SIZE, MAX_SIZE)
    @free_neighbours_count[ left ] = empty_neighbours_for(left[0], left[1]).count if left.on_board?(MIN_SIZE, MAX_SIZE)
    @free_neighbours_count[ up ] = empty_neighbours_for(right[0], right[1]).count if right.on_board?(MIN_SIZE, MAX_SIZE)
  end
  
=begin rdoc
aplikuje konstruktivne tah na desku
 vraci novou desku.
Destruktivni verzi je +apply_move!+
=end
  def apply_move(move)
    copy = MigMangBoard.new
    copy.on_move = @on_move
    copy.board = @board.dup
    copy.free_neighbours_count = @free_neighbours_count
    copy.apply_move!(move)
  end

=begin rdoc
 tah je pole poli ve formatu
  [:remove, pole, figura] nebo [:place, pole, figura]
Pri odbrani tahu je treba uvadet jakou figuru odebirame, abysme mohli pak provadet jednoduse undo
Konstruktivni verzi je apply_move
=end
  def apply_move!(move)
    for part in move
      what_to_do = part[0]
      where_to_apply = part[1]
      case what_to_do
      when :remove
        self[where_to_apply] = 0
      when :place
        self[where_to_apply] = part[2]
      end
    end

    if @on_move.white?
      @on_move = BLACK
    else 
      @on_move = WHITE
    end

    changed
    notify_observers self, move
    self
  end

  def empty_neighbours_for(board_x,board_y)
    [board_x, board_y].neighbours(MIN_SIZE, MAX_SIZE).delete_if{|e| @board[e[0],e[1]].full?}
  end
end