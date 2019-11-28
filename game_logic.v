`timescale 1ns/1ns

/*
	create 2 instances of "hit_detector" in top level module,
	1 for the left bongo, 1 for the right bongo
	
	connect "go" to whatever detects a button press by the user
	connect "stream" to register holding x position of target
	"hit" is the output signal to animation modules to identify a successful hit

*/

module hit_detector(
    input clk, 
    input reset_b, 
    input go,
	 input [1:0]target,
	 input [3:0] KEY,
    input [8:0] stream, // x position of target to hit
    output reg hit // signal to animation modules if the user has successfully hit the bongo
	);

   localparam CLICK_WAIT = 0, CLICK = 1, EPS = 36;
   reg [3:0] cur_s, next_s;
	reg correct;
   
	always@(*)
	begin
	correct <=0;
	case(target)
	2'b00:;
	2'b01:if(~KEY[1]) correct <=1;
	2'b10:if(~KEY[2]) correct <=1;
	2'b11:if(~KEY[0]) correct <=1;
	default:;
	endcase
	end
	
   always@(*)
   	begin: state_table
      		case(cur_s)
        		CLICK_WAIT:
        			next_s = go ? CLICK : CLICK_WAIT;
        		CLICK:
          			next_s = go ? CLICK : CLICK_WAIT;
      		endcase
    end
    
    always@(posedge clk) begin
		hit = 0;
		if(reset_b == 1'b0)
			cur_s <= CLICK_WAIT;
		else if(cur_s == CLICK) begin
			//logic to send the correct output signal to "hit", based on position of keys relative to hit marker
			
			if(correct && stream < EPS)
				hit = 1;
			
			cur_s <= next_s;
		end
		else
			cur_s <= next_s;
    end

endmodule

module playlogic(CLOCK_50,start,xoffset, drawstream, hit,scoreout, streamout, HEX0);

	output [6:0] HEX0;
	localparam DELAY = 5000000;
	input CLOCK_50;
	input start;
	output [8:0] xoffset;
	reg [8:0] xoffsetset;
	reg [23:0] delayCnt;
	reg [23:0] curDelay;
	reg [7:0] score;
	wire hit;
	wire background;
	reg [239:0] stream;
	output [24:0] drawstream;
	reg [24:0] setstream;
	input hit;
	output [7:0]scoreout;
	output [239:0] streamout;
	reg updateline;
	
	initial begin
		xoffsetset <= 9'd160;
		delayCnt <= DELAY;
		curDelay <= DELAY;
	end
	
	assign xoffset = xoffsetset;
	assign scoreout = score;
	assign streamout = stream;
	
	// move the sprite from right to left
	always@(posedge CLOCK_50) 
	begin
		updateline <= 0;
		if(delayCnt == 0) begin
			if(xoffsetset == 0) begin
				xoffsetset <= 9'd48;
				curDelay <= curDelay - 500000;
				updateline <= 1;
			end
			else
				xoffsetset <= xoffsetset - 1;
			delayCnt <= curDelay;
		end
		else
			delayCnt <= delayCnt - 1;
		if(curDelay == 0) 
			curDelay <= DELAY;
	end
	
	//streamlogic
	always@(posedge CLOCK_50)
	begin
	if(hit)
	stream[1:0] = 2'b00;
	if(updateline)
	stream <= stream >> 2;
	if(start)
	stream <= 240'b001011001011000001110001110011001100100000100011000100100010001100101000001111001010010100110110001110000100101100001000100010101000110010100010001100101001011100100010001100110100100100100000001000101101001100001001001101111001001100100000;
	end
	
	//assign icons
	always@(*)
	begin
	if(stream[1:0] == 2'b10)
	setstream[4:0] <= 5'b00010;
	else if(stream[1:0] == 2'b01)
	setstream[4:0] <= 5'b00011;
	else if(stream[1:0] == 2'b11)
	setstream[4:0] <= 5'b00001;
	else
	setstream[4:0] <= 5'b01100;
	
	if(stream[3:2] == 2'b10)
	setstream[9:5] <= 5'b00010;
	else if(stream[3:2] == 2'b01)
	setstream[9:5] <= 5'b00011;
	else if(stream[3:2] == 2'b11)
	setstream[9:5] <= 5'b00001;
	else
	setstream[9:5] <= 5'b01100;
	
	if(stream[5:4] == 2'b10)
	setstream[14:10] <= 5'b00010;
	else if(stream[5:4] == 2'b01)
	setstream[14:10] <= 5'b00011;
	else if(stream[5:4] == 2'b11)
	setstream[14:10] <= 5'b00001;
	else
	setstream[14:10] <= 5'b01100;
	
	if(stream[7:6] == 2'b10)
	setstream[19:15] <= 5'b00010;
	else if(stream[7:6] == 2'b01)
	setstream[19:15] <= 5'b00011;
	else if(stream[7:6] == 2'b11)
	setstream[19:15] <= 5'b00001;
	else
	setstream[19:15] <= 5'b01100;
	
	if(stream[9:8] == 2'b10)
	setstream[24:20] <= 5'b00010;
	else if(stream[9:8] == 2'b01)
	setstream[24:20] <= 5'b00011;
	else if(stream[9:8] == 2'b11)
	setstream[24:20] <= 5'b00001;
	else
	setstream[24:20] <= 5'b01100;
	
	
	end
	
	assign drawstream = setstream;

	
	always@(posedge hit)
		score <= score + 1; // increment score on a hit

	hex_decoder u0(.hex_digit(score[3:0]), .segments(HEX0));
endmodule

module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule

