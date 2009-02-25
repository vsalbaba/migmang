require File.dirname(__FILE__) + '/../../lib/models/dama_board'
require File.dirname(__FILE__) + '/../spec_helper.rb'

	WHITEMAN = 1
	BLACKMAN = 2
	WHITEKING = 3
	BLACKKING = 4
	EMPTY = 0

describe DamaBoard do

	before do
		@dama_board = DamaBoard.new
	end
	
	describe ".[]" do
		it "should respond to classic notation" do
			@dama_board["a3"].should be_zero
		end
		
		it "should respond to array notation" do
			@dama_board[1,3].should be_zero
		end
	end
	
	describe ".[]=" do
		it "should be able to assign via classic notation" do
  			lambda {
    			@dama_board["a3"] = 1
  			}.should change { @dama_board["a3"] }.from(0).to(1)
		end
	
		it "should be able to assign via array notation" do
			lambda {
				@dama_board[1,0] = 1
			}.should change {@dama_board["b1"] }.from(0).to(1)
		end
	end
	
	describe ".populate!" do
		it "should populate! correctly" do
			@dama_board.populate!
			%w(a1 a3 b2 c1 c3 d2 e1 e3 f2 g1 g3 h2).each do |e|
				@dama_board[e].should be_white
			end
		
			%w(a7 b6 b8 c7 d6 d8 e7 f6 f8 g7 h6 h8).each do |e|
				@dama_board[e].should be_black
			end
		
			%w(a2 a4 a5 a6 a8 
				b1 b3 b4 b5 b7 
				c2 c4 c5 c6 c8 
				d1 d3 d4 d5 d7 
				e2 e4 e5 e6 e8 
				f1 f3 f4 f5 f7
				g2 g4 g5 g6 g8
				h1 h3 h4 h5 h7).each do |e|
					@dama_board[e].should be_empty
				end
		end
	end
	
	describe ".apply_move!(move)" do
		it "should correctly apply simple move" do
			lambda do
				@dama_board.apply_move!([ [:place, 'a1', WHITEMAN] ])
			end.should change {@dama_board['a1']}.from(EMPTY).to(WHITEMAN)
			
			lambda do
				@dama_board.apply_move!([ [:remove, 'a1', WHITEMAN] ])
			end.should change {@dama_board['a1']}.from(WHITEMAN).to(EMPTY)
		end
		
		it "should correctly apply more complicated move" do
			@dama_board['a1'] = WHITEMAN
			@dama_board['b2'] = BLACKMAN
			@dama_board.apply_move! [[:remove, 'a1', WHITEMAN], [:remove, 'b2', BLACKMAN], [:place, 'c3', WHITEMAN]]
			@dama_board['a1'].should be_empty
			@dama_board['b2'].should be_empty
			@dama_board['c3'].should eql(WHITEMAN)
		end
	end
	
	describe ".apply_move(move)" do
		it "should correctly apply move to a new desk, not changing the old" do
			lambda do
				@copy = @dama_board.apply_move([ [:place, 'a1', WHITEMAN] ])
			end.should_not change {@dama_board['a1']}
			@copy['a1'].should eql(WHITEMAN)
			
			lambda do
				@copy = @dama_board.apply_move([ [:remove, 'a1', WHITEMAN] ])
			end.should_not change {@dama_board['a1']}.from(WHITEMAN).to(EMPTY)
			@copy['a1'].should be_empty
		end
		
		it "should return a copy of dama board" do
			@copy = @dama_board.apply_move([])
			@copy.should_not equal(@dama_board)
		end
	end
	
	describe ".moves for(player)" do
		it do
			@dama_board.should respond_to(:moves_for)
		end
		
		it "should return no moves for empty board" do
			moves = @dama_board.moves_for(:white)
			moves.should be_empty
			@dama_board.moves_for(:black).should be_empty
		end
		describe "man figure" do
			
			describe "(plain move)" do
				it "should generate 2 moves in the middle" do
					@dama_board['e3'] = WHITEMAN
					moves = @dama_board.moves_for(:white)
					moves.should have_exactly(2).possible_moves
					moves.should include([[:remove, 'e3', WHITEMAN], [:place, 'd4', WHITEMAN]])
					moves.should include([[:remove, 'e3', WHITEMAN], [:place, 'f4', WHITEMAN]])
				end
				
				it "should change the figure from man to king at the line 8 for white player" do
					@dama_board['a7'] = WHITEMAN
					white_moves = @dama_board.moves_for(:white)
					white_moves.should have_exactly(1).possible_move
					white_moves.should include([[:remove, 'a7', WHITEMAN], [:place, 'b8', WHITEKING]])
				end
				
				it "should change the figure from man to king at the line 1 for black player" do
					@dama_board['h2'] = BLACKMAN
					black_moves = @dama_board.moves_for(:black)
					black_moves.should have_exactly(1).possible_move
					black_moves.should include([[:remove, 'h2', BLACKMAN], [:place, 'g1', BLACKKING]])
				end
			end
			
			describe "(constrained move)" do
				it "should be constrained by left border" do
					@dama_board['a1'] = WHITEMAN
					moves = @dama_board.moves_for(:white)
					moves.should have_exactly(1).possible_move
					moves.should include([[:remove, 'a1', WHITEMAN], [:place, 'b2', WHITEMAN]])
				end
				
				it "should be constrained by right border" do
					@dama_board['h2'] = WHITEMAN
					moves = @dama_board.moves_for(:white)
					moves.should have_exactly(1).possible_move
					moves.should include([[:remove, 'h2', WHITEMAN], [:place, 'g3', WHITEMAN]])
				end
				
				it "should be constrained by own figures" do
					@dama_board['a1'] = WHITEMAN
					@dama_board['b2'] = WHITEMAN
					moves = @dama_board.moves_for(:white)
					moves.should have_exactly(2).possible_moves
					moves.should include([[:remove, 'b2', WHITEMAN], [:place, 'a3', WHITEMAN]])
					moves.should include([[:remove, 'b2', WHITEMAN], [:place, 'c3', WHITEMAN]])
				end
				
				it "should be constrained be enemy figures" do
					@dama_board['e3'] = WHITEMAN
					@dama_board['d4'] = BLACKMAN
					@dama_board['c5'] = BLACKMAN
					moves = @dama_board.moves_for(:white)
					moves.should have_exactly(1).possible_move
					moves.should include([[:remove, 'e3', WHITEMAN], [:place, 'f4', WHITEMAN]])
				end
			end
			
			describe "(capture)" do
				it "should offer simple capture" do
					@dama_board['a1'] = WHITEMAN
					@dama_board['b2'] = BLACKMAN
					moves = @dama_board.moves_for(:white)
					moves.should have_exactly(1).possible_move
					moves.should include([[:remove, 'a1', WHITEMAN], [:remove, 'b2', BLACKMAN], [:place, 'c3', WHITEMAN]])
				end
				
				it "should not offer move when capture is possible" do
					@dama_board['a1'] = WHITEMAN
					@dama_board['b2'] = BLACKMAN
					@dama_board['a3'] = WHITEMAN
					@dama_board.should_not_receive :moves_for_men
					moves = @dama_board.moves_for(:white)
					moves.should have_exactly(1).possible_move
					moves.should include([[:remove, 'a1', WHITEMAN], [:remove, 'b2', BLACKMAN], [:place, 'c3', WHITEMAN]])
				end
				
				it "should offer more simple captures with one man if possible" do
					@dama_board['e3'] = WHITEMAN
					@dama_board['f4'] = BLACKMAN
					@dama_board['d4'] = BLACKMAN
					moves = @dama_board.moves_for(:white)
					moves.should have_exactly(2).possible_moves
					moves.should include([[:remove, 'e3', WHITEMAN], [:remove, 'f4', BLACKMAN], [:place, 'g5', WHITEMAN]])
					moves.should include([[:remove, 'e3', WHITEMAN], [:remove, 'd4', BLACKMAN], [:place, 'c5', WHITEMAN]])
				end

				it "should offer series of captures" do
					@dama_board['a1'] = WHITEMAN
					@dama_board['b2'] = BLACKMAN
					@dama_board['d4'] = BLACKMAN
					moves = @dama_board.moves_for(:white) 
					moves.should have_exactly(1).possible_move
					moves.should include([[:remove, 'a1', WHITEMAN],[:remove, 'b2', BLACKMAN], [:place, 'c3', WHITEMAN], [:remove, 'c3', WHITEMAN],[:remove, 'd4', BLACKMAN],[:place,  'e5', WHITEMAN]])
				end
				
				it "should offer multiple series of captures" do
					@dama_board['a1'] = WHITEMAN
					@dama_board['b2'] = BLACKMAN
					@dama_board['d4'] = BLACKMAN
					@dama_board['b4'] = BLACKMAN
					moves = @dama_board.moves_for(:white)
					moves.should include([[:remove, 'a1', WHITEMAN],[:remove, 'b2', BLACKMAN],[:place, 'c3', WHITEMAN], [:remove, 'c3', WHITEMAN],[:remove, 'd4', BLACKMAN],[:place,  'e5', WHITEMAN]])
					moves.should include([[:remove, 'a1', WHITEMAN],[:remove, 'b2', BLACKMAN],[:place, 'c3', WHITEMAN], [:remove, 'c3', WHITEMAN],[:remove, 'b4', BLACKMAN],[:place,  'a5', WHITEMAN]])
					moves.should have_exactly(2).possible_moves
				end
				
				it "should offer captures with multiple figures" do
					@dama_board['a1'] = WHITEMAN
					@dama_board['b2'] = BLACKMAN
					@dama_board['e3'] = WHITEMAN
					@dama_board['f4'] = BLACKMAN
					moves = @dama_board.moves_for(:white)
					moves.should have_exactly(2).possible_moves
					moves.should include([[:remove, 'a1', WHITEMAN],[:remove, 'b2', BLACKMAN], [:place, 'c3', WHITEMAN]])
					moves.should include([[:remove, 'e3', WHITEMAN],[:remove, 'f4', BLACKMAN], [:place, 'g5', WHITEMAN]])
				end
			end
		end
		
		describe "king" do
		
			describe "(plain move)" do

				it "should generate diagonal moves" do
					@dama_board['e3'] = WHITEKING
					moves = @dama_board.moves_for(:white)
					moves.should include([[:remove, 'e3', WHITEKING], [:place, 'd2', WHITEKING]])
					moves.should include([[:remove, 'e3', WHITEKING], [:place, 'c1', WHITEKING]])
					moves.should include([[:remove, 'e3', WHITEKING], [:place, 'f2', WHITEKING]])
					moves.should include([[:remove, 'e3', WHITEKING], [:place, 'g1', WHITEKING]])
					moves.should include([[:remove, 'e3', WHITEKING], [:place, 'f4', WHITEKING]])
					moves.should include([[:remove, 'e3', WHITEKING], [:place, 'g5', WHITEKING]])
					moves.should include([[:remove, 'e3', WHITEKING], [:place, 'h6', WHITEKING]])
					moves.should include([[:remove, 'e3', WHITEKING], [:place, 'd4', WHITEKING]])
					moves.should include([[:remove, 'e3', WHITEKING], [:place, 'c5', WHITEKING]])
					moves.should include([[:remove, 'e3', WHITEKING], [:place, 'b6', WHITEKING]])
					moves.should include([[:remove, 'e3', WHITEKING], [:place, 'a7', WHITEKING]])
					moves.should have_exactly(11).possible_moves
				end
				
				it "should stop at friendly figure" do
					@dama_board['e3'] = WHITEKING
					@dama_board['g1'] = WHITEMAN
					@dama_board['c1'] = WHITEMAN
					@dama_board['c5'] = WHITEMAN
					@dama_board['g5'] = WHITEMAN
					@dama_board.moves_for(:white).find_all{|e| e.first.last == WHITEKING}.should have_exactly(4).possible_moves
				end
			end
			
			describe "(capture)" do
				
				it "should offer simple capture" do
					@dama_board['e3'] = WHITEKING
					@dama_board['d2'] = BLACKMAN
					moves = @dama_board.moves_for(:white)
					moves.should include([[:remove, 'e3', WHITEKING], [:remove, 'd2', BLACKMAN], [:place, 'c1', WHITEKING]])
					moves.should have_exactly(1).possible_move
				end


				it "should not offer captures with man when capture with king is possible" do
					@dama_board['e3'] = WHITEKING
					@dama_board['e5'] = WHITEMAN
					@dama_board['b6'] = BLACKMAN
					@dama_board['d6'] = BLACKMAN
					moves = @dama_board.moves_for(:white)
					moves.should include([[:remove, 'e3', WHITEKING], [:remove, 'b6', BLACKMAN], [:place, 'a7', WHITEKING]])
					moves.should have_exactly(1).possible_move
				end
		
				it "should offer to end anywhere behind the enemy" do
					@dama_board['e3'] = WHITEKING
					@dama_board['d4'] = BLACKMAN
					moves = @dama_board.moves_for(:white)
					moves.should have_exactly(3).possible_moves
				end
				
				
				it "should offer multiple captures" do
					@dama_board['e3'] = WHITEKING
					@dama_board['b6'] = BLACKMAN
					@dama_board['g5'] = BLACKMAN
					moves = @dama_board.moves_for(:white)
					moves.should have_exactly(2).possible_moves
				end
				
				it "should offer series of captures" do
					@dama_board['e1'] = WHITEKING
					@dama_board['c3'] = BLACKMAN
					@dama_board['c7'] = BLACKMAN
					moves = @dama_board.moves_for(:white)
					moves.should include([[:remove, "e1", WHITEKING], [:remove, "c3", BLACKMAN], [:place, "a5", WHITEKING], [:remove, "a5", WHITEKING], [:remove, "c7", BLACKMAN], [:place, "d8", WHITEKING]])
					moves.should have_exactly(1).possible_move
				end

				it "should offer really elaborate captures" do
					@dama_board["e3"] = BLACKKING
					@dama_board["d2"] = WHITEMAN
					@dama_board["c5"] = WHITEMAN
					@dama_board["c7"] = WHITEMAN
					@dama_board["e7"] = WHITEMAN
					@dama_board["g5"] = WHITEMAN
					@dama_board["c3"] = WHITEMAN
					moves = @dama_board.moves_for(:black)
					moves.should include([[:remove, "e3", BLACKKING], [:remove, "d2", WHITEMAN], [:place, "c1", BLACKKING]])
					moves.should include([[:remove, "e3", BLACKKING], [:remove, "g5", WHITEMAN], [:place, "h6", BLACKKING]])
					moves.should have_exactly(5).possible_moves
				end

			end
		end
	end
end
