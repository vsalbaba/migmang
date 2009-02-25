require 'rubygems'
require 'narray'


class Board < NMatrix
	def each_with_keys(&block)
		width, height = sizes
		for x in 0..width-1
			for y in 0..height-1
				yield x,y,self[x,y]
			end
		end
	end
	
	def clear!
		self.fill! 0
	end
end