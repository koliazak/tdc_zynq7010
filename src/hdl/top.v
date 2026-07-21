`timescale 1ns / 1ps

module top(
    input  wire                       clk_in
//    output wire [(4*4)-1:0]           tdc_data_out 
    );
    
    
    // ================ MMCM Tester =================    
    
    wire start;
    wire stop;
    wire psdone;
    
    wire vio_psen;
    wire vio_psincdec;
    
    tdc_mmcm_tester mmcm_tester_inst (
        .clk_in     (clk_in),
        .reset      (1'b0),
        .psen       (vio_psen),
        .psincdec   (vio_psincdec),
        .psdone     (psdone),
        .start_clk  (start),
        .stop_clk   (stop)
    );


    // ================ TDC =================   
    
    (* DONT_TOUCH = "TRUE" *) 
    wire [(32*4)-1:0] tdc_data_out;
    
    tdc_carry4 #(
        .LEVEL_COUNT(32)
    ) tdc_inst (
        .clk(clk_in),
        .start(start),
        .stop(stop),
        .tdc_data_out(tdc_data_out)
    );
  

    // ================ VIO =================    
    
    vio_0 vio_inst (
        .clk(clk_in),
        .probe_in0(tdc_data_out[127:0]),
        .probe_in1(psdone),
        .probe_out0(vio_psen),
        .probe_out1(vio_psincdec)
    );


    // ================ ILA =================    

    ila_0 ila_inst (
        .clk(clk_in),
        .probe0(tdc_data_out),
        .probe1(start),
        .probe2(stop),
        .probe3(psdone)
    );
    
endmodule
