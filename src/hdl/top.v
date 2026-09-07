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
    wire [(32*4)-1:0] tdc_data_out_0;
    (* DONT_TOUCH = "TRUE" *) 
    wire [(32*4)-1:0] tdc_data_out_1;
    (* DONT_TOUCH = "TRUE" *) 
    wire [(32*4)-1:0] tdc_data_out_2;
    (* DONT_TOUCH = "TRUE" *) 
    wire [(32*4)-1:0] tdc_data_out_3;

    
    tdc_carry4 #(
        .LEVEL_COUNT(32)
    ) tdc_inst_0 (
        .clk(clk_in),
        .start(start),
        .stop(stop),
        .tdc_data_out(tdc_data_out_0)
    );
          
    tdc_carry4 #(
        .LEVEL_COUNT(32)
    ) tdc_inst_1 (
        .clk(clk_in),
        .start(start),
        .stop(stop),
        .tdc_data_out(tdc_data_out_1)
    );
    
    tdc_carry4 #(
        .LEVEL_COUNT(32)
    ) tdc_inst_2 (
        .clk(clk_in),
        .start(start),
        .stop(stop),
        .tdc_data_out(tdc_data_out_2)
    );
            
    tdc_carry4 #(
        .LEVEL_COUNT(32)
    ) tdc_inst_3 (
        .clk(clk_in),
        .start(start),
        .stop(stop),
        .tdc_data_out(tdc_data_out_3)
    );


    // ================ VIO =================    
    
    vio_0 vio_inst (
        .clk(clk_in),
        .probe_in0(tdc_data_out_0[127:0]),
        .probe_in1(tdc_data_out_1[127:0]),
        .probe_in2(tdc_data_out_2[127:0]),
        .probe_in3(tdc_data_out_3[127:0]),
        .probe_in4(psdone),
        .probe_out0(vio_psen),
        .probe_out1(vio_psincdec)
    );


    // ================ ILA =================    

    ila_0 ila_inst (
        .clk(clk_in),
        .probe0(tdc_data_out_0),
        .probe1(tdc_data_out_1),
        .probe2(tdc_data_out_2),
        .probe3(tdc_data_out_3),
        .probe4(start),
        .probe5(stop),
        .probe6(psdone)
    );
    
endmodule
