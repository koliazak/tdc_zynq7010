`timescale 1ns / 1ps

module tdc_mmcm_tester (
    input  wire clk_in,       // 50MHz | 20ns
    input  wire reset,
    
    // dynamic phase shift (VIO)
    input  wire psen,         // phase activation
    input  wire psincdec,     // 1 = incr delay, 0 = decr delay
    output wire psdone,       // phase shift done flag
    
    // TDC signals
    output wire start_clk,
    output wire stop_clk
);
  
    wire clkfb_in, clkfb_out;
    wire clk_out0_unbuf, clk_out1_unbuf;
    wire psdone_raw;
    
    // =================== Edge detection ========================

    reg psen_d;
    wire psen_pulse;

    always @(posedge clk_in) psen_d <= psen;
    assign psen_pulse = psen & ~psen_d;

    
    // ================ PSDONE flag =================    
     
     reg psdone_sticky;
     
     always @(posedge clk_in) begin
        if (psen_pulse)
            psdone_sticky <= 1'b0;
        else if (psdone_raw)
            psdone_sticky <= 1'b1;
     end

    assign psdone = psdone_sticky;


    // =================== MMCM inst ========================
    MMCME2_ADV #(
        .BANDWIDTH            ("OPTIMIZED"),
        .COMPENSATION         ("ZHOLD"),
        .STARTUP_WAIT         ("FALSE"),
        .DIVCLK_DIVIDE        (1),
        // 50 MHz (20 ns)
        .CLKIN1_PERIOD        (20.000), 
        // multyplyer VCO: 50 MHz * 20 = 1000 MHz
        .CLKFBOUT_MULT_F      (20.000), 
        .CLKFBOUT_PHASE       (0.000),
        
        // Settings for output 0 (start) - 50 MHz (1000 / 20 = 50)
        .CLKOUT0_DIVIDE_F     (20.000),
        .CLKOUT0_PHASE        (0.000),
        .CLKOUT0_DUTY_CYCLE   (0.500),
        
        // Settings for output 1 (stop) - 50 MHz with phase shift
        .CLKOUT1_DIVIDE       (20),
        .CLKOUT1_PHASE        (0.000),
        .CLKOUT1_DUTY_CYCLE   (0.500),
        .CLKOUT1_USE_FINE_PS  ("TRUE") // ENABLE dynamic phase shift
    ) mmcm_inst (
        .CLKIN1     (clk_in),
        .CLKIN2     (1'b0),
        .CLKINSEL   (1'b1),
        
        .CLKFBIN    (clkfb_in),
        .CLKFBOUT   (clkfb_out),
        
        // MMCM outputs (to buffers)
        .CLKOUT0    (clk_out0_unbuf),
        .CLKOUT1    (clk_out1_unbuf),
        
        // dynamic phase shift
        .PSCLK      (clk_in),
        .PSEN       (psen_pulse),
        .PSINCDEC   (psincdec),
        .PSDONE     (psdone_raw),
        
        
        .RST        (reset),
        .PWRDWN     (1'b0)
    );
    
    
    // ======================== BUFG ===================
    
    BUFG bufg_fb (
        .I (clkfb_out),
        .O (clkfb_in)
    );

    BUFG bufg_start (
        .I (clk_out0_unbuf),
        .O (start_clk)
    );

    BUFG bufg_stop (
        .I (clk_out1_unbuf),
        .O (stop_clk)
    );

endmodule
