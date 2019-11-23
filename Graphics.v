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
wire [11:0] data, dataRED,dataPINK,dataBLUE,dataYELLOW,dataTARGET,dataSONG1,dataSONG2,dataSONG3;
reg  [11:0] colour;
reg  [8:0]x,xmax,xoffset;
reg  [7:0]y,ymax,yoffset;
reg  [3:0] todraw, DrawState;
reg  next, startdraw, donedraw, waitfor, draw;
reg [23:0] delayCnt;
wire  [7:0] w;


ROM256x12TEST u0 (.address(address),.clock(CLOCK_50),.q(data));
ROM256x12RED u1 (.address(address),.clock(CLOCK_50),.q(dataRED));
ROM256X12PINK u2 (.address(address),.clock(CLOCK_50),.q(dataPINK));
ROM256X12BLUE u3 (.address(address),.clock(CLOCK_50),.q(dataBLUE));
ROM256X12YELLOW u4 (.address(address),.clock(CLOCK_50),.q(dataYELLOW));
ROM1024X12TARGET u5 (.address(address),.clock(CLOCK_50),.q(dataTARGET));

ROM992X12SONG1 u6 (.address(address),.clock(CLOCK_50),.q(dataSONG1));
ROM1082x12SONG2 u7 (.address(address),.clock(CLOCK_50),.q(dataSONG2));
ROM1024X12SONG3 u8 (.address(address),.clock(CLOCK_50),.q(dataSONG3));

localparam BG = 4'b0001, BGwait = 4'b0010, Draw1 = 4'b0011 , Draw1wait = 4'b0100, Justwait = 4'b1101; // FSM states
localparam Background = 4'b1000, Test = 4'b1111 ,Hit = 4'b00XX ,Target = 4'b0100, blank = 4'b1100, MENU1=4'b1011 , MENU2 = 4'b1010 ,MENU3 = 4'b1001 ,SONG1 = 4'b0111  ,SONG2 = 4'b0101 ,SONG3 = 4'b0110; // Draw states
localparam RED = 4'b0010, BLUE = 4'b0011 ,YELLOW = 4'b0001 ,PINK = 4'b0000; // hitboxes
localparam DELAY = 5000000;// Delay

initial begin
	address <= 17'd0;
	DrawState <= BG;
	donedraw <=0;
	next <= 0;
	startdraw <= 0;
	x=0;
	y=0;
end

always@(posedge CLOCK_50) 
begin
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
				todraw = Test;
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

				Test: begin
					xoffset = xoffsetset;
					yoffset = yoffsetset;
					xmax = 9'd15 + xoffset;
					ymax = 8'd15 + yoffset;
					next = 1;
				end
				Hit: begin
					xoffset = xoffsetset;
					yoffset = 8'd112;
					xmax = 9'd15 + xoffset;
					ymax = 8'd15 + yoffset;
					next = 1;
				end
				Target: begin
					xoffset = 8'd64;
					yoffset = 8'd104;
					xmax = 9'd31 + xoffset;
					ymax = 8'd31 + yoffset;
					next = 1;
				end
				MENU1: begin
					xoffset = xoffsetset;
					yoffset = yoffsetset;
					xmax = 9'd95 + xoffset;
					ymax = 8'd31 + yoffset;
					next = 1;
				end
				MENU2: begin
					xoffset = xoffsetset;
					yoffset = yoffsetset;
					xmax = 9'd95 + xoffset;
					ymax = 8'd31 + yoffset;
					next = 1;
				end
				MENU3: begin
					xoffset = xoffsetset;
					yoffset = yoffsetset;
					xmax = 9'd95 + xoffset;
					ymax = 8'd31 + yoffset;
					next = 1;
				end
				SONG1: begin
					xoffset = xoffsetset;
					yoffset = yoffsetset;
					xmax = 9'd61 + xoffset;
					ymax = 8'd15 + yoffset;
					next = 1;
				end
				SONG2: begin
					xoffset = xoffsetset;
					yoffset = yoffsetset;
					xmax = 9'd62 + xoffset;
					ymax = 8'd15 + yoffset;
					next = 1;
				end
				SONG3: begin
					xoffset = xoffsetset;
					yoffset = yoffsetset;
					xmax = 9'd63 + xoffset;
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
	draw <= 1;
		case(todraw)
			Background: begin
				colour <= 12'b100010000100;
			end

			Test: 
				colour <= data;
			RED: 
			begin
				if(dataRED == 12'd4095)
					draw <=0;
				colour <= dataRED;
			end
			BLUE: 
			begin
				if(dataBLUE == 12'd4095)
					draw <=0;
				colour <= dataBLUE;
			end
			PINK: 
			begin
				if(dataPINK == 12'd4095)
					draw <=0;
				colour <= dataPINK;
			end
			YELLOW: 
			begin
				if(dataYELLOW == 12'd4095)
					draw <=0;
				colour <= dataYELLOW;
			end
			Target: 
			begin
				if(dataTARGET == 12'd273)
					draw <=0;
				colour <= dataTARGET;
			end
			MENU1: 
				colour <= 12'b000011111111;
			MENU2: 
				colour <= 12'b111111110000;
			MENU3: 
				colour <= 12'b000011110000;
			SONG1: 
				colour <= dataSONG1;
			SONG2: 
				colour <= dataSONG2;
			SONG3: 
				colour <= dataSONG2;
			default:
			draw <= 0;
			draw <= 12'b111111111111;
		endcase
end

vga_adapter VGA0 (.resetn(KEY[0]),.clock(CLOCK_50),.colour(colour),.x(x),.y(y),.plot(draw),.VGA_R(VGA_R),.VGA_G(VGA_G),.VGA_B(VGA_B),.VGA_HS(VGA_HS),.VGA_VS(VGA_VS),.VGA_BLANK(VGA_BLANK_N),.VGA_SYNC(VGA_SYNC_N),	.VGA_CLK(VGA_CLK));

defparam VGA0.RESOLUTION = "320x240";
defparam VGA0.MONOCHROME = "FALSE";
defparam VGA0.BITS_PER_COLOUR_CHANNEL = 4;
defparam VGA0.BACKGROUND_IMAGE = "black.mif";

endmodule
