module MigMangBoardHelper
	def from_noted(string)
		[string[0]-97, string[1].chr.to_i-1]
  end
=begin rdoc
takes 1 or 2 arguments - first argument is x coord or array [x, y] - second is optional y coord.
=end
  def to_noted(x,y = nil)
		return "#{(97+x).chr}#{y+1}" if y
		return "#{(97+x[0]).chr}#{x[1]+1}"
  end

  def get_tile_coords(square_number)
    [square_number % SQUARES_PER_SIDE, square_number / SQUARES_PER_SIDE]
  end

  def get_actual_position(tile_x, tile_y)
    [tile_x*SQUARE_SIDE, FULL_SIZE - tile_y*SQUARE_SIDE]
  end
end