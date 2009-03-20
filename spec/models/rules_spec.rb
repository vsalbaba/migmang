require File.dirname(__FILE__) + '/../../lib/models/mig_mang_board'
require File.dirname(__FILE__) + '/../../lib/models/rules'
require File.dirname(__FILE__) + '/../../lib/models/board'
require File.dirname(__FILE__) + '/../spec_helper.rb'
require File.dirname(__FILE__) + '/../../lib/constants'

describe "Rules" do
  before(:each) do
    @board = MigMangBoard.new
  end

  describe "#moves_for" do
    it "should return array" do
      @board.moves_for(WHITE).should be_instance_of(Array)
    end

    def be_inside_the_board
      simple_matcher("inside the board") do |given|
        given.each do |move|
          move[1][0].chr.should match(/[a-i]/)
        end
        given.each do |move|
          move[1][1].chr.should match(/[1-9]/)
        end
      end
    end

    it "should generate moves inside the board" do
      @board[0,0] = WHITE
      @board.moves_for(WHITE).each do|move|
        move.should be_inside_the_board
      end
    end

    it "should generate captures" do
      @board[0, 0] = WHITE
      @board[0, 1] = WHITE
      @board[2, 0] = BLACK
      @board.moves_for(BLACK).should include([[:remove, "c1", BLACK], [:place, "b1", BLACK], [:remove, "a1", WHITE]])
    end

    it "should not generate captues of friendlies" do
      @board[0, 0] = WHITE
      @board[0, 1] = WHITE
      @board[2, 0] = WHITE
      @board.moves_for(WHITE).should include([[:remove, "c1", WHITE], [:place, "b1", WHITE]])
      @board.moves_for(WHITE).should_not include([[:remove, "c1", WHITE], [:place, "b1", WHITE], [:remove, "a1", WHITE]])
    end

    it "should generate jump captures if one player has only 1 figure"
  end
  
  describe "#winner" do
    it "should return nil if there is not a clear winner" do
      @board[0, 0] = WHITE
      @board[8, 8] = BLACK
      @board.winner.should be_nil
    end
    
    it "should return :white if there are no black figures on board" do
      @board[0, 0] = WHITE
      @board.winner.should be_white
    end
    
    it "should return :black if there are no white figures on board" do
      @board[0, 0] = BLACK
      @board.winner.should be_black
    end
  end
  
  describe "#ended?" do
    it "should return false if winner returns nil and draw! was not called"
    it "should return false if winner returns WHITE or BLACK or draw! was called"
  end
end