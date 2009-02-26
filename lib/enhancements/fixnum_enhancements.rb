class Fixnum

	def black?
		return false if zero?
		even?
	end

	def white?; odd?; end

	def empty?; zero?; end
	
	def full?; !empty?; end
	
	def friendly_to?(as_what)
		return true if empty? and as_what.empty?
		return true if white? and as_what.white?
		return true if black? and as_what.black?
		return false
	end
	
	def enemy_to?(what)
		return false if what.empty? or empty?
		!friendly_to?(what)
	end
end
