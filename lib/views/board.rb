module View
  class Board < Qt::Widget
    include Observable
    include MigMangBoardHelper
    FILE_PATH = File.dirname(__FILE__)
    
    attr_accessor :board, :white_gui, :black_gui, :best_move_highlight

    def initialize(parent = nil)
      super
      @theme = Theme.new
      load_graphic
      dehighlight
    end

    def paintEvent(event)
      painter = Qt::Painter.new(self)
      SQUARES.times do |square|
        board_x, board_y = get_tile_coords(square)
        actual_x, actual_y = get_actual_position(board_x, board_y)
        paint_game_things_at([board_x, board_y], [actual_x, actual_y], painter)
      end
      painter.end
    end

    def mouseDoubleClickEvent(event)
      case event.button
      when Qt::LeftButton:
        tile_x = event.x / SQUARE_SIDE
        tile_y = MAX_SIZE - (event.y / SQUARE_SIDE)

        case @destination_highlight.include? [tile_x, tile_y]
        when true:
          move = select_move(to_noted(@origin_highlight), to_noted(tile_x, tile_y))
      
          case @board.on_move
          when WHITE:
            white_gui.update(self, move) if white_gui && white_gui.respond_to?(:update)
          when BLACK:
            black_gui.update(self, move) if black_gui && black_gui.respond_to?(:update)
          end
          dehighlight
        when false:
          highlight_moves_from(tile_x, tile_y)
        end
        update
      end
    end
    
    def best_move_highlight=(move)
      @best_move_highlight=move
      update
      @best_move_highlight
    end

private
    def load_graphic
      @theme.load_squares(FILE_PATH + DESK_PATH)
      @theme.load_pieces(FILE_PATH + PIECES_PATH)
      @theme.load_highlights(FILE_PATH + HIGHLIGHT_PATH)
    end
  
    def paint_board_at(tile_coord, actual_coord, painter)
      pixmap = select_board_picture_for(tile_coord)
      painter.drawPixmap(actual_coord.first, actual_coord.last, pixmap)
    end
  
    def paint_game_things_at(tile_coord, actual_coord, painter)
      paint_board_at(tile_coord, actual_coord, painter)
      paint_pieces_at(tile_coord, actual_coord, painter)
      paint_destination_highlight_at(tile_coord, actual_coord, painter)
      paint_remove_highlight_at(tile_coord, actual_coord, painter)
      paint_best_move_highlight_at(tile_coord, actual_coord, painter)
    end
    
    def paint_best_move_highlight_at(tile_coord, actual_coord, painter)
      # p @best_move_highlight
      # p tile_coord
      # p @theme.best_move_highlight
      if @best_move_highlight.include?(tile_coord)
        painter.drawPixmap(actual_coord.first, actual_coord.last, @theme.best_move_highlight)
      end
    end

    def paint_remove_highlight_at(tile_coord, actual_coord, painter)
      if @remove_highlight.include?(tile_coord) then
        painter.drawPixmap(actual_coord.first, actual_coord.last, @theme.remove_highlight)
      end
    end

    def paint_pieces_at(tile_coord, actual_coord, painter)
      piece = @board[tile_coord.first,tile_coord.last]
      unless piece.empty?
        painter.drawPixmap(actual_coord.first, actual_coord.last, @theme.piece[piece -1])
      end
    end

    def paint_destination_highlight_at(tile_coord, actual_coord, painter)
      if @destination_highlight.include?(tile_coord) then
        painter.drawPixmap(actual_coord.first, actual_coord.last, @theme.place_highlight)
      end
    end

    def select_board_picture_for(tile_coord)
      tile_x = tile_coord.first
      tile_y = tile_coord.last
      case tile_x
      when 0:
        case tile_y
        when 0: @theme.left_bottom
        when 8: @theme.left_top
        else @theme.left
        end
      when 8:
        case tile_y
        when 0: @theme.right_bottom
        when 8: @theme.right_top
        else @theme.right
        end
      else
        case tile_y
        when 0: @theme.bottom
        when 8: @theme.top
        else @theme.center
        end
      end
    end

    def dehighlight
      @origin_highlight = @place_highlight = @remove_highlight = @destination_highlight = @best_move_highlight = []
    end

    def select_move(from, to)
      @moves.index{|move| (move.first[1] == from) and (move[1][1] == to)}
    end

    def highlight_moves_from(tile_x, tile_y)
      dehighlight
      @moves = @board.moves_for(@board.on_move)
      p @moves
      moves_begining_at([tile_x,tile_y], @moves).each do |move|
        highlight_move(move)
      end
    end

    def moves_begining_at(position, moves)
      moves.find_all do |move|
        move.first[1] == to_noted(position)
      end
    end

    def highlight_move(move)
      @origin_highlight = @board.from_noted(move.first[1])
      @place_highlight += move.find_all{|place_sub_move| place_sub_move.first == :place}.map{|place_sub_move| @board.from_noted(place_sub_move[1])}
      @remove_highlight += move.tail.find_all{|remove_sub_move| remove_sub_move.first == :remove}.map{|remove_sub_move| @board.from_noted(remove_sub_move[1])}
      @destination_highlight = @place_highlight #DANGER - zalozeno na pravidlech migmangu
    end
  end
end