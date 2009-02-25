require File.dirname(__FILE__) + '/../../lib/controllers/dama_board_controller'
require File.dirname(__FILE__) + '/../../lib/models/dama_board'
require File.dirname(__FILE__) + '/../spec_helper'

describe DamaBoardController do
	before do
		@it = DamaBoardController.new
		@dama_board = mock "DamaBoard", :null_object => true
		DamaBoard.stub!(:new).and_return @dama_board
	end
	
	describe "new_game!" do
		it "should call new_game! on DamaBoard" do
			@dama_board.should_receive(:new_game!)
			@it.new_game!
		end
		
		it "should create new DamaBoard desk" do
			DamaBoard.should_receive(:new)
			@it.new_game!
		end
	end
	
	
end
