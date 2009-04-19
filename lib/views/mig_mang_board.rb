module View
  class Board < Qt::Widget
    attr_accessor :board
    SQUARES = 81
    SQUARE_SIDE = 60
    FULL_SIZE = 8*SQUARE_SIDE
    FILE_PATH = File.dirname(__FILE__)
    DESK_PATH = "/themes/simple.png"
    PIECES_PATH = "/themes/pieces.png"
    HIGHLIGHT_PATH = "/themes/composed-highlight.png"

    def initialize(parent = nil)
      super
      @theme = Theme.new
      @theme.load_squares(FILE_PATH + DESK_PATH)
      @theme.load_pieces(FILE_PATH + PIECES_PATH)
      @theme.load_highlights(FILE_PATH + HIGHLIGHT_PATH)

      @place_highlight = []
      @remove_highlight = []
      @destination_highlight = []
    end

    def paintEvent(event)
      puts "painting"
      painter = Qt::Painter.new(self)
      SQUARES.times do |square|
        board_x = square % 9
        board_y = square / 9
        pixmap = case board_x
        when 0:
          case board_y
          when 0: @theme.left_bottom
          when 8: @theme.left_top
          else @theme.left
          end
        when 8:
          case board_y
          when 0: @theme.right_bottom
          when 8: @theme.right_top
          else @theme.right
          end
        else
          case board_y
          when 0: @theme.bottom
          when 8: @theme.top
          else @theme.center
          end
        end
        actual_x = board_x*SQUARE_SIDE
        actual_y = FULL_SIZE - board_y*SQUARE_SIDE
        painter.drawPixmap(actual_x, actual_y, pixmap)
        unless @board[board_x,board_y].empty?
          painter.drawPixmap(actual_x, actual_y, @theme.piece[board[board_x,board_y] -1])
        end
        if @destination_highlight.include?([board_x,board_y]) then
          painter.drawPixmap(actual_x, actual_y, @theme.place_highlight)
        end
        if @remove_highlight.include?([board_x,board_y]) then
          painter.drawPixmap(actual_x, actual_y, @theme.remove_highlight)
        end
      end
    end

    def mouseDoubleClickEvent(event)
      case event.button
      when Qt::LeftButton:
        tile_x = event.x / SQUARE_SIDE
        tile_y = 8 - (event.y / SQUARE_SIDE)

        case @destination_highlight.include? [tile_x, tile_y]
        when true:
          move = select_move(@board.to_noted(@origin_highlight), @board.to_noted(tile_x, tile_y))
          @board.apply_move!(move)
          dehighlight
        when false:
          highliht_moves_from(tile_x, tile_y)
        end
        update
      end
    end

private
    def dehighlight
      @origin_highlight = @place_highlight = @remove_highlight = @destination_highlight = []
    end

    def select_move(from, to)
      move = @moves.find{|move| (move.first[1] == from) and (move[1][1] == to)}
    end

    def highliht_moves_from(tile_x, tile_y)
      dehighlight
      @moves = @board.moves_for(@board.on_move)
      moves_begining_at([tile_x,tile_y], @moves).each do |move|
        highlight_move(move)
      end
    end

    def moves_begining_at(position, moves)
      moves.find_all do |move|
        move.first[1] == @board.to_noted(position)
      end
    end

    def highlight_move(move)
      @origin_highlight = @board.from_noted(move.first[1])
      @place_highlight += move.find_all{|sub_move| sub_move.first == :place}.map{|sub_move| @board.from_noted(sub_move[1])}
      @remove_highlight += move.tail.find_all{|sub_move| sub_move.first == :remove}.map{|sub_move| @board.from_noted(sub_move[1])}
      @destination_highlight = @place_highlight #DANGER - zalozeno na pravidlech migmangu
    end
  end
end