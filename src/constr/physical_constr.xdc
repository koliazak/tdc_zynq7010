create_clock -period 20.000 -name clk [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property PACKAGE_PIN N18 [get_ports clk]


set_property IOSTANDARD LVCMOS33 [get_ports start]
set_property IOSTANDARD LVCMOS33 [get_ports stop]

set_property PACKAGE_PIN J20 [get_ports start]
set_property PACKAGE_PIN N20 [get_ports stop]



#set_property IOSTANDARD LVCMOS33 [get_ports {tdc_data_out[15]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {tdc_data_out[14]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {tdc_data_out[13]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {tdc_data_out[12]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {tdc_data_out[11]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {tdc_data_out[10]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {tdc_data_out[9]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {tdc_data_out[8]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {tdc_data_out[7]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {tdc_data_out[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {tdc_data_out[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {tdc_data_out[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {tdc_data_out[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {tdc_data_out[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {tdc_data_out[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {tdc_data_out[0]}]

#set_property PACKAGE_PIN M17 [get_ports {tdc_data_out[15]}]
#set_property PACKAGE_PIN P18 [get_ports {tdc_data_out[14]}]
#set_property PACKAGE_PIN K19 [get_ports {tdc_data_out[13]}]
#set_property PACKAGE_PIN M19 [get_ports {tdc_data_out[12]}]
#set_property PACKAGE_PIN M20 [get_ports {tdc_data_out[11]}]
#set_property PACKAGE_PIN L17 [get_ports {tdc_data_out[10]}]
#set_property PACKAGE_PIN M18 [get_ports {tdc_data_out[9]}]
#set_property PACKAGE_PIN L20 [get_ports {tdc_data_out[8]}]
#set_property PACKAGE_PIN J18 [get_ports {tdc_data_out[7]}]
#set_property PACKAGE_PIN G20 [get_ports {tdc_data_out[6]}]
#set_property PACKAGE_PIN J19 [get_ports {tdc_data_out[5]}]
#set_property PACKAGE_PIN K18 [get_ports {tdc_data_out[4]}]
#set_property PACKAGE_PIN L19 [get_ports {tdc_data_out[3]}]
#set_property PACKAGE_PIN L16 [get_ports {tdc_data_out[2]}]
#set_property PACKAGE_PIN H20 [get_ports {tdc_data_out[1]}]
#set_property PACKAGE_PIN G19 [get_ports {tdc_data_out[0]}]


# =================== TDC PLACEMENT ===============

create_pblock pblock_tdc
add_cells_to_pblock [get_pblocks pblock_tdc] [get_cells -quiet [list tdc_inst]]
resize_pblock [get_pblocks pblock_tdc] -add {SLICE_X40Y60:SLICE_X43Y99}
set_property IS_SOFT FALSE [get_pblocks pblock_tdc]

set_property DONT_TOUCH true [get_cells -hier *carry4*]
set_property KEEP_HIERARCHY TRUE [get_cells tdc_inst]

#set_property LOC SLICE_X27Y99 [get_cells tdc_inst/carry4_inst_first]



