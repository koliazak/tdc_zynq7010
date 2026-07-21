`timescale 1ns / 1ps

module tdc_carry4 #(
    parameter LEVEL_COUNT = 32
)(
    input  wire                       clk,
    input  wire                       start,
    input  wire                       stop,
    output reg  [(LEVEL_COUNT*4)-1:0] tdc_data_out
);

    (* KEEP = "TRUE", ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) 
    reg  [(LEVEL_COUNT*4)-1:0] sample_reg;

    wire [(LEVEL_COUNT*4)-1:0] carry_data_out;
    wire  [(LEVEL_COUNT*4)-1:0] carry_out;
    wire [LEVEL_COUNT-1:0] cyinit;
    wire [LEVEL_COUNT-1:0] ci;
    wire [3:0] s_inputs [LEVEL_COUNT-1:0];
    
    assign cyinit[0] = start; 
    assign ci[0]     = 1'b0;
    
    assign s_inputs[0] = 4'b1111;
    
    (* DONT_TOUCH = "TRUE" *) CARRY4 carry4_inst_first (
        .CO     (carry_out[3:0]),
        .O      (carry_data_out[3:0]),
        .CI     (ci[0]),
        .CYINIT (cyinit[0]),
        .DI     (4'b0000),
        .S      (s_inputs[0])
    );
    
    
    genvar i;
    generate
        for (i = 1; i < LEVEL_COUNT; i = i + 1) begin : carry_chain
            assign cyinit[i]   = 1'b0;
            assign ci[i]       = carry_out[i*4-1];
            assign s_inputs[i] = 4'b1111;

            (* DONT_TOUCH = "TRUE" *) CARRY4 carry4_inst_next (
                .CO     (carry_out[i*4 +: 4]),
                .O      (carry_data_out[i*4 +: 4]),
                .CI     (ci[i]),
                .CYINIT (cyinit[i]),
                .DI     (4'b0000),
                .S      (s_inputs[i])
            );
        end
    endgenerate
    
    
    always @(posedge stop) begin
        sample_reg <= carry_out;
    end

    always @(posedge clk) begin
        tdc_data_out <= sample_reg;
    end
    
    
endmodule
