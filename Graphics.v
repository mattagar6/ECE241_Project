module Graphics( 
		input CLOCK_50,
		input [8:0] xoffsetset,
		input [7:0] yoffsetset,
		input [3:0] KEY,
		input [7:0] score, // used to draw the digits
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
wire [11:0] data, dataRED,dataPINK,dataBLUE,dataYELLOW,dataTARGET,dataSONG1,dataSONG2,dataSONG3,
			dataH0, dataH1, dataH2, dataH3, dataH4, dataH5, dataH6, dataH7, dataH8, dataH9, dataHA, dataHB, dataHC, dataHD, dataHE, dataHF;
reg  [11:0] colour;
reg  [8:0]x,xmax,xoffset;
reg  [7:0]y,ymax,yoffset;
reg  [4:0] todraw, DrawState;
reg  next, startdraw, donedraw, waitfor, draw;
reg [23:0] delayCnt;
wire  [7:0] w;


/*

	add 16 more rom modules for .png files corresponding each of the hex digits
	
	FSM assumes each name for the hex digits is "dataHx", where x is 0, 1, 2, 3...

*/

ROM256x12TEST u0 (.address(address),.clock(CLOCK_50),.q(data));
ROM256x12RED u1 (.address(address),.clock(CLOCK_50),.q(dataRED));
ROM256X12PINK u2 (.address(address),.clock(CLOCK_50),.q(dataPINK));
ROM256X12BLUE u3 (.address(address),.clock(CLOCK_50),.q(dataBLUE));
ROM256X12YELLOW u4 (.address(address),.clock(CLOCK_50),.q(dataYELLOW));
ROM1024X12TARGET u5 (.address(address),.clock(CLOCK_50),.q(dataTARGET));

ROM992X12SONG1 u6 (.address(address),.clock(CLOCK_50),.q(dataSONG1));
ROM1082x12SONG2 u7 (.address(address),.clock(CLOCK_50),.q(dataSONG2));
ROM1024X12SONG3 u8 (.address(address),.clock(CLOCK_50),.q(dataSONG3));

localparam BG = 5'b00001, BGwait = 5'b00010, Draw1 = 5'b00011 , Draw1wait = 5'b00100, Justwait = 5'b01101; // FSM states
localparam Background = 5'b01000, Test = 5'b01111 ,Hit = 5'b000XX ,Target = 5'b00100, blank = 5'b01100, MENU1=5'b01011 , MENU2 = 5'b01010 ,MENU3 = 5'b01001 ,SONG1 = 5'b00111  ,SONG2 = 5'b00101 ,SONG3 = 5'b00110, DIGIT0 = 5'b10000, DIGIT1 = 5'b10001; // Draw states
localparam RED = 5'b00010, BLUE = 5'b00011 ,YELLOW = 5'b00001 ,PINK = 5'b00000; // hitboxes
localparam DELAY = 5000000;// Delay

// hex digits
localparam H0 = 5'b10000, H1 = 5'b10001, H2 = 5'b10010, H3 = 5'b10011, H4 = 5'b10100, H5 = 5'b10101, H6 = 5'b10110, H7 = 5'b10111, 
		   H8 = 5'b11000, H9 = 5'b11001, HA = 5'b11010, HB = 5'b11011, HC = 5'b11100, HD = 5'b11101, HE = 5'b11110, HF = 5'b11111;

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
				DIGIT0: begin
					xoffset = xoffsetset;
					yoffset = yoffsetset;
					xmax = /* something */ + xoffset;
					ymax = /* something */ + yoffset;
					next = 1;
				end
				DIGIT1: begin
					xoffset = xoffsetset;
					yoffset = yoffsetset;
					xmax = /* something */ + xoffset;
					ymax = /* something */ + yoffset;
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
			DIGIT0: begin
				case({1'b1, score[3:0]}) // I hope this works
					H0: colour <= dataH0;
					H1: colour <= dataH1;
					H2: colour <= dataH2;
					H3: colour <= dataH3;
					H4: colour <= dataH4;
					H5: colour <= dataH5;
					H6: colour <= dataH6;
					H7: colour <= dataH7;
					H8: colour <= dataH8;
					H9: colour <= dataH9;
					HA: colour <= dataHA;
					HB: colour <= dataHB;
					HC: colour <= dataHC;
					HD: colour <= dataHD;
					HE: colour <= dataHE;
					HF: colour <= dataHF;
				endcase
			end
			DIGIT1: begin
				case({1'b1, score[7:4]})
					H0: colour <= dataH0;
					H1: colour <= dataH1;
					H2: colour <= dataH2;
					H3: colour <= dataH3;
					H4: colour <= dataH4;
					H5: colour <= dataH5;
					H6: colour <= dataH6;
					H7: colour <= dataH7;
					H8: colour <= dataH8;
					H9: colour <= dataH9;
					HA: colour <= dataHA;
					HB: colour <= dataHB;
					HC: colour <= dataHC;
					HD: colour <= dataHD;
					HE: colour <= dataHE;
					HF: colour <= dataHF;
				endcase
			end
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
