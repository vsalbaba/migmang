=begin rdoc
Trida historie.
Pri vytvoreni se uvrtá do třídy specifikovane parametrem pred metodu apply_move!
Tahy ktere takto odchytne si uchovava v poli a je je schopen stornovat.
Sledovani desky je mozno zastavit metodou sedate!, ale za integritu dat pak Historian neni zodpovedny.
=end
require "yaml"
require File.dirname(__FILE__) + '/../enhancements/metaid'
require File.dirname(__FILE__) + '/../enhancements/move_enhancements'

class Historian
  include MoveEnhancements
	
  attr_reader :history, :index
	
  def initialize(game)
		@game = game
		@history = Array.new
		@index = -1
		wake_up!
  end

	def update(message, board, move)
	  if message == :move
  		unless (@index == (@history.length - 1))
  			@history = @history[0..@index]
  		end
  		@history << move
  		@index += 1
  	end
	end

	def self.observe(game)
		self.new(game)
	end

	def sedate!
		@game.delete_observer(self)
	end

	def save!(filepath)
		File.open(filepath, "w") do |file|
			YAML.dump( {:history => @history, :index => @index}, file )
		end
	end

	def load!(filepath)
		loaded = Yaml.load_file( filepath)
		@history = loaded[:history]
		@index = loaded[:index]
		@game.new_game
	end

	def undo!
		if @index == -1
			raise "No moves to undo!"
			return
		end
		without_history do
			@game.apply_move! reverse_move(@history[@index])
		end
		@index -= 1
	end

	def redo!
		if @index.next == @history.length
			raise "No moves to redo!"
			return
		end
		@index += 1
		without_history do
			@game.apply_move! @history[@index]
		end
	end

	def wake_up!
		@game.add_observer(self)
	end

	def without_history &block
		sedate!
		yield
		wake_up!
	end
end
