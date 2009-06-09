=begin rdoc
Trida historie.
Pri vytvoreni se uvrtá do třídy specifikovane parametrem pred metodu apply_move!
Tahy ktere takto odchytne si uchovava v poli a je je schopen stornovat.
Sledovani desky je mozno zastavit metodou sedate!, ale za integritu dat pak Historian neni zodpovedny.
=end
require "yaml"

class Historian
  include MoveEnhancements
	
  attr_accessor :index, :history, :game
	
  def initialize(game)
		@game = game
		@history = Array.new
		@index = -1
		wake_up!
  end

	def update(who, move)
	  if @game == who
      puts "move saved to history"
  		unless (@index == (@history.length - 1))
  			@history = @history[0..@index]
  		end
  		@history << move
  		@index += 1
  	end
  	return @history
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
		loaded = YAML.load_file(filepath)
		@history = loaded[:history]
		@game.populate!
		@index = 0
		until @index == loaded[:index] do
		  redo!
	  end
	end

	def undo!
		if @index == -1
			raise "No moves to undo!"
		end
		without_history do
			@game.apply_move! reverse_move(@history[@index])
		end
		@index -= 1
		@history[@index + 1]
	end

	def redo!
	  p @history.length
	  p @index
		if @index.next == @history.length
		  puts "blah"
			raise "No moves to redo!"
		end
		@index += 1
		without_history do
			@game.apply_move! @history[@index]
		end
		@history[@index]
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
