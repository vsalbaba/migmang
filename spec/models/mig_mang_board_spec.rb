require File.dirname(__FILE__) + '/../../lib/models/mig_mang_board'
require File.dirname(__FILE__) + '/../spec_helper.rb'

	WHITEMAN = 1
	BLACKMAN = 2
	EMPTY = 0

describe MigMangBoard do

	before do
		@it = MigMangBoard.new
	end
	
	describe ".[]" do
		it "should respond to classic notation" do
			@it["a3"].should be_zero
		end
		
		it "should respond to array notation" do
			@it[1,3].should be_zero
		end
	end
	
	describe ".[]=" do
		it "should be able to assign via classic notation" do
  			lambda {
    			@it["a3"] = 1
  			}.should change { @it["a3"] }.from(0).to(1)
		end
	
		it "should be able to assign via array notation" do
			lambda {
				@it[1,0] = 1
			}.should change {@it["b1"] }.from(0).to(1)
		end
	end
	
	describe ".populate!" do
		it "should populate! correctly" do
			@it.populate!
			%w(a1 a2 a3 a4 a5 a6 a7 a8 a9 b1 c1 d1 e1 f1 g1 h1).each do |e|
				@it[e].should be_white
			end
		
			%w(b9 c9 d9 e9 f9 g9 h9 i9 i8 i7 i6 i5 i4 i3 i2 i1).each do |f|
				@it[f].should be_black
			end
		  #vsechna pole minus ta co maji mit cernou nebo bilou figuru
			(%w(a1 a2 a3 a4 a5 a6 a7 a8 a9
				 b1 b2 b3 b4 b5 b6 b7 b8 b9
				 c1 c2 c3 c4 c5 c6 c7 c8 c9
				 d1 d2 d3 d4 d5 d6 d7 d8 d9
				 e1 e2 e3 e4 e5 e6 e7 e8 e9
				 f1 f2 f3 f4 f5 f6 f7 f8 f9
				 g1 g2 g3 g4 g5 g6 g7 g8 g9
				 h1 h2 h3 h4 h5 h6 h7 h8 h9
				 i1 i2 i3 i4 i5 i6 i7 i8 i9) - %w(a1 
				 a2 a3 a4 a5 a6 a7 a8 a9 b1 
				 c1 d1 e1 f1 g1 h1) - %w(b9 
				 c9 d9 e9 f9 g9 h9 i9 i8 i7
				 i6 i5 i4 i3 i2 i1)).each do |e|
					@it[e].should be_empty
				end
		end
	end
	
	describe ".apply_move!(move)" do
		it "should correctly apply simple move" do
			lambda do
				@it.apply_move!([ [:place, 'a1', WHITEMAN] ])
			end.should change {@it['a1']}.from(EMPTY).to(WHITEMAN)
			
			lambda do
				@it.apply_move!([ [:remove, 'a1', WHITEMAN] ])
			end.should change {@it['a1']}.from(WHITEMAN).to(EMPTY)
		end
		
		it "should correctly apply more complicated move" do
			@it['a1'] = WHITEMAN
			@it['b2'] = BLACKMAN
			@it.apply_move! [[:remove, 'a1', WHITEMAN], [:remove, 'b2', BLACKMAN], [:place, 'c3', WHITEMAN]]
			@it['a1'].should be_empty
			@it['b2'].should be_empty
			@it['c3'].should eql(WHITEMAN)
		end
	end
	
	describe ".apply_move(move)" do
		it "should correctly apply move to a new desk, not changing the old" do
			lambda do
				@copy = @it.apply_move([ [:place, 'a1', WHITEMAN] ])
			end.should_not change {@it['a1']}
			@copy['a1'].should eql(WHITEMAN)
			
			lambda do
				@copy = @it.apply_move([ [:remove, 'a1', WHITEMAN] ])
			end.should_not change {@it['a1']}.from(WHITEMAN).to(EMPTY)
			@copy['a1'].should be_empty
		end
		
		it "should return a copy of dama board" do
			@copy = @it.apply_move([])
			@copy.should_not equal(@it)
		end
	end
	
	describe ".winner" do
	  it "should return nil when each player has more than one figure" do
      @it['a1'] = WHITEMAN
      @it['b1'] = BLACKMAN
	    @it.winner.should be_nil
	  end
	  
	  it "should return white when there are no black figures" do
	    @it['a1'] = WHITEMAN
	    @it.winner.should be_white
    end
    
    it "should return black when there are no white figures" do
      @it['a1'] = BLACKMAN
      @it.winner.should be_black
    end
  end
end