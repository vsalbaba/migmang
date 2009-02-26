# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 
require File.dirname(__FILE__) + '/../../lib/models/board.rb'
require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Board do
	before(:each) do
		@it = Board.new 8,8
	end
	
	describe "each with keys" do 	
		it "should be defined" do
			@it.respond_to?(:each_with_keys).should be_true
		end
	end

	describe ".[]" do
	  it "should take 2 things in the brackets" do
	    @it[0,0].should eql(0)
    end
	end
	
	describe ".[]=" do
	  it "should take 2 things in the brackets and assign it something" do
	    @it[3,4] = 1
	    @it[3,4].should eql(1)
	    @it[4,3].should eql(0)
    end
  end
end