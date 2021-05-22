
module TopEntity ( 
		
		// ----------- CLOCKS --------------
		input         clk_u59,
		input 	     clk_y3,
		input 	     clk_y4,
		input 	     clk_y5,
		input 	     clk_y6,
		input			  clk_pcie1,
		input			  clk_pcie2,
	 
		// ------------ LEDS ---------------
		output [8:0]	leds	
);

	reg [31:0] alive_count;
	
	assign leds[8:0] = alive_count[31:23];
	
	always @ (posedge clk_u59)
	begin
		alive_count <= alive_count + 1'b1;
	end

endmodule 