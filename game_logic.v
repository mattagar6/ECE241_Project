`timescale 1ns/1ns

module hit_detector(
    input clk, 
    input resetb, 
    input go, 
    // neeed some way to check wether there is something at the hit marker
    // input registers for position of keys to press?
    output reg hit);

   localparam CLICK_WAIT = 0, CLICK = 1;
   reg [3:0] cur_s, next_s;
   
   always@(*)
    begin: state_table
      case(cur_s)
        CLICK_WAIT:
          next_s = go ? CLICK : CLICK_WAIT;
        CLICK:
          next_s = CLICK_WAIT;
      endcase
    end
    
    always@(posedge clk) begin
      if(reset_b == 1'b0)
        hit <= 0;
        cur_s <= CLICK_WAIT;
      else if(cur_s == CLICK) begin
        //logic to send the correct output signal to "hit", based on position of keys relative to hit marker
        cur_s <= next_s;
      end
      else
        cur_s <= next_s;
    end

endmodule
