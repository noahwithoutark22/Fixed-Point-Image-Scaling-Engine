`timescale 1fs / 1fs
module coordgen #(parameter WIDTH=4) (
    input incx,
    input incy,
    input rstx,
    input rsty,
    input rst,
    input clk,
    output reg [WIDTH-1:0] x_out,
    output reg [WIDTH-1:0] y_out
    );
    always @(posedge clk) begin
        if(rst) begin
            x_out <= 0;
            y_out <= 0;
        end
        if(rstx) x_out<=0;
        if(rsty) y_out<=0;
        if(incx) x_out <= x_out + 1;
        if(incy) y_out <= y_out + 1;
    end
endmodule