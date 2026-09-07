create_clock -period 20.000 -name clk_in [get_ports clk_in]
set_property IOSTANDARD LVCMOS33 [get_ports clk_in]
set_property PACKAGE_PIN N18 [get_ports clk_in]

# =================== TDC PLACEMENT ===============

create_pblock pblock_tdc_0
add_cells_to_pblock [get_pblocks pblock_tdc_0] [get_cells -quiet [list tdc_inst_0]]
resize_pblock [get_pblocks pblock_tdc_0] -add {SLICE_X40Y60:SLICE_X43Y99}
set_property IS_SOFT FALSE [get_pblocks pblock_tdc_0]

create_pblock pblock_tdc_1
add_cells_to_pblock [get_pblocks pblock_tdc_1] [get_cells -quiet [list tdc_inst_1]]
resize_pblock [get_pblocks pblock_tdc_1] -add {SLICE_X0Y60:SLICE_X3Y99}
set_property IS_SOFT FALSE [get_pblocks pblock_tdc_1]

create_pblock pblock_tdc_2
add_cells_to_pblock [get_pblocks pblock_tdc_2] [get_cells -quiet [list tdc_inst_2]]
resize_pblock [get_pblocks pblock_tdc_2] -add {SLICE_X0Y0:SLICE_X3Y33}
set_property IS_SOFT FALSE [get_pblocks pblock_tdc_2]

create_pblock pblock_tdc_3
add_cells_to_pblock [get_pblocks pblock_tdc_3] [get_cells -quiet [list tdc_inst_3]]
resize_pblock [get_pblocks pblock_tdc_3] -add {SLICE_X40Y0:SLICE_X43Y33}
set_property IS_SOFT FALSE [get_pblocks pblock_tdc_3]

set_property DONT_TOUCH true [get_cells -hier *carry4*]
set_property KEEP_HIERARCHY TRUE [get_cells tdc_inst_0]
set_property KEEP_HIERARCHY TRUE [get_cells tdc_inst_1]
set_property KEEP_HIERARCHY TRUE [get_cells tdc_inst_2]
set_property KEEP_HIERARCHY TRUE [get_cells tdc_inst_3]



#set_property LOC SLICE_X27Y99 [get_cells tdc_inst/carry4_inst_first]

set_clock_groups -asynchronous \
    -group [get_clocks clk_in] \
    -group [get_clocks clk_out0_unbuf] \
    -group [get_clocks clk_out1_unbuf]
