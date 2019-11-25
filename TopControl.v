module topControl(
		input CLOCK_50,
		input [3:0] KEY, 
		input [9:0] SW,
		output [9:0] LEDR, 
		output [6:0] HEX0,
		output VGA_CLK, 
		output VGA_HS,
		output VGA_VS, 
		output VGA_BLANK_N, 
		output VGA_SYNC_N, 
		output [7:0] VGA_R, 
		output [7:0] VGA_G, 
		output [7:0] VGA_B
		);
		
		
	localparam DELAY = 5000000;
		
	reg [8:0] xoffsetset;
	reg [7:0] yoffsetset;
	reg [23:0] delayCnt;
	reg [23:0] curDelay;
	reg [3:0] score;
	reg hit;
	
	initial begin
		xoffsetset <= 9'd160;
		yoffsetset <= 8'd120;
		delayCnt <= DELAY;
		curDelay <= DELAY;
	end
	
	// move the sprite from right to left
	always@(posedge CLOCK_50) begin
		yoffsetset <= 8'd120;
		if(delayCnt == 0) begin
			if(xoffsetset == 0) begin
				xoffsetset <= 9'd160;
				curDelay <= curDelay - 500000; // object will speed up every time it moves off the screen
			end
			else
				xoffsetset <= xoffsetset - 1;
			delayCnt <= curDelay;
		end
		else
			delayCnt <= delayCnt - 1;
		if(curDelay == 0) 
			curDelay <= DELAY;
		score <= score + hit; // increment score on a hit
	end
	
	Graphics u0(
					.CLOCK_50(CLOCK_50),
					.xoffsetset(xoffsetset),
					.yoffsetset(yoffsetset),
					.KEY(KEY[2:0]),
					.VGA_CLK(VGA_CLK),
					.VGA_HS(VGA_HS),
					.VGA_VS(VGA_VS),
					.VGA_BLANK_N(VGA_BLANK_N),
					.VGA_SYNC_N(VGA_SYNC_N),
					.VGA_R(VGA_R),
					.VGA_B(VGA_B),
					.VGA_G(VGA_G)
					);
					
	hit_detector u1(
					.clk(CLOCK_50),
					.reset_b(~SW[0]), // dummy switch
					.go(~KEY[3]),
					.stream(xoffsetset),
					.hit(hit)
					);
	
	// temporary, will hook up to VGA later
	hex_decoder u2(.hex_digit(score), 
		       .segments(HEX0)
		      );
	
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
