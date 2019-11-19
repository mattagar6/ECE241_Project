
module topControl(
		input CLOCK_50,
		input [3:0] KEY, 
		output [9:0] LEDR, 
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
	
	initial begin
		xoffsetset <= 9'b010000000;
		yoffsetset <= 8'd56;
		delayCnt <= DELAY;
	end
	
	// move the sprite from right to left
	always@(posedge CLOCK_50) begin
		if(delayCnt == 0) begin
			if(xoffsetset == 0)
				xoffsetset <= 9'b010000000;
			else
				xoffsetset <= xoffsetset - 1;	
			delayCnt <= DELAY;
		end
		else
			delayCnt <= delayCnt - 1;
	end
	
	Graphics u0(
					.CLOCK_50(CLOCK_50),
					.xoffsetset(xoffsetset),
					.yoffsetset(yoffsetset),
					.KEY(KEY),
					.VGA_CLK(VGA_CLK),
					.VGA_HS(VGA_HS),
					.VGA_VS(VGA_VS),
					.VGA_BLANK_N(VGA_BLANK_N),
					.VGA_SYNC_N(VGA_SYNC_N),
					.VGA_R(VGA_R),
					.VGA_B(VGA_B),
					.VGA_G(VGA_G)
					);
		
		
endmodule

module Graphics( 
		input CLOCK_50,
		input [8:0] xoffsetset,
		input [7:0] yoffsetset,
		input [3:0] KEY,
		output VGA_CLK, 
		output VGA_HS,
		output VGA_VS, 
		output VGA_BLANK_N, 
		output VGA_SYNC_N, 
		output [7:0] VGA_R, 
		output [7:0] VGA_G, 
		output [7:0] VGA_B
		);


reg  [16:0] address;
wire [11:0] data;
reg  [11:0] colour;
reg  [8:0]x;
reg  [7:0]y;
reg  [8:0]xmax;
reg  [7:0]ymax;
reg  [8:0]xoffset;
reg  [7:0]yoffset;
reg  [3:0] todraw, DrawState;
reg  next, startdraw, donedraw;
reg [23:0] delayCnt;
wire  [7:0] w;
reg waitfor;


ROM256x12TEST u0 (.address(address),.clock(CLOCK_50),.q(data));


localparam BG = 4'b0001, BGwait = 4'b0010, 
			  Draw1 = 4'b0011 , Draw1wait = 4'b0100, 
			  Justwait = 4'b1101;

localparam Background = 4'b0001, Item1 = 4'b0010 ;
	localparam DELAY = 5000000;
	
	always@(posedge CLOCK_50) begin
		if(delayCnt == 0)
			begin	
			waitfor<=1;
			delayCnt <= DELAY;
			end
		else
			begin
			waitfor<= 0;
			delayCnt <= delayCnt - 1;
			end
	end

initial begin
	address <= 17'd0;
	DrawState <= BG;
	donedraw <=0;
	next <= 0;
	startdraw <= 0;
	x=0;
	y=0;
end

reg setdraw;

always@(posedge CLOCK_50)
	begin: drawingstate
		case(DrawState)
			BG: begin
				setdraw <= 1;
				startdraw <= 0;
				todraw <= Background;
				if(next == 1 )
					DrawState <= BGwait;
			end

			BGwait: begin
				setdraw <= 0;
				startdraw <= 1;
				if(donedraw == 1)
					DrawState <= Draw1;
			end

			Draw1: begin
				setdraw <= 1;
				todraw = Item1;
				startdraw <= 0;
				if(next == 1)
					DrawState <= Draw1wait;
			end

			Draw1wait: begin
				setdraw <= 0;
				startdraw <= 1;
				if(donedraw == 1) begin
					DrawState <= Justwait;
				end
			end

			Justwait: begin
				startdraw <= 0;
				if(waitfor)
				DrawState <= BG;
			end
			

		endcase
	end

// whats going on here kevin??
or (w[2],setdraw, next);
and(w[1],w[2],CLOCK_50); 

always@(posedge w[1])
	begin: drawsetter
		if(setdraw == 0)
			next <= 0;
		else begin
			case(todraw)
				Background: begin
					xoffset <= 0;
					yoffset <= 0;
					xmax <= 9'd320 ;
					ymax <= 8'd240 ;
					next <= 1;
				end

				Item1: begin
					xoffset = xoffsetset;
					yoffset = yoffsetset;
					xmax = 9'd15 + xoffset ;
					ymax = 8'd15 + yoffset;
					next = 1;
				end
			endcase
		end
end

or (w[3],startdraw,donedraw);
and(w[0],w[3],CLOCK_50);

always@(posedge w[0])
	begin: imagesetter
		if(startdraw == 0)
			donedraw <= 0;
		else begin

			address <= 0;
			donedraw <= 0;

		case(x)
			xmax: begin
				if (y == ymax) begin
					donedraw <= donedraw + 1;
					address <= 0;
				end
				else begin
					x <= xoffset;
					y <= y + 1;
					address <= address + 1;
				end
			end

			default: begin
				if(address == 0) begin
					x <= xoffset;
					y <= yoffset;
					address <= address + 1;
				end
				else begin
					address <= address + 1;
					x <= x + 1;
					y <= y + 0;
				end
			end
		endcase
	end
end



always@(*)
	begin: dataset
		case(todraw)
			Background: begin
				colour <= 12'b100010000100;
			end

			Item1: begin
				colour <= data;
			end
		endcase
end

vga_adapter VGA0 (.resetn(KEY[0]),.clock(CLOCK_50),.colour(colour),.x(x),.y(y),.plot(KEY[2]),.VGA_R(VGA_R),.VGA_G(VGA_G),.VGA_B(VGA_B),.VGA_HS(VGA_HS),.VGA_VS(VGA_VS),.VGA_BLANK(VGA_BLANK_N),.VGA_SYNC(VGA_SYNC_N),	.VGA_CLK(VGA_CLK));

defparam VGA0.RESOLUTION = "320x240";
defparam VGA0.MONOCHROME = "FALSE";
defparam VGA0.BITS_PER_COLOUR_CHANNEL = 4;
defparam VGA0.BACKGROUND_IMAGE = "black.mif";

endmodule

