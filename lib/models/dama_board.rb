require File.join(File.expand_path(File.dirname(__FILE__)), "board")
require File.join(File.expand_path(File.dirname(__FILE__)), "../enhancements/fixnum_enhancements")
require File.join(File.expand_path(File.dirname(__FILE__)), "../enhancements/dama_board_helper")
require 'observer'
=begin rdoc
Matice hraci desky. Policka jsou polozky v matici, jejich hodnota urcuje
jaka je na nich figurka.
* 0 - prazdne
* 1 - bila figura
* 2 - cerna figura
* 3 - bila dama
* 4 - cerna dama
=end
class DamaBoard
  WHITEMAN = 1
  BLACKMAN = 2
  WHITEKING = 3
  BLACKKING = 4
	include Observable
  attr_accessor :board, :on_move

  def initialize
		extend DamaBoardHelper
		@board = Board.byte(8,8)
		@on_move = :white
  end

=begin rdoc
vlozi na  desku figury v zakladnim postaveni
=end
  def populate!
		@board.clear!
		black_men = %w(a7 b6 b8 c7 d6 d8 e7 f6 f8 g7 h6 h8)
		white_men = %w(a1 a3 b2 c1 c3 d2 e1 e3 f2 g1 g3 h2)

		black_men.each do |man|
			self[man] = BLACKMAN
		end

		white_men.each do |man|
			self[man] = WHITEMAN
		end
		self
  end

=begin rdoc
selector policka na desce. Je mozne selektovat napr. 0,0 (jako v poli poli) nebo stringem, napr. "a1" (jako v normalni notace)
=end
  def [](key1, key2 = nil)
		if key1.kind_of?(String)
			normal = from_noted key1
			@board[normal.first, normal.last]
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
vygeneruje vsechny mozne tahy pro jednoho hrace
=end
  def moves_for(player_color)
		moves = generate(:capture, :king, player_color)
		return moves unless moves.empty?

		moves = generate(:capture, :man, player_color)
		return moves unless moves.empty?
		return generate(:move, :king, player_color) + generate(:move, :man, player_color)
  end


=begin rdoc
aplikuje konstruktivne tah na desku, tah je pole poli ve formatu
	[:remove, pole, figura] nebo [:place, pole, figura]
Pri odbrani tahu je treba uvadet jakou figuru odebirame, abysme mohli pak provadet jednoduse undo
vraci novou desku.
Destruktivni verzi je apply_move!
=end
  def apply_move(move)
		copy = DamaBoard.new
		copy.on_move = @on_move
		copy.board = @board.clone

		for part in move
			case part[0]
			when :remove
				copy[part[1]] = 0
			when :place
				copy[part[1]] = part[2]
			end
		end
		copy
  end

