`timescale 1ns/1ns

/*
	create 2 instances of "hit_detector" in top level module,
	1 for the left bongo, 1 for the right bongo
	
	connect "go" to whatever detects a button press by the user
	connect "stream" to whatever shift register is playing the song
	"hit" is the output signal to animation modules to identify a successful hit

*/
module hit_detector(
    input clk, 
    input reset_b, 
    input go, 
    input [2:0] stream, // bit stream for bongo => 1 indicates a button the user has to press
    output reg hit // signal to animation modules if the user has successfully hit the bongo
	);

   localparam CLICK_WAIT = 0, CLICK = 1;
   reg [3:0] cur_s, next_s;
   
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
			
			// if at least 1 bit of the bitstream is set, close enough to be considered a hit
			if(stream != 0)
				hit = 1;
			
			cur_s <= next_s;
		end
		else
			cur_s <= next_s;
    end

endmodule
