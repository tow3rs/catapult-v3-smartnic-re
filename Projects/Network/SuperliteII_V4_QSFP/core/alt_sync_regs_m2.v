// Copyright 2012 Altera Corporation. All rights reserved.  
// Altera products are protected under numerous U.S. and foreign patents, 
// maskwork rights, copyrights and other intellectual property laws.  
//
// This reference design file, and your use thereof, is subject to and governed
// by the terms and conditions of the applicable Altera Reference Design 
// License Agreement (either as signed by you or found at www.altera.com).  By
// using this reference design file, you indicate your acceptance of such terms
// and conditions between you and Altera Corporation.  In the event that you do
// not agree with such terms and conditions, you may not use the reference 
// design file and please promptly destroy any copies you have made.
//
// This reference design file is being provided on an "as-is" basis and as an 
// accommodation and therefore all warranties, representations or guarantees of 
// any kind (whether express, implied or statutory) including, without 
// limitation, warranties of merchantability, non-infringement, or fitness for
// a particular purpose, are specifically disclaimed.  By making this reference
// design file available, Altera expressly does not recommend, suggest or 
// require that this reference design file be used in combination with any 
// other product not provided by Altera.
/////////////////////////////////////////////////////////////////////////////


`timescale 1 ps / 1 ps

// baeckler - 04-16-2013

// DESCRIPTION
// 
// This is an alternate version of sync_regs with a multicycle 2 setup and cut hold rather than a false path.
// It is generally more constrained and safer than the false path. It will create more work for timing
// analysis and the place and route CAD.
// 



// CONFIDENCE
// This is a bread and butter synchronizer register with extensive hardware deployment
// 

module alt_sync_regs_m2 #(
	parameter WIDTH = 32,
	parameter DEPTH = 2		// minimum of 2
)(
	input clk,
	input [WIDTH-1:0] din,
	output [WIDTH-1:0] dout
);

reg [WIDTH-1:0] din_meta = 0 /* synthesis preserve dont_replicate */
/* synthesis ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \"set_multicycle_path -to [get_keepers *sync_regs_m*din_meta\[*\]] 2\" " */ ;

reg [WIDTH*(DEPTH-1)-1:0] sync_sr = 0 /* synthesis preserve dont_replicate */
/* synthesis ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \"set_false_path -hold -to [get_keepers *sync_regs_m*din_meta\[*\]]\" " */ ;

always @(posedge clk) begin
	din_meta <= din;
	sync_sr <= (sync_sr << WIDTH) | din_meta;
end
assign dout = sync_sr[WIDTH*(DEPTH-1)-1:WIDTH*(DEPTH-2)];

endmodule
