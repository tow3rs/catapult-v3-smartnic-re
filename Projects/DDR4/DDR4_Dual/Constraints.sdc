derive_pll_clocks -create_base_clocks

#100 MHz from U59
create_clock -period 10 [get_ports clk_u59]

#266.667 MHz DDR TOP from Y4
create_clock -period 3.75 [get_ports clk_y4]

#266.667 MHz DDR BOTTOM from Y3
create_clock -period 3.75 [get_ports clk_y3]

#644.53125 MHz QSFP from Y5
create_clock -period 1.551 [get_ports clk_y5]

#644.53125 MHz Mellanox XCVR from Y6 in PCIe variant
create_clock -period 1.551 [get_ports clk_y6]

#156.250 MHz Mellanox XCVR from Y6 in OCP variant
#create_clock -period 6.4 [get_ports clk_y6]

#100MHz PCIe#1 Ref clock from U56
create_clock -period 10 [get_ports clk_pcie1]

#100MHz PCIe#2 Ref clock from U56
create_clock -period 10 [get_ports clk_pcie2]

set_false_path -to [get_ports {leds[*]}]