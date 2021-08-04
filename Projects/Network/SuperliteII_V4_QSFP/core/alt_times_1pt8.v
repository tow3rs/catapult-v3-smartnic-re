// Copyright 2014 Altera Corporation. All rights reserved.  
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

`timescale 1ps/1ps

// baeckler - 05-02-2014
// DESCRIPTION
// Multiply by 461 / 256 

module alt_times_1pt8 #(
	parameter WIDTH = 8
)(
	input clk,
	input [WIDTH-1:0] din,
	output [WIDTH-1:0] dout
);

reg [WIDTH+8-1:0] scratch = {(WIDTH+8){1'b0}};

reg [WIDTH+1-1:0] p0 = {(WIDTH+1){1'b0}};
reg [WIDTH+3-1:0] p1 = {(WIDTH+3){1'b0}};
reg [WIDTH+2-1:0] p2 = {(WIDTH+2){1'b0}};

always @(posedge clk) begin
	p0 <= {din,1'b0} + din; // 256,128
	p1 <= {din,3'b0} + din; // 64 8
	p2 <= {din,2'b0} + din; // 4 1
	scratch <= {p0,7'b0} + {p1,3'b0} + p2;
end

assign dout = scratch[WIDTH+8-1:8];

endmodule
