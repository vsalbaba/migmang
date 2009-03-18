require 'qt4'
module View
  class Board < Qt::Widget
    SQUARES = 64
    SQUARE_SIDE = 60

    def initialize(parent = nil)
      @black_square = Qt::Pixmap.new()
      super
    end

    def paintEvent(event)
      p = Qt::Painter.new(self)
      SQUARES.times do |square|
        x = square % 8 
        y = square / 8 
        p.drawPixmap(x * SQUARE_SIDE, y * SQUARE_SIDE, #TODO nejaky obrazek)
      end
    end
  end
  
  class BoardTheme
=begin rdoc
Pokusi se nacist obrazek desky ze souboru. V souboru by mely byt 2 ctvercove obrazky nad sebou,
horni svetly a dolni tmavy.
=end    
    def load_board(path)
      big = QPixmap.new
      #pokud soubor neexistuje, vrat false
      return false unless big.load(path)
      half_size = big.height / 2
      #pokud horni a dolni obrazek nejsou ctverce, vrat false (obrazek v neplatnem formatu)
      return false unless half_size == big.width
      @white = big.copy(0, 0, half_size, half_size)
      @black = big.copy(0, half_size, half_size, half_size)
    end
  end
end