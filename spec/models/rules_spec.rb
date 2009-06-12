require File.dirname(__FILE__) + '/../../lib/require_farm'
require File.dirname(__FILE__) + '/../spec_helper.rb'

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
      2.times do #musi se provest 2krat, kvuli zapsani spravnych zaznamu do free_neighbours_count
        @board['a1'] = WHITE
        @board['a2'] = WHITE
        @board['c1'] = BLACK
      end
      
      @board.moves_for(BLACK).should include([[:remove, "c1", BLACK], [:place, "b1", BLACK], [:remove, "a1", WHITE]])
    end

    it "should not generate captues of friendlies" do
      2.times do
        @board[0, 0] = WHITE
        @board[0, 1] = WHITE
        @board[2, 0] = WHITE
      end

      @board.moves_for(WHITE).should include([[:remove, "c1", WHITE], [:place, "b1", WHITE]])
      @board.moves_for(WHITE).should_not include([[:remove, "c1", WHITE], [:place, "b1", WHITE], [:remove, "a1", WHITE]])
    end

    it "should generate jump captures if one player has only 1 figure" do
      2.times do
        @board['c3'] = WHITE
        @board['c4'] = BLACK
        @board['g3'] = BLACK
      end
      
      @board.moves_for(WHITE).should include([[:remove, 'c3', WHITE], [:place, 'c5', WHITE], [:remove, 'c4', BLACK]])
    end
    
    it "should not bugcapture" do
      2.times do
        @board['h1'] = WHITE
        @board['i2'] = BLACK
        @board['i3'] = BLACK
      end
      
      @board.moves_for(WHITE).should_not include([[:remove, "h1", WHITE], [:place, "i1", WHITE], [:remove, "i2", BLACK]])
    end
    
    it "should not bug" do
      2.times do
        @board['h2'] = WHITE
        @board['i2'] = BLACK
      end
      @board.moves_for(BLACK).should include([[:remove, "i2", BLACK], [:place, "g2", BLACK], [:remove, "h2", WHITE]])
    end
  end
  
  
  describe "#winner" do
    it "should return nil if there is not a clear winner" do
      2.times do
        @board[0, 0] = WHITE
        @board[8, 8] = BLACK
      end
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