
module TopEntity ( 
		// CLOCKS
		input         clk_u59,
		input 	     clk_y3,
		input 	     clk_y4,
		input 	     clk_y5,
		input 	     clk_y6,
		input			  clk_pcie1,
		input			  clk_pcie2,
		
		// LEDS
		output [8:0]leds, 

		// I2C channel 1
		inout 		  sda_ch1,
		inout 		  scl_ch1,
		
		// I2C channel 2
		inout 		  sda_ch2,
		inout 		  scl_ch2
);

 
	reg [31:0] count_u59;

	wire i2c_ch1_scl_oe;
	wire i2c_ch1_sda_oe;
	wire i2c_ch2_scl_oe;
	wire i2c_ch2_sda_oe;
	
	assign leds[0] = count_u59[27];

	assign scl_ch1 = i2c_ch1_scl_oe ? 1'b0 : 1'bz;
	assign sda_ch1 = i2c_ch1_sda_oe ? 1'b0 : 1'bz;

	assign scl_ch2 = i2c_ch2_scl_oe ? 1'b0 : 1'bz;
	assign sda_ch2 = i2c_ch2_sda_oe ? 1'b0 : 1'bz;

 
	always @ (posedge clk_u59)
	begin
		count_u59 <= count_u59 + 1'b1;
	end

	Qsys u1 (
	.clk_100_clk		(clk_u59),
	
	// I2C Channel 1
	.i2c_ch1_sda_in 	(sda_ch1),
	.i2c_ch1_scl_in 	(scl_ch1),
	.i2c_ch1_sda_oe 	(i2c_ch1_sda_oe),
	.i2c_ch1_scl_oe 	(i2c_ch1_scl_oe),
	
	// I2C Channel 2
	.i2c_ch2_sda_in 	(sda_ch2),
	.i2c_ch2_scl_in 	(scl_ch2),
	.i2c_ch2_sda_oe 	(i2c_ch2_sda_oe),
	.i2c_ch2_scl_oe 	(i2c_ch2_scl_oe)
	);

endmodule 