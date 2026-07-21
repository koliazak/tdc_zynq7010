# =================== SYSTEM CLOCK ================

create_clock -period 20.000 -name clk_in [get_ports clk_in]
set_property IOSTANDARD LVCMOS33 [get_ports clk_in]
set_property PACKAGE_PIN N18 [get_ports clk_in]


# =================== TDC PLACEMENT ===============

create_pblock pblock_tdc
add_cells_to_pblock [get_pblocks pblock_tdc] [get_cells -quiet [list tdc_inst]]
resize_pblock [get_pblocks pblock_tdc] -add {SLICE_X40Y60:SLICE_X43Y99}
set_property IS_SOFT FALSE [get_pblocks pblock_tdc]

set_property DONT_TOUCH true [get_cells -hier *carry4*]
set_property KEEP_HIERARCHY TRUE [get_cells tdc_inst]

set_clock_groups -asynchronous \
    -group [get_clocks clk_in] \
    -group [get_clocks clk_out0_unbuf] \
    -group [get_clocks clk_out1_unbuf]
