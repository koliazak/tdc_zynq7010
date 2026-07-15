`timescale 1ns / 1ps

module top(
    input  wire                       clk,
    input  wire                       start,
    input  wire                       stop
//    output wire [(4*4)-1:0]           tdc_data_out 
    );
    
(* DONT_TOUCH = "TRUE" *) wire [(32*4)-1:0] tdc_data_out;
        
tdc_carry4 #(
    .LEVEL_COUNT(32)
) tdc_inst (
    .clk(clk),
    .start(start),
    .stop(stop),
    .tdc_data_out(tdc_data_out)
);

    
endmodule
