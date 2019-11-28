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
		
		
wire start, hit;
wire [8:0]xoffset;
wire [24:0] drawstream;
wire [1:0] screen;
reg [29:0] todraw;
reg [101:0] topos;
wire [29:0] menubuttons;
wire [101:0] menupos;
wire[239:0] stream;
reg [8:0]disttohit;
wire [7:0] score;
wire [2:0] w;
wire [11:0] background;
wire done;

or(w[0],~KEY[0],~KEY[1]);
or(w[1],~KEY[2],~KEY[3]);
or(w[2],w[1],w[0]);

assign LEDR = stream[19:10];



	
	Graphics u0(
					.CLOCK_50(CLOCK_50),
					.background(background),
					.score(score),
					.inputs(todraw),
					.pos(topos),
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
					.go(w[2]),
					.stream(xoffset),
					.target(stream[1:0]),
					.hit(hit),
					.KEY(KEY),
					);
					
					
	screenlogic u2 (
				.CLOCK_50(CLOCK_50),
				.KEY(KEY),
				.background(background),
				.gameover(done),
				.ob1a(menubuttons[4:0]),
				.ob1axy(menupos[16:0]),
				.ob2a(menubuttons[14:10]),
				.ob2axy(menupos[50:34]),
				.ob3a(menubuttons[24:20]),
				.ob3axy(menupos[84:68]),
				.ob1b(menubuttons[9:5]),
				.ob1bxy(menupos[33:17]),
				.ob2b(menubuttons[19:15]),
				.ob2bxy(menupos[67:51]),
				.ob3b(menubuttons[29:25]),
				.ob3bxy(menupos[101:85]),
				.start(start),
				.Screen(screen),);
				
	playlogic u3 (
				.CLOCK_50(CLOCK_50),
				.start(start),
				.xoffset(xoffset),
				.drawstream(drawstream),
				.hit(hit),
				.scoreout(score),
				.streamout(stream),
				.HEX0(HEX0),
			.	done(done));
				

//Assign draw1-6		
always@(*)
begin
case(screen)
2'b00://Mainscreen
	begin
	todraw <= 29'b011000110001100011000110001100;
	topos <= 0;
	end
2'b01://Menu
	begin
	todraw <= menubuttons;
	topos <= menupos;
	end
2'b10://Game
	begin
	topos <= 0;
	todraw[4:0] <= 5'b00100;
	todraw[29:5] <= drawstream;
	topos[33:17] <= 17'd64+xoffset;
	topos[50:34] <= 17'd112+xoffset;
	topos[67:51] <= 17'd160+xoffset;
	topos[84:68] <= 17'd208+xoffset;
	topos[101:85] <= 17'd256+xoffset;
	end
default:;
endcase
end

	
endmodule
