
module autoPNGVGA( CLOCK_50 , LEDR, KEY , VGA_CLK , VGA_HS , VGA_VS , VGA_BLANK_N , VGA_SYNC_N , VGA_R , VGA_G , VGA_B );

input	CLOCK_50;
input [3:0] KEY;

output	VGA_CLK;
output	VGA_HS;
output	VGA_VS;
output	VGA_BLANK_N;
output	VGA_SYNC_N;
output	[7:0]	VGA_R;
output	[7:0]	VGA_G;
output	[7:0]	VGA_B;

output [9:0]LEDR;

reg [15:0] address;
wire [11:0] data;
reg [11:0] colour;
reg  [8:0]x;
reg  [7:0]y;
reg  [8:0]xmax;
reg  [7:0]ymax;
reg  [8:0]xoffset;
reg  [7:0]yoffset;
reg  [8:0]xoffsetset;
reg  [7:0]yoffsetset;
reg  [3:0] todraw, DrawState;
reg  donedraw, next, startdraw;
wire  [3:0] w;


//gradient 8bit
/*
ROM65536x24 (.address(address),.clock(CLOCK_50),.q(data));
*/


// Gradient Picture 4bit

//ROM65536x12 (.address(address),.clock(CLOCK_50),.q(data));

//gradient 3bit
/*
ROM65536x3 (.address(address),.clock(CLOCK_50),.q(data));
*/

ROM256x12TEST(.address(address),.clock(CLOCK_50),.q(data));


localparam BG = 4'b0001 , BGwait = 4'b0010 , Draw1 = 4'b0011 , Draw1wait = 4'b0100 ,Draw2 = 4'b0101 , Draw2wait = 4'b0110 , Draw3 = 4'b0111 , Draw3wait = 4'b1000 ,Draw4 = 4'b1001 , Draw4wait = 4'b1010 , Draw5 = 4'b1011 , Draw5wait = 4'b1100, Justwait = 4'b1101;

localparam Background = 4'b0001, Iteam1 = 4'b0010 ;

initial begin
address <= 16'b0000000000000000;
x<=9'd0;
y<=8'd0;
DrawState <= Draw1;
donedraw <=0;
next <= 0;
startdraw <= 0;
end

reg setdraw;

always@(posedge CLOCK_50)
begin: drawingstate
case(DrawState)

BG: 

begin
setdraw <= 1;
startdraw <= 0;
todraw <= Background;
if(next == 1)
DrawState <= BGwait;
end

BGwait:

begin

setdraw <= 0;
startdraw <= 1;
if(donedraw == 1)
DrawState <= Draw1;
end

Draw1:

begin
setdraw <= 1;
todraw = Iteam1;
startdraw <= 0;
xoffsetset <= 9'd16;
yoffsetset <= 8'd16;
if(next == 1)
DrawState <= Draw1wait;
end

Draw1wait:

begin
setdraw <= 0;
startdraw <= 1;
if(donedraw == 1)
DrawState <= Draw2;
end

Draw2:

begin
setdraw <= 1;
todraw = Iteam1;
startdraw <= 0;
xoffsetset <= 9'd32;
yoffsetset <= 8'd32;
if(next == 1)
DrawState <= Draw2wait;
end

Draw2wait:

begin
setdraw <= 0;
startdraw <= 1;
if(donedraw == 1)
DrawState <= Draw3;
end

Draw3:

begin
setdraw <= 1;
todraw = Iteam1;
startdraw <= 0;
xoffsetset <= 9'd64;
yoffsetset <= 8'd64;
if(next == 1)
DrawState <= Draw3wait;
end

Draw3wait:

begin
setdraw <= 0;
startdraw <= 1;
if(donedraw == 1)
DrawState <= Draw4;
end

Draw4:

begin
setdraw <= 1;
todraw = Iteam1;
startdraw <= 0;
xoffsetset <= 0;
yoffsetset <= 8'd64;
if(next == 1)
DrawState <= Draw4wait;
end

Draw4wait:

begin
setdraw <= 0;
startdraw <= 1;
if(donedraw == 1)
DrawState <= Draw5;
end

Draw5:

begin
setdraw <= 1;
todraw = Iteam1;
startdraw <= 0;
xoffsetset <= 9'd64;
yoffsetset <= 0;
if(next == 1)
DrawState <= Draw5wait;
end

Draw5wait:

begin
setdraw <= 0;
startdraw <= 1;
if(donedraw == 1);
DrawState <= Justwait;
end

Justwait:
startdraw <= 0;

endcase
end



always@(setdraw)
begin: drawsetter

next <= 0;

case(todraw)


Background:
begin
xoffset <= 0;
yoffset <= 0;
xmax <= 9'd320 ;
ymax <= 8'd240 ;
next <= 1;
end

Iteam1:
//TEST
begin
xoffset <= xoffsetset;
yoffset <= yoffsetset;
xmax <= 9'd15 + xoffset ;
ymax <= 8'd15 + yoffset;
next <= 1;
end



endcase
end

and(w[0],startdraw,CLOCK_50);




always@(posedge w[0])
begin: imagesetter
address <= 0;
donedraw <= 0;

case(x)
xmax: begin

if (y == ymax)
donedraw <= 1;
else
x<= xoffset;
y<=y+1;
address <= address +1;
end

default:
begin
if(address == 0)
begin
x <= xoffset;
y <= yoffset;
end

address <= address +1;
x <= x+1;
y <= y;

end
endcase
end



always@(*)
begin: dataset



case(todraw)

Background:
begin
colour <= 12'b111111111111;
end

Iteam1:
//TEST
begin
colour <= data;
end

endcase

end

// donedraw, DrawState, todraw, next, startdraw

assign LEDR[0] = donedraw;
assign LEDR[1] = DrawState;
assign LEDR[2] = todraw;
assign LEDR[3] = next;
assign LEDR[4] = startdraw;

assign LEDR[9:6] = DrawState;


vga_adapter VGA0 (.resetn(KEY[0]),.clock(CLOCK_50),.colour(colour),.x(x),.y(y),.plot(KEY[2]),.VGA_R(VGA_R),.VGA_G(VGA_G),.VGA_B(VGA_B),.VGA_HS(VGA_HS),.VGA_VS(VGA_VS),.VGA_BLANK(VGA_BLANK_N),.VGA_SYNC(VGA_SYNC_N),	.VGA_CLK(VGA_CLK));

defparam VGA0.RESOLUTION = "320x240";
defparam VGA0.MONOCHROME = "FALSE";
defparam VGA0.BITS_PER_COLOUR_CHANNEL = 4;
defparam VGA0.BACKGROUND_IMAGE = "black.mif";

endmodule


