require 'observer'

class AbstractPlayer
  include Observable
  attr_accessor :color
  def initialize(color)
    @color = color
  end

  def pick_move(game, moves)
    puts "hello"
  end
end