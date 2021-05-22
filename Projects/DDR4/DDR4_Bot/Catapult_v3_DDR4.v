
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
		output [8:0]	leds,
		
		// ---------- DDR4 Bottom Interface -----------
		input         emif_bot_oct_oct_rzqin,   // emif_0_oct.oct_rzqin
		output [0:0]  emif_bot_mem_mem_ck,      // emif_0_mem.mem_ck
		output [0:0]  emif_bot_mem_mem_ck_n,    //           .mem_ck_n
		output [16:0] emif_bot_mem_mem_a,       //           .mem_a
		output [0:0]  emif_bot_mem_mem_act_n,   //           .mem_act_n
		output [1:0]  emif_bot_mem_mem_ba,      //           .mem_ba
		output [0:0]  emif_bot_mem_mem_bg,      //           .mem_bg
		output [0:0]  emif_bot_mem_mem_cke,     //           .mem_cke
		output [0:0]  emif_bot_mem_mem_cs_n,    //           .mem_cs_n
		output [0:0]  emif_bot_mem_mem_odt,     //           .mem_odt
		output [0:0]  emif_bot_mem_mem_reset_n, //           .mem_reset_n
		output [0:0]  emif_bot_mem_mem_par,     //           .mem_par
		input  [0:0]  emif_bot_mem_mem_alert_n, //           .mem_alert_n
		inout  [8:0]  emif_bot_mem_mem_dqs,     //           .mem_dqs
		inout  [8:0]  emif_bot_mem_mem_dqs_n,   //           .mem_dqs_n
		inout  [71:0] emif_bot_mem_mem_dq,      //           .mem_dq
		inout  [8:0]  emif_bot_mem_mem_dbi_n    //           .mem_dbi_n
		
); 

reg [31:0] count; 
wire mem_clk;

always @ (posedge mem_clk)
begin
	count <= count + 1'b1;
end

assign leds[8:5] = count[28:25];

	Qsys u0 (
	// --------CLOCKS
		.clk_100_clk            (clk_u59),            	  //    clk_100.clk
		.clk_266_clk            (clk_y3),            	  //    clk_266.clk
		
	// --------DDR4
		.emif_bot_mem_mem_ck      (emif_bot_mem_mem_ck),      // 	  emif_bot_mem.mem_ck
		.emif_bot_mem_mem_ck_n    (emif_bot_mem_mem_ck_n),    //           .mem_ck_n
		.emif_bot_mem_mem_a       (emif_bot_mem_mem_a),       //           .mem_a
		.emif_bot_mem_mem_act_n   (emif_bot_mem_mem_act_n),   //           .mem_act_n
		.emif_bot_mem_mem_ba      (emif_bot_mem_mem_ba),      //           .mem_ba
		.emif_bot_mem_mem_bg      (emif_bot_mem_mem_bg),      //           .mem_bg
		.emif_bot_mem_mem_cke     (emif_bot_mem_mem_cke),     //           .mem_cke
		.emif_bot_mem_mem_cs_n    (emif_bot_mem_mem_cs_n),    //           .mem_cs_n
		.emif_bot_mem_mem_odt     (emif_bot_mem_mem_odt),     //           .mem_odt
		.emif_bot_mem_mem_reset_n (emif_bot_mem_mem_reset_n), //           .mem_reset_n
		.emif_bot_mem_mem_par     (emif_bot_mem_mem_par),     //           .mem_par
		.emif_bot_mem_mem_alert_n (emif_bot_mem_mem_alert_n), //           .mem_alert_n
		.emif_bot_mem_mem_dqs     (emif_bot_mem_mem_dqs),     //           .mem_dqs
		.emif_bot_mem_mem_dqs_n   (emif_bot_mem_mem_dqs_n),   //           .mem_dqs_n
		.emif_bot_mem_mem_dq      (emif_bot_mem_mem_dq),      //           .mem_dq
		.emif_bot_mem_mem_dbi_n   (emif_bot_mem_mem_dbi_n),   //           .mem_dbi_n
		.emif_bot_oct_oct_rzqin   (emif_bot_oct_oct_rzqin),   // 	  emif_bot_oct.oct_rzqin
		.emif_bot_status_local_cal_success (leds[0]), 				  //	  emif_bot_status.local_cal_success
		.emif_bot_status_local_cal_fail    (leds[1]),     			  //              .local_cal_fail
		.emif_bot_emif_usr_clk_clk(mem_clk),
		.emif_bot_pll_locked_conduit_end_pll_locked(leds[2])
	);



endmodule 