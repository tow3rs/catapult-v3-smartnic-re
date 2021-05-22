
module GoldenTop ( 

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

		// ---------- DDR4 Top Interface -----------
		input         emif_top_oct_oct_rzqin,   
		output [0:0]  emif_top_mem_mem_ck,      
		output [0:0]  emif_top_mem_mem_ck_n,    
		output [16:0] emif_top_mem_mem_a,       
		output [0:0]  emif_top_mem_mem_act_n,   
		output [1:0]  emif_top_mem_mem_ba,      
		output [0:0]  emif_top_mem_mem_bg,      
		output [0:0]  emif_top_mem_mem_cke,     
		output [0:0]  emif_top_mem_mem_cs_n,    
		output [0:0]  emif_top_mem_mem_odt,     
		output [0:0]  emif_top_mem_mem_reset_n, 
		output [0:0]  emif_top_mem_mem_par,     
		input  [0:0]  emif_top_mem_mem_alert_n, 
		inout  [8:0]  emif_top_mem_mem_dqs,     
		inout  [8:0]  emif_top_mem_mem_dqs_n,   
		inout  [71:0] emif_top_mem_mem_dq,      
		inout  [8:0]  emif_top_mem_mem_dbi_n,   
		
		// ---------- DDR4 Bottom Interface -----------
		input         emif_bot_oct_oct_rzqin,  
		output [0:0]  emif_bot_mem_mem_ck,     
		output [0:0]  emif_bot_mem_mem_ck_n,   
		output [16:0] emif_bot_mem_mem_a,      
		output [0:0]  emif_bot_mem_mem_act_n,  
		output [1:0]  emif_bot_mem_mem_ba,     
		output [0:0]  emif_bot_mem_mem_bg,     
		output [0:0]  emif_bot_mem_mem_cke,    
		output [0:0]  emif_bot_mem_mem_cs_n,   
		output [0:0]  emif_bot_mem_mem_odt,    
		output [0:0]  emif_bot_mem_mem_reset_n,
		output [0:0]  emif_bot_mem_mem_par,    
		input  [0:0]  emif_bot_mem_mem_alert_n,
		inout  [8:0]  emif_bot_mem_mem_dqs,    
		inout  [8:0]  emif_bot_mem_mem_dqs_n,  
		inout  [71:0] emif_bot_mem_mem_dq,     
		inout  [8:0]  emif_bot_mem_mem_dbi_n,  
		
		// PCIe2
		input           pcie2_perstn,
		input  [ 7:0]   pcie2_rx,
		output [ 7:0]   pcie2_tx,	 
		input				 pcie2_cpsrnt,	
		
		// PCIe1
		input           pcie1_perstn,
		input  [ 7:0]   pcie1_rx,
		output [ 7:0]   pcie1_tx,  
		
		// QSFP
		input  [3:0]    qsfp_rx,
		output [3:0]    qsfp_tx,
		input				 modprsl,		
		
		// Mellanox XVCR
		input  [3:0]    mell_rx,
		output [3:0]    mell_tx,
		
		// I2C Channel 1
		inout 		  sda_ch1,
		inout 		  scl_ch1,
		
		// I2C Channel 2
		inout 		  sda_ch2,
		inout 		  scl_ch2,
		
		// J11 Header pins		
		input  [2:0]	io_j11,
		
		// U22 
		output [2:0]	dir_u22,
		inout  [3:0]	io_u22,
		output			oe_u22
		
); 

	reg [31:0] alive_count; 
	
	wire i2c_ch1_scl_oe;
	wire i2c_ch1_sda_oe;
	wire i2c_ch2_scl_oe;
	wire i2c_ch2_sda_oe;
	
	assign leds[8] = alive_count[25];
	assign leds[7] = ~modprsl;	
	
	always @ (posedge clk_u59)
	begin
		alive_count <= alive_count + 1'b1;
	end


	//I2C
	assign scl_ch1 = i2c_ch1_scl_oe ? 1'b0 : 1'bz;
	assign sda_ch1 = i2c_ch1_sda_oe ? 1'b0 : 1'bz;

	assign scl_ch2 = i2c_ch2_scl_oe ? 1'b0 : 1'bz;
	assign sda_ch2 = i2c_ch2_sda_oe ? 1'b0 : 1'bz;

	Qsys u0 (
		// --------CLOCKS
		.clk_100_clk            (clk_u59),							//      clk_100.clk
		
		// --------DDR4 Top
		.emif_top_pll_ref_clk_clk (clk_y4),                   //      emif_top_pll_ref_clk.clk
		.emif_top_mem_mem_ck      (emif_top_mem_mem_ck),      // 	  emif_top_mem.mem_ck
		.emif_top_mem_mem_ck_n    (emif_top_mem_mem_ck_n),    //           .mem_ck_n
		.emif_top_mem_mem_a       (emif_top_mem_mem_a),       //           .mem_a
		.emif_top_mem_mem_act_n   (emif_top_mem_mem_act_n),   //           .mem_act_n
		.emif_top_mem_mem_ba      (emif_top_mem_mem_ba),      //           .mem_ba
		.emif_top_mem_mem_bg      (emif_top_mem_mem_bg),      //           .mem_bg
		.emif_top_mem_mem_cke     (emif_top_mem_mem_cke),     //           .mem_cke
		.emif_top_mem_mem_cs_n    (emif_top_mem_mem_cs_n),    //           .mem_cs_n
		.emif_top_mem_mem_odt     (emif_top_mem_mem_odt),     //           .mem_odt
		.emif_top_mem_mem_reset_n (emif_top_mem_mem_reset_n), //           .mem_reset_n
		.emif_top_mem_mem_par     (emif_top_mem_mem_par),     //           .mem_par
		.emif_top_mem_mem_alert_n (emif_top_mem_mem_alert_n), //           .mem_alert_n
		.emif_top_mem_mem_dqs     (emif_top_mem_mem_dqs),     //           .mem_dqs
		.emif_top_mem_mem_dqs_n   (emif_top_mem_mem_dqs_n),   //           .mem_dqs_n
		.emif_top_mem_mem_dq      (emif_top_mem_mem_dq),      //           .mem_dq
		.emif_top_mem_mem_dbi_n   (emif_top_mem_mem_dbi_n),   //           .mem_dbi_n
		.emif_top_oct_oct_rzqin   (emif_top_oct_oct_rzqin),   // 	  emif_top_oct.oct_rzqin
		.emif_top_status_local_cal_success (leds[0]),			//	  	  emif_top_status.local_cal_success
		.emif_top_status_local_cal_fail    (leds[1]),			//           .local_cal_fail
		
		// --------DDR4 Bottom
		.emif_bot_pll_ref_clk_clk (clk_y3),                   //      emif_bot_pll_ref_clk.clk
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
		.emif_bot_status_local_cal_success (leds[3]),			//	     emif_bot_status.local_cal_success
		.emif_bot_status_local_cal_fail    (leds[4]),			//           .local_cal_fail
		
		// I2C Channel#1
		.i2c_ch1_sda_in 	(sda_ch1),
		.i2c_ch1_scl_in 	(scl_ch1),
		.i2c_ch1_sda_oe 	(i2c_ch1_sda_oe),
		.i2c_ch1_scl_oe 	(i2c_ch1_scl_oe),
		
		// I2C Channel#2
		.i2c_ch2_sda_in 	(sda_ch2),
		.i2c_ch2_scl_in 	(scl_ch2),
		.i2c_ch2_sda_oe 	(i2c_ch2_sda_oe),
		.i2c_ch2_scl_oe 	(i2c_ch2_scl_oe),

		// PCIe #1
		.pcie_a10_hip_1_refclk_clk         (clk_pcie1),	  //         pcie_a10_hip_1_refclk.clk
		.pcie_a10_hip_1_npor_npor          (1'b1),				  //         pcie_a10_hip_1_npor.npor
		.pcie_a10_hip_1_npor_pin_perst     (pcie1_perstn), //                              .pin_perst
		.pcie_a10_hip_1_hip_serial_rx_in0  (pcie1_rx[0]),  //     pcie_a10_hip_1_hip_serial.rx_in0
		.pcie_a10_hip_1_hip_serial_rx_in1  (pcie1_rx[1]),  //                              .rx_in1
		.pcie_a10_hip_1_hip_serial_rx_in2  (pcie1_rx[2]),  //                              .rx_in2
		.pcie_a10_hip_1_hip_serial_rx_in3  (pcie1_rx[3]),  //                              .rx_in3
		.pcie_a10_hip_1_hip_serial_rx_in4  (pcie1_rx[4]),  //                              .rx_in4
		.pcie_a10_hip_1_hip_serial_rx_in5  (pcie1_rx[5]),  //                              .rx_in5
		.pcie_a10_hip_1_hip_serial_rx_in6  (pcie1_rx[6]),  //                              .rx_in6
		.pcie_a10_hip_1_hip_serial_rx_in7  (pcie1_rx[7]),  //                              .rx_in7
		.pcie_a10_hip_1_hip_serial_tx_out0 (pcie1_tx[0]),  //                              .tx_out0
		.pcie_a10_hip_1_hip_serial_tx_out1 (pcie1_tx[1]),  //                              .tx_out1
		.pcie_a10_hip_1_hip_serial_tx_out2 (pcie1_tx[2]),  //                              .tx_out2
		.pcie_a10_hip_1_hip_serial_tx_out3 (pcie1_tx[3]),  //                              .tx_out3
		.pcie_a10_hip_1_hip_serial_tx_out4 (pcie1_tx[4]),  //                              .tx_out4
		.pcie_a10_hip_1_hip_serial_tx_out5 (pcie1_tx[5]),  //                              .tx_out5
		.pcie_a10_hip_1_hip_serial_tx_out6 (pcie1_tx[6]),  //                              .tx_out6
		.pcie_a10_hip_1_hip_serial_tx_out7 (pcie1_tx[7]),  //                              .tx_out7
		
		 // PCIe #2
		.pcie_a10_hip_2_refclk_clk         (clk_pcie2), 	 //         pcie_a10_hip_2_refclk.clk
		.pcie_a10_hip_2_npor_npor          (1'b1),             //         pcie_a10_hip_2_npor.npor
		.pcie_a10_hip_2_npor_pin_perst     (pcie2_perstn), //                              .pin_perst
		.pcie_a10_hip_2_hip_serial_rx_in0  (pcie2_rx[0]),  //     pcie_a10_hip_2_hip_serial.rx_in0
		.pcie_a10_hip_2_hip_serial_rx_in1  (pcie2_rx[1]),  //                              .rx_in1
		.pcie_a10_hip_2_hip_serial_rx_in2  (pcie2_rx[2]),  //                              .rx_in2
		.pcie_a10_hip_2_hip_serial_rx_in3  (pcie2_rx[3]),  //                              .rx_in3
		.pcie_a10_hip_2_hip_serial_rx_in4  (pcie2_rx[4]),  //                              .rx_in4
		.pcie_a10_hip_2_hip_serial_rx_in5  (pcie2_rx[5]),  //                              .rx_in5
		.pcie_a10_hip_2_hip_serial_rx_in6  (pcie2_rx[6]),  //                              .rx_in6
		.pcie_a10_hip_2_hip_serial_rx_in7  (pcie2_rx[7]),  //                              .rx_in7
		.pcie_a10_hip_2_hip_serial_tx_out0 (pcie2_tx[0]),  //                              .tx_out0
		.pcie_a10_hip_2_hip_serial_tx_out1 (pcie2_tx[1]),  //                              .tx_out1
		.pcie_a10_hip_2_hip_serial_tx_out2 (pcie2_tx[2]),  //                              .tx_out2
		.pcie_a10_hip_2_hip_serial_tx_out3 (pcie2_tx[3]),  //                              .tx_out3
		.pcie_a10_hip_2_hip_serial_tx_out4 (pcie2_tx[4]),  //                              .tx_out4
		.pcie_a10_hip_2_hip_serial_tx_out5 (pcie2_tx[5]),  //                              .tx_out5
		.pcie_a10_hip_2_hip_serial_tx_out6 (pcie2_tx[6]),  //                              .tx_out6
		.pcie_a10_hip_2_hip_serial_tx_out7 (pcie2_tx[7]),   //                             .tx_out7
		
		.pio_j11_export(io_j11)
	);


endmodule 