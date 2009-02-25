# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 
require File.dirname(__FILE__) + '/../../lib/models/board.rb'
require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Board do


	before(:each) do
		@it = Board.byte 8,8
	end
	
	describe "each with keys" do 	
		it "should be defined" do
			@it.respond_to?(:each_with_keys).should be_true
		end
		
		it "should yield each field with indexes" do
			@it.each_with_keys do |x,y,value|
			end
		end
	
	end
end

