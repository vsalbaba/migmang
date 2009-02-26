require File.dirname(__FILE__) + '/../../lib/models/historian.rb'
require File.dirname(__FILE__) + '/../../lib/models/mig_mang_board.rb'
require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Historian do

	before(:each) do
		@game = MigMangBoard.new
		@it = Historian.new(@game)
	end
	describe "observing Historian", :shared => true do
		it "should catch moves and save them to memory" do
			@game.apply_move!([[:place, "a1", 1]])
			@it.history.should include([[:place, "a1", 1]])
			@it.index.should eql(0)
		end
	end
	
	describe "observe(game:dama_board)" do
		it "should respond to observe a dama_board" do
			Historian.should respond_to(:observe)
		end
		it_should_behave_like "observing Historian"
	end
	
	describe "sedate!" do
		it "should respond to sedate!" do
			@it.should respond_to(:sedate!)
		end
		it "should pause observing" do
			@it.sedate!
			@game.apply_move!([[:place, "a1", 1]])
			@it.history.should_not include([[:place, "a1", 1]])
			@it.index.should eql(-1)
		end
	end

	describe "wake_up!" do
		it "should respond to wake_up!" do
			@it.should respond_to(:wake_up!)
		end
		it_should_behave_like "observing Historian"
	end

	describe "save!(filename)" do
		it "should respond to save" do
			@it.should respond_to(:save!)
		end
		it "should save game with given name." do
			File.should_receive(:open).with("test.yaml", "w")
			@it.save!("test.yaml")
		end
		it "should raise error when game cannot be saved"
	end

	describe "load!(filename)" do
		it "should respond to load" do
			@it.should respond_to(:load!)
		end
		it "should load a game and return dama_board"
		it "should load moves into memory"
		it "should raise error when game cannot be loaded"
	end

	describe "undo!" do
		it "should respond to undo" do
			@it.should respond_to(:undo!)
		end
		
		it "should undo a move" do
			@game.apply_move!([[:place, "a1", 1]])
			@it.undo!
			@game["a1"].should eql(0)
		end
		
		it "should raise error when are no moves to undo" do
			lambda {@it.undo!}.should raise_error
		end
	end

	describe "redo!" do
		before do
			@game.apply_move!([[:place, "a1", 1]])
			@it.undo!
		end
		it "should respond to redo" do
			@it.should respond_to(:redo!)
		end
		it "should redo a move" do
			@game["a1"].should eql(0)
			@it.redo!
			@game["a1"].should eql(1)
		end
		it "should raise error where there is nothing to redo" do
			@it.redo!
			lambda {@it.redo!}.should raise_error
		end
	end

	describe "without_history" do
		it "should not record actions in the block" do
			@it.without_history do
				@game.apply_move! [[:place, "a1", 1]]
			end
			@game["a1"].should eql(1)
			@it.history.should be_empty
			@it.index.should eql(-1)
		end
	end

	describe "when captures a move" do
		it "should keep move in memory"
	end
end
