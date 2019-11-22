module screenlogic(CLOCK_50,KEY,LEDR);


input [3:0] KEY;
input CLOCK_50;
output [7:0]LEDR;

reg [1:0] screen;
reg [1:0] menuscreen;

reg startgame,gameover,menu;

wire [3:0] w;

or(w[0],~KEY[0],~KEY[1]);
or(w[1],~KEY[2],~KEY[3]);
or(w[2],w[1],w[0]);

assign LEDR[1:0] = w[2:1];
assign LEDR[3:2] = screen;
assign LEDR[5:4] = menuscreen;
assign LEDR[6] = menu;
assign LEDR[7] = startgame;


initial begin
gameover <= 0;
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
				if(w[2])
				screen <= 2'b01;
				end
			2'b01://Menu
				begin
				menu <=1;
				if(startgame)
				screen <= 2'b10;
				end
			2'b10://Game
				begin 
				menu <=0;
				if(gameover)
				screen <= 2'b01;
				end
			default: screen <= 2'b00;
		endcase
	end


	
always@(posedge w[2])
begin
	case(menuscreen)
		2'b00://startgame
			begin
				startgame <= 0;
				if( ~KEY[0])
					menuscreen<=2'b01;
				else if( ~KEY[1])
					menuscreen<=2'b10;
				else if(~KEY[2])
					begin
						startgame <= 1;
						menuscreen<=2'b11;
					end
			end
		2'b01://placeholder
			begin
				if( ~KEY[0])
					menuscreen<=2'b10;
				else if( ~KEY[1])
					menuscreen<=2'b00;
			end
		2'b10://placeholder
			begin
				if( ~KEY[0])
					menuscreen<=2'b00;
				else if( ~KEY[1])
					menuscreen<=2'b01;
			end
		2'b11://wait
			begin
				if(menu)
					menuscreen<=2'b00;
				else
					startgame <= 0;
			end
		default:
			menuscreen<=2'b00;
	endcase
end

endmodule
