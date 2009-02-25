# To change this template, choose Tools | Templates
# and open the template in the editor.

module DamaBoardHelper
	def from_noted(string)
		[string[0]-97, string[1].chr.to_i-1]
  end

  def to_noted(x,y)
		"#{(97+x).chr}#{y+1}"
  end
end
