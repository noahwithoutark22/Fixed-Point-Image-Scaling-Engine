`timescale 1fs / 1fs
module div #(parameter WIDTH=4)( //width can be given from outside as max(A,B)
   input clk,
   input start,
   input reset,
   input [WIDTH-1:0] dividend,
   input [WIDTH-1:0] divisor,
   output reg[WIDTH-1:0] quotient,
   output reg [WIDTH-1:0] remainder,
   output reg done
);
   reg [WIDTH-1:0] Q;
   reg [WIDTH-1:0] A;
   reg sign;
   parameter ITER_WIDTH = $clog2(WIDTH);
   reg [ITER_WIDTH:0] N;
   parameter INIT=0, SHIFT=1, LOAD1=2, LOAD2=3, COND=4, DONE=5;
   reg [2:0] curr_state, next_state;
   always @(posedge clk) begin
      if(reset) begin
         curr_state <= INIT;
      end
      else if(start) curr_state <= next_state;
      else curr_state <= INIT;
         end
   always @(posedge clk) 
      case (curr_state) 
         INIT: begin
            A <= 0;
            Q <= dividend;
            N <= WIDTH;
            sign <= 1'b0;
         end 
         SHIFT: begin
            sign <= A[WIDTH-1];
               {A,Q} <= {A[WIDTH-2:0], Q, 1'b0};
               N <= N-1;
            end
         LOAD1: begin
            if(sign) A <= A + divisor;
            else A <= A + (~divisor + 1'b1);
            
         end
         LOAD2: begin
            if(A[WIDTH-1]) Q[0] <= 0;
            else Q[0] <= 1;
            sign <= A[WIDTH-1];
         end
         COND: begin
            if(sign) A <= A+divisor;
         end
         DONE: begin
            A <= A;
            Q <= Q;
         end
      endcase
      
      always @(*)
      case (curr_state)
         INIT: begin next_state = SHIFT;
         done=0;
         end
         SHIFT: begin
         next_state = LOAD1;
            done=0;
         end 
         LOAD1: begin
            next_state = LOAD2;
            done=0;
         end
         LOAD2: begin            
            if(N==0) next_state = COND;
            else next_state= SHIFT;
            done=0;
         end
         COND: begin
         next_state = DONE;
            done=0;
         end 
         DONE: begin
            next_state = DONE;
            done=1;
            quotient = Q;
            remainder = A;
         end 
      endcase   
endmodule