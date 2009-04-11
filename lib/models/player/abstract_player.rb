require 'observer'

class AbstractPlayer
  include Observable
  def pick_move(moves)
    raise "not implemented"
  end
end