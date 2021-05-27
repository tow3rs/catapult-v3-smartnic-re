
module TopEntity ( 

		// CLOCKS
		input         clk_u59,
		input 	     clk_y3,
		input 	     clk_y4,
		input			  clk_y5,
		input			  clk_y6,
		input			  clk_pcie1,
		input			  clk_pcie2,
		
		// LEDs
		output [8:0] leds,
		
		// PCIe Interface#2
		input           pcie2_perstn,
		input  [ 7:0]   pcie2_rx,
		output [ 7:0]   pcie2_tx
);

 	reg [31:0] alive_count; 
	assign leds[8] = alive_count[25];
	
	always @ (posedge clk_u59)
	begin
		alive_count <= alive_count + 1'b1;
	end
	
	Qsys u0 (
	
		// ------ CLOCKS --------
		.clk_100_clk                       (clk_u59),
		
		//---------- PCIe Interface#1	--------
		.pcie_a10_hip_2_refclk_clk         (clk_pcie2),
		.pcie_a10_hip_2_npor_npor          (1'b1),
		.pcie_a10_hip_2_npor_pin_perst     (pcie2_perstn),
		.pcie_a10_hip_2_hip_serial_rx_in0  (pcie2_rx[0]), 
		.pcie_a10_hip_2_hip_serial_rx_in1  (pcie2_rx[1]), 
		.pcie_a10_hip_2_hip_serial_rx_in2  (pcie2_rx[2]), 
		.pcie_a10_hip_2_hip_serial_rx_in3  (pcie2_rx[3]), 
		.pcie_a10_hip_2_hip_serial_rx_in4  (pcie2_rx[4]), 
		.pcie_a10_hip_2_hip_serial_rx_in5  (pcie2_rx[5]), 
		.pcie_a10_hip_2_hip_serial_rx_in6  (pcie2_rx[6]), 
		.pcie_a10_hip_2_hip_serial_rx_in7  (pcie2_rx[7]), 
		.pcie_a10_hip_2_hip_serial_tx_out0 (pcie2_tx[0]), 
		.pcie_a10_hip_2_hip_serial_tx_out1 (pcie2_tx[1]), 
		.pcie_a10_hip_2_hip_serial_tx_out2 (pcie2_tx[2]), 
		.pcie_a10_hip_2_hip_serial_tx_out3 (pcie2_tx[3]), 
		.pcie_a10_hip_2_hip_serial_tx_out4 (pcie2_tx[4]), 
		.pcie_a10_hip_2_hip_serial_tx_out5 (pcie2_tx[5]), 
		.pcie_a10_hip_2_hip_serial_tx_out6 (pcie2_tx[6]), 
		.pcie_a10_hip_2_hip_serial_tx_out7 (pcie2_tx[7]), 
		.pcie_a10_hip_2_coreclkout_hip_clk (),
		
		//--------- GPIO ----------
		.pio_0_external_connection_export(leds[7:0])
		);



endmodule 