# To change this template, choose Tools | Templates
# and open the template in the editor.

require File.dirname(__FILE__) + '/../../lib/enhancements/move_enhancements'
require File.dirname(__FILE__) + '/../spec_helper.rb'

describe MoveEnhancements do
  before(:each) do
    extend MoveEnhancements
  end
describe "reverse_move"
  it "should return reversed move with place and remove swaped" do
    reverse_move([[:place, "a1", 1], [:remove, "b3", 3]]).should eql([[:remove, "a1", 1], [:place, "b3", 3]].reverse)
  end

	it "should not change reversed variables" do
		a = [[:place, "a1", 1], [:remove, "b3", 3]]
		reverse_move a
		a.should eql([[:place, "a1", 1], [:remove, "b3", 3]])
	end
end

