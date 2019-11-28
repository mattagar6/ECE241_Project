module screenlogic(CLOCK_50,KEY,background, gameover, ob1a,ob1axy,ob2a,ob2axy,ob3a,ob3axy,ob1b,ob1bxy,ob2b,ob2bxy,ob3b,ob3bxy,start,Screen);


input [3:0] KEY;
input CLOCK_50;
input gameover;

reg [1:0] screen, menuscreen, menunext;
reg [11:0] setbackground;
output [11:0] background;
output [4:0] ob1a ,ob1b , ob2a , ob2b , ob3a , ob3b;
output [16:0] ob1axy , ob1bxy , ob2axy , ob2bxy , ob3axy , ob3bxy;
output start;
output [1:0] Screen;
reg [9:0] ob1s, ob2s, ob3s;

reg startgame, menu;

wire [3:0] w;

or(w[0],~KEY[0],~KEY[1]);
or(w[1],~KEY[2],~KEY[3]);
or(w[2],w[1],w[0]);

assign background = setbackground;
assign start = startgame;
assign Screen = screen;

initial begin
startgame<=0;
screen <= 2'b00;
menuscreen <= 2'b11;
end

always@(posedge CLOCK_50)
	begin
		case(screen)
			2'b00://Mainscreen
				begin
				menu <=0;
				setbackground <= 12'b000001110111;
				if(w[2])
				screen <= 2'b01;
				end
			2'b01://Menu
				begin
				menu <=1;
				setbackground <= 12'b011101110000;
				if(startgame)
				screen <= 2'b10;
				end
			2'b10://Game
				begin 
				menu <=0;
				setbackground <= 12'b000001110000;
				if(gameover)
					screen <= 2'b01;
				end
			default: screen <= 2'b00;
		endcase
	end


	
always@(posedge CLOCK_50)
begin
	case(menuscreen)
		2'b00://startgame
			begin
				startgame <= 0;
				ob1s <= 10'b0011101011;
				ob2s <= 10'b0010101010;
				ob3s <= 10'b0011001001;
				if( ~KEY[0])
					menunext<=2'b01;
				if( ~KEY[1])
					menunext<=2'b10;
				if(~KEY[2])
					begin
						startgame <= 1;
						menunext<=2'b11;
					end
			end
		2'b01://placeholder
			begin
				ob1s <= 10'b0011001001;
				ob2s <= 10'b0011101011;
				ob3s <= 10'b0010101010;
				if( ~KEY[0])
					menunext<=2'b10;
				if( ~KEY[1])
					menunext<=2'b00;
			end
		2'b10://placeholder
			begin
				ob1s <= 10'b0010101010;
				ob2s <= 10'b0011001001;
				ob3s <= 10'b0011101011;
				if( ~KEY[0])
					menunext<=2'b00;
				if( ~KEY[1])
					menunext<=2'b01;
			end
		2'b11://wait
			begin
				if(menu)
					menunext<=2'b00;
				else
				begin
					ob1s <= 10'b0110001100;
					ob2s <= 10'b0110001100;
					ob3s <= 10'b0110001100;
					startgame <= 0;
			end
			end
		default:
			menunext<=2'b11;
	endcase
end
assign ob1axy = 17'b01101000001110000;
assign ob2axy = 17'b01101000000001000;
assign ob3axy = 17'b01101000011011000;
assign ob1bxy = 17'b01110000010010000;
assign ob2bxy = 17'b01110000000101000;
assign ob3bxy = 17'b01110000011111000;
assign ob1a = ob1s[4:0];
assign ob1b = ob1s[9:5];
assign ob2a = ob2s[4:0];
assign ob2b = ob2s[9:5];
assign ob3a = ob3s[4:0];
assign ob3b = ob3s[9:5];


always@(negedge w[2])
begin
menuscreen <= menunext;
end
endmodule
