require File.dirname(__FILE__) + '/../../lib/models/mig_mang_board'
require File.dirname(__FILE__) + '/../../lib/models/rules'
require File.dirname(__FILE__) + '/../../lib/models/board'
require File.dirname(__FILE__) + '/../spec_helper.rb'
include Rules

describe Rules do
  before(:each) do
    @it = MigMangBoard.new
  end
  
  describe "#moves_for" do
    it "should return array"
    it "should generate moves inside the board"
    it "should generate captures"
    it "should not generate captues of friendlies"
  end
  
  describe "#winner" do
    it "should return symbol or nil"
    it "should return :white if there are no black figures on board"
    it "should return :black if there are no white figures on board"
    it "should return nil if winner cant be decided"
  end
  
  describe "#ended?" do
    it "" do
      
    end
  end
end