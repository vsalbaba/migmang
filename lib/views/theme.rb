module View
=begin rdoc
  stara se o obrazky na desce
=end
  class Theme
  attr_reader :left_bottom, :left_top, :right_bottom, :right_top,
              :left, :right, :top, :bottom, :center,
              :black_piece, :white_piece, :piece,
              :highlight, :place_highlight, :remove_highlight, :best_move_highlight

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
      raise "#{path} does not exist" unless big.load(path)
      small_size = big.height / 2
      raise "#{path} has invalid proportions" unless small_size == big.width
      @white_piece = big.copy(0, 0, small_size, small_size)
      @black_piece = big.copy(0, small_size, small_size, small_size)
      @piece       = [white_piece, @black_piece]
      return true
    end

    def load_highlights(path)
      big = Qt::Pixmap.new
      return false unless big.load(path)
      small_size = big.height / 3
      return false unless small_size == big.width

      @highlight        = big.copy(0, 0 * small_size, small_size, small_size)
      @remove_highlight  = big.copy(0, 1 * small_size, small_size, small_size)
      @place_highlight = big.copy(0, 2 * small_size, small_size, small_size)
      @best_move_highlight = @highlight
      true
    end
  end
end