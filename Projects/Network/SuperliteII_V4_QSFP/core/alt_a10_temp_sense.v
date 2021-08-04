// Copyright 2011 Altera Corporation. All rights reserved.  
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

// altera message_off 10230

`timescale 1 ps / 1 ps
// baeckler - 05-01-2014

// DESCRIPTION
// 
// This is a wrapper to simplify reading from the on die temperature sense diode and ADC. It continuously
// poles the temperature and reports in degrees Celsius and Fahrenheit. The temperature sense diode is
// only accurate within a few degrees Celsius, and may in some extreme cases be influenced by core
// switching activity. Please treat it as information only.
// 

// CONFIDENCE
// The temperature sense for A10 is not working yet.  Highly speculative.
// 

module alt_a10_temp_sense (
	input clk, 
	output reg [7:0] degrees_c,
	output reg [7:0] degrees_f	
);

// WYS connection to sense diode ADC
wire [9:0] tsd_out;

// make sure it actually routes, out of caution for flakey new port connections
wire trst = 1'b0 /* synthesis keep */;
wire corectl = 1'b1 /* synthesis keep */;

twentynm_tsdblock tsd
(
	.corectl(corectl),
	.reset(trst),
	.tempout(tsd_out),
	.eoc()	
);

wire [9:0] tsd_out_s;
alt_sync_regs_m2 sr0 (
	.clk(clk),
	.din(tsd_out),
	.dout(tsd_out_s)
);
defparam sr0 .WIDTH = 10;

// convert valid samples to better format

reg [12:0] p0 = 13'h0;
reg [10:0] p1 = 11'h0;
reg [14:0] scaled_tsd = 15'h0;
always @(posedge clk) begin
	
	// NPP says Temp = val * (706 / 1024) - 275
	// that fraction is 1/2 + 1/8 + 1/16 + 1/512
	p0 <= {1'b0,tsd_out_s,2'b0} + {3'b0,tsd_out_s};
	p1 <= {1'b0,tsd_out_s} + {6'b0,tsd_out_s[9:5]};	
	scaled_tsd <= {1'b0,p0,1'b0} + {4'b0,p1};				  
end		

reg [14:0] scaled_ofs_tsd = 15'h0;
always @(posedge clk) begin
	scaled_ofs_tsd <= scaled_tsd - {9'd275,4'b0};
end	

initial degrees_c = 0;
always @(posedge clk) begin
	degrees_c <= scaled_ofs_tsd[11:4];
end	
	
// F = C * 1.8 + 32
wire [9:0] fscaled;
alt_times_1pt8 at0 (
	.clk(clk),
	.din(scaled_ofs_tsd[11:2]),
	.dout(fscaled)
);	
defparam at0 .WIDTH = 10;
	
initial degrees_f = 0;
always @(posedge clk) begin
	degrees_f <= fscaled[9:2] + 8'd32;
end

endmodule