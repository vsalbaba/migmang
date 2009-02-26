require File.dirname(__FILE__) + '/../../lib/enhancements/array_enhancements'
require File.dirname(__FILE__) + '/../spec_helper.rb'



describe Array do
  describe "direction methods" do
    before(:each) do
      @it = [1, 2]
    end
  
    share_examples_for "all direction methods" do
      it "should not be destructive" do
        lambda {
          @it.up
        }.should_not change{@it}
      end
    end

    describe "#up" do
      it_should_behave_like "all direction methods"
      
      it "should increment second element of array (y coordinate)" do
        @it.up[1].should eql(@it[1]+1)
      end
    end
    
    describe "#down" do
      it_should_behave_like "all direction methods"
      
      it "should decrement second element of array (y coordinate)" do
        @it.down[1].should eql(@it[1]-1)
      end
    end
    
    describe "#left" do
      it_should_behave_like "all direction methods"
      
      it "should decrement first element of array (x coordinate)" do
        @it.left[0].should eql(@it[0]-1)
      end
    end
    
    describe "#right" do 
      it_should_behave_like "all direction methods"
        
      it "should increment first element of array (x coordinate)" do
        @it.right[0].should eql(@it[0]+1)
      end
    end
  end
  
  describe "board position helper methods" do
    describe "#only_those_on_board" do
      it "should eliminate positions from array which are not on board" do
        [[0, 0], [-1, 0], [4, 0], [6, 0], [4, 4], [4, 5]].only_those_on_board(0, 4).should eql(
        [[0, 0], [4, 0], [4, 4]])
      end
    end
  end
end