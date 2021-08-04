// ******************************************************************************
//                                                                              *
//                  Copyright (C) 2015 Altera Corporation                       *
//                                                                              *
// ALTERA, ARRIA, CYCLONE, HARDCOPY, MAX, MEGACORE, NIOS, QUARTUS & STRATIX     *
// are Reg. U.S. Pat. & Tm. Off. and Altera marks in and outside the U.S.       *
//                                                                              *
// All information provided herein is provided on an "as is" basis,             *
// without warranty of any kind.                                                *
//                                                                              *
// Module Name: hyper_pipe                   File Name: hyper_pipe.sv           *
//                                                                              *
// Module Function: This file implements a parameterizable bus of pipeline      *
//     registers for Altera training class                                      *
//                                                                              *
// REVISION HISTORY:                                                            *
//     1.0    00/00/0000 - Initial Revision  for QII 14.0                       * 
// ******************************************************************************

module hyper_pipe #(
	parameter DWIDTH = 1,
	parameter NUM_PIPES = 1)
(
input clk,
input [DWIDTH-1:0] din,
output [DWIDTH-1:0] dout);

reg [DWIDTH-1:0] hp [NUM_PIPES-1:0];

genvar i;
generate
	if (NUM_PIPES == 0) begin
		assign dout = din;
	end
	else begin
		always @ (posedge clk) 
			hp[0] <= din;
		for (i=1;i < NUM_PIPES;i++) begin : hregs
			always @ ( posedge clk) begin
					hp[i] <= hp[i-1];
			end
		end
		assign dout = hp[NUM_PIPES-1];
	end
		

endgenerate

endmodule


