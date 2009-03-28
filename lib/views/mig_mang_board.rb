require 'Qt4'
module View
  class Board < Qt::Widget
    attr_accessor :board
    SQUARES = 81
    SQUARE_SIDE = 60

    def initialize(parent = nil)
      super
      @theme = Theme.new
      unless @theme.load_squares(File.join(File.expand_path(File.dirname(__FILE__)), "themes/test.png"))
        Kernel.raise 'Board image not in the right format or missing'
      end
      unless @theme.load_pieces(File.join(File.expand_path(File.dirname(__FILE__)), "themes/pieces.png"))
        Kernel.raise 'Pieces image not in the right format or missing'
      end
    end
    
    def paintEvent(event)
      p = Qt::Painter.new(self)
      SQUARES.times do |square|
        x = square % 9
        y = square / 9 
        puts x, y
        pixmap = case x
        when 0:
          case y
          when 0: @theme.left_bottom
          when 8: @theme.left_top
          else @theme.left
          end
        when 8:
          case y
          when 0: @theme.right_bottom
          when 8: @theme.right_top
          else @theme.right
          end
        else
          case y
          when 0: @theme.bottom
          when 8: @theme.top
          else @theme.center
          end
        end
        p.drawPixmap(x*SQUARE_SIDE, 8*SQUARE_SIDE - y*SQUARE_SIDE, pixmap)
        unless board[x,y].empty?
          p.drawPixmap(x*SQUARE_SIDE, 8*SQUARE_SIDE - y*SQUARE_SIDE, @theme.piece[board[x,y] -1])
        end
      end
    end
 
    def mousePressEvent(event)
      case event.button
      when Qt::LeftButton:
        x = event.x / SQUARE_SIDE
        y = 8 - (event.y / SQUARE_SIDE)      
        @to_be_highlighted = [x, y]
      end
    end
    
    def mouseReleaseEvent(event)
      case event.button
      when Qt::LeftButton:
        x = event.x / SQUARE_SIDE
        y = 8 - (event.y / SQUARE_SIDE)
        highlighted = [x, y]
        @highlighted = highlighted if highlighted == @to_be_highlighted
        @to_be_highlighted = nil
      end
    end
   end
  
  
  
=begin rdoc
  stara se o obrazky na desce
=end
  class Theme
  attr_reader :left_bottom, :left_top, :right_bottom, :right_top, :left, :right, :top, :bottom, :center, :black_piece, :white_piece, :piece

=begin rdoc
Pokusi se nacist obrazek desky ze souboru. V souboru by melo byt 9 ctvercovych obrazku nad sebou
=end    
    def load_squares(path)
      big = Qt::Pixmap.new
      #pokud soubor neexistuje, vrat false
      return false unless big.load(path)
      pictures = [@left_bottom, @left_top, @right_bottom, @right_top, @left, @right, @top, @bottom, @center]
      small_size = big.height / pictures.count

      return false unless small_size == big.width
      @left_bottom  = big.copy(0, 0 * small_size, small_size, small_size)
      @left_top     = big.copy(0, 1 * small_size, small_size, small_size)
      @right_bottom = big.copy(0, 2 * small_size, small_size, small_size)
      @right_top    = big.copy(0, 3 * small_size, small_size, small_size)
      @left         = big.copy(0, 4 * small_size, small_size, small_size)
      @right        = big.copy(0, 5 * small_size, small_size, small_size)
      @top          = big.copy(0, 6 * small_size, small_size, small_size)
      @bottom       = big.copy(0, 7 * small_size, small_size, small_size)
      @center       = big.copy(0, 8 * small_size, small_size, small_size)
      return true
    end
    
    def load_pieces(path)
      big = Qt::Pixmap.new
      #pokud soubor neexistuje, vrat false
      return false unless big.load(path)
      small_size = big.height / 2
      return false unless small_size == big.width
      @white_piece = big.copy(0, 0, small_size, small_size)
      @black_piece = big.copy(0, small_size, small_size, small_size)
      @piece       = [white_piece, @black_piece]
      return true
    end
  end
end