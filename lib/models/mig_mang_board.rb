require File.join(File.expand_path(File.dirname(__FILE__)), "../enhancements/mig_mang_board_helper")
require 'observer'
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

  attr_accessor :board, :on_move

  def initialize
    @board = Board.new(9,9)
    @on_move = WHITE
  end

=begin rdoc
vlozi na  desku figury v zakladnim postaveni
=end
  def populate!
    @board.clear!

    %w(a1 a2 a3 a4 a5 a6 a7 a8 a9 b1 c1 d1 e1 f1 g1 h1).each do |man|
      self[man] = WHITE
    end

    %w(b9 c9 d9 e9 f9 g9 h9 i9 i8 i7 i6 i5 i4 i3 i2 i1).each do |man|
      self[man] = BLACK
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
      @board[normal.first, normal.last] = key2_or_value
    elsif [key1, key2_or_value].all? {|key| key.kind_of?(Integer) }
      @board[key1, key2_or_value] = value
    end
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
    [board_x,board_y].neighbours(MIN_SIZE, MAX_SIZE).delete_if{|position|
      @board[position[0], position[1]].full?}
  end
end