=begin rdoc
aplikuje destruktivne tah na desku. Pro podrobnosti se podivejte na apply_move
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
		changed
		notify_observers @board.dup, move
		self
  end

  private
  def generate(what, figures, player_color)
		moves = []
		if figures == :man
			figure = (player_color == :white) ? WHITEMAN : BLACKMAN
		else
			figure = (player_color == :white) ? WHITEKING : BLACKKING
		end
		board.each_with_keys do |x,y,value|
			if value == figure then
				moves.concat self.send("#{what.to_s}s_for_#{figures}",x,y)
			end
		end
		return moves

  end

  def captures_for_king_helper(x,y,direction, &block)
		i = 1
		while true do
			computed_x = x+i*direction[0]
			computed_y = y+i*direction[1]
			break unless [computed_x, computed_y].all?{|value| value.between?(0,7)}
			computed_noted_position = to_noted(computed_x, computed_y)
			yield computed_noted_position
			i +=1
		end
  end

  def captures_for_king(x,y)
		figure = self[x,y]
		noted_position = to_noted(x,y)
		directions = [[-1,1],[1,1], [-1,-1], [1, -1]]
		result = []
		moves = []

		directions.each do |direction|
			enemy_to_jump_over = nil
			captures_for_king_helper(x,y,direction) do |computed_noted_position|
				break if self[computed_noted_position].friendly_to?(figure)
				if self[computed_noted_position].enemy_to?(figure) then
					enemy_to_jump_over = computed_noted_position
					break
				end
			end #tak ted mam v enemy_to_jump over nepritele ktereho preskocit nebo nil.

			next unless enemy_to_jump_over #ted uz pokracuju jen kdyz je pres co skakat.
			new_x, new_y = from_noted(enemy_to_jump_over)
			captures_for_king_helper(new_x, new_y, direction) do |computed_noted_position|
				break if self[computed_noted_position].full?
				moves.push [[:remove, noted_position, figure],
					[:remove, enemy_to_jump_over, self[enemy_to_jump_over]],
					[:place, computed_noted_position, figure]]
			end #ted by v moves mely byt jednoduche preskoky.
		end

		until moves.empty? do #dokud se daji tahy nejak rozvijet
			move = moves.pop
			should_return_this_move = true
			new_starting_position = move.last[1]
			x,y = from_noted(new_starting_position)

			directions.each do |direction| #rozvoj postupne ve vsech smerech
				enemy_to_jump_over = nil
				captures_for_king_helper(x,y,direction) do |computed_noted_position|
					break if self[computed_noted_position].friendly_to?(figure)
					if self[computed_noted_position].enemy_to?(figure) then
						enemy_to_jump_over = computed_noted_position
						break
					end
				end #tak ted mam v enemy_to_jump over nepritele ktereho preskocit nebo nil.

				next unless enemy_to_jump_over
				#ted uz pokracuju jen kdyz je pres co skakat.
				new_x, new_y = from_noted(enemy_to_jump_over)
				captures_for_king_helper(new_x,new_y, direction) do |computed_noted_position|
					break if self[computed_noted_position].full?
					unless move.any?{|part| part == [:remove, enemy_to_jump_over, self[enemy_to_jump_over]]}
						move2 = [[:remove, new_starting_position, figure],
							[:remove, enemy_to_jump_over, self[enemy_to_jump_over]],
							[:place, computed_noted_position, figure]]
						moves.push move + move2
						should_return_this_move = false
					end
				end #ted by v moves mely byt jednoduche preskoky.
			end
			if should_return_this_move
				result.push move
			end
		end

		#ted vytridit z vysledku tahy ktere nikam nevedou ale lezi na stejne uhlopricce jako ty ktere se dale rozvijely
		result2 = []
		result.each do |tah|
			posledni_brany_kamen = tah[-2]
			index_toho_kamenu = tah.length-2
			tahy_se_stejnym_branym_kamenem = result.find_all{|taky_tah| taky_tah[index_toho_kamenu] == posledni_brany_kamen}
			unless tah.length < tahy_se_stejnym_branym_kamenem.map(&:length).max
				result2.push tah
			end
		end
		return result2
  end


  def captures_for_man(x,y)
		figure = self[x,y]
		directions = figure.white? ? [[-1,1],[1,1]] : [[-1,-1], [1, -1]]
		result = []
		moves = []
		directions.each do |direction|
			next unless [x+2*direction[0], y+2*direction[1]].all?{|e|e.between?(0,7)}
			field_to_go_over = to_noted((x + direction[0]), (y + direction[1]))
			field_to_go = to_noted((x+2*direction[0]), (y+2*direction[1]))
			if self[field_to_go_over].enemy_to?(self[x,y]) and self[field_to_go].empty? then
				move = [[:remove, to_noted(x,y), figure], [:remove, field_to_go_over, self[field_to_go_over]], [:place, field_to_go, figure]]
				move = make_change_to_king_to move
				moves.push move
			end
		end

		until moves.empty?
			move = moves.pop
			should_return_this_move = true
			directions.each do |direction|
				x,y = from_noted(move.last[1])
				next unless [x+2*direction[0], y+2*direction[1]].all?{|e|e.between?(0,7)}
				field_to_go_over = to_noted((x + direction[0]), (y + direction[1]))
				field_to_go = to_noted((x+2*direction[0]), (y+2*direction[1]))
				if self[field_to_go_over].enemy_to?(figure) and self[field_to_go].empty? then
					should_return_this_move = false
					move2 = [[:remove, to_noted(x,y), figure], [:remove, field_to_go_over, self[field_to_go_over]], [:place, field_to_go, figure]]
					move2 = make_change_to_king_to move2
					moves.push move + move2
				end
			end
			if should_return_this_move
				result.push move
			end
		end #until
		return result
  end


  def moves_for_king(x,y)
		raise "No man or king at #{to_noted(x,y)}" if self[x,y].empty?
		directions = [[-1,1],[1,1], [-1,-1], [1, -1]]

		moves = []
		directions.each do |direction|
			i = 1
			while true do
				break unless [x+i*direction[0], y+i*direction[1]].all? do |e|
					e.between?(0,7)
				end

				field_to_go = to_noted((x + i*direction[0]), (y + i*direction[1]))

				break if self[field_to_go].full?
				if self[field_to_go].empty? then
					move = [[:remove, to_noted(x,y), self[x,y]], [:place, field_to_go, self[x,y]]]
					moves.push move
				end
				i += 1
			end
		end
		return moves
  end

  def moves_for_man(x,y)
		raise "No man or king at #{to_noted(x,y)}" if self[x,y].empty?
		directions = self[x,y].white? ? [[-1,1],[1,1]] : [[-1,-1], [1, -1]]

		moves = []
		directions.each do |direction|
			next unless [x+direction[0], y+direction[1]].all? do |e|
				e.between?(0,7)
			end

			field_to_go = to_noted((x + direction[0]), (y + direction[1]))
			if self[field_to_go].empty? then
				move = [[:remove, to_noted(x,y), self[x,y]], [:place, field_to_go, self[x,y]]]
				move = make_change_to_king_to move
				moves.push move
			end
		end
		return moves
  end

  def make_change_to_king_to(move)
		last_part = move.last
		case last_part[1][1]
		when "8"[0]
			if last_part[2].white?
				result = move.dup
				result.last[2] = WHITEKING
				return result
			end
		when "1"[0]
			if last_part[2].black?
				result = move.dup
				result.last[2] = BLACKKING
				return result
			end
		end
		return move
  end
end
