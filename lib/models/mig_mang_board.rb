require File.join(File.expand_path(File.dirname(__FILE__)), "board")
require File.join(File.expand_path(File.dirname(__FILE__)), "rules")
require File.join(File.expand_path(File.dirname(__FILE__)), "../enhancements/fixnum_enhancements")
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
  EMPTY    = 0
  WHITEMAN = 1
  BLACKMAN = 2
  MIN_SIZE = 0
  MAX_SIZE = 8

  include Observable
  include Rules
  include MigMangBoardHelper

  attr_accessor :board, :on_move

  def initialize
    @board = Board.new(9,9)
    @on_move = WHITEMAN
  end

=begin rdoc
vlozi na  desku figury v zakladnim postaveni
=end
  def populate!
    @board.clear!

    %w(a1 a2 a3 a4 a5 a6 a7 a8 a9 b1 c1 d1 e1 f1 g1 h1).each do |man|
      self[man] = WHITEMAN
    end

    %w(b9 c9 d9 e9 f9 g9 h9 i9 i8 i7 i6 i5 i4 i3 i2 i1).each do |man|
      self[man] = BLACKMAN
    end

    @on_move = WHITEMAN
    self
  end

=begin rdoc
selector policka na desce. Je mozne selektovat napr. 0,0 (jako v poli poli) nebo stringem, napr. "a1" (jako v normalni notace)
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
      case part[0]
      when :remove
        self[part[1]] = 0
      when :place
        self[part[1]] = part[2]
      end
    end

    if @on_move.white?
      @on_move = BLACKMAN
    else 
      @on_move = WHITEMAN
    end

    changed
    notify_observers :move, @board.dup, move
    self
  end

  def empty_neighbours_for(x,y)
    [x,y].neighbours(MIN_SIZE, MAX_SIZE).delete_if{|position|
      @board[position[0], position[1]].full?}
  end
end