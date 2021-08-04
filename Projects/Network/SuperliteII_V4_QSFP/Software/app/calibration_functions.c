/* Calibration functions */

#include <stdio.h>
#include "system.h"
#include "string.h"
#include "altera_avalon_pio_regs.h"
#include <unistd.h>
#include "io.h"
#include "altera_avalon_jtag_uart_regs.h"

#include "parameters.h"
#include "PMA_functions.h"

#define DEBUG_CALIBRATION 0


// Recalibrate Channel
void recalibrate_channel(int channel, int rate_switch)
{
   int temp;
   int control_bit;
   int cal_busy_bits;

   // a. Do direct write of 0x02 to address  0x000 to request access to internal configuration bus (do not use RMW).
   wr_channel(((channel << 10) + 0x000), 0x02);

   // b. Read bit[2] of 0x281 to check it is zero (user has control)
   do
   {
      temp = rd_channel((channel << 10) + 0x281);
      control_bit = 0x0001 & (temp >> 2); //Bit 2
   }
   while (control_bit != 0);

   // c. Do RMW 0x22 with mask 0x62 to address 0x100 to set the Tx and Rx calibration bit (note: bit[6] needs to be masked as well).
   rmw_channel(((channel << 10) + 0x100), 0x62, 0x22);

   // d. Set the rate switch flag register for PMA Rx calibration (*)
   //		 If no CDR rate switch is done do RMW 0x80 with mask 0x80 to address 0x166.
   // 	 If CDR rate switch  is done do RMW 0x00 with mask 0x80 to address 0x166
   if (rate_switch == 0)
   {
	   rmw_channel(((channel << 10) + 0x166), 0x80, 0x80);
   }
   else
   {
	   rmw_channel(((channel << 10) + 0x166), 0x80, 0x00);
   }
   
   // e. Do RMW 0x01 with mask 0xFF to address 0x000 to let the PreSice doing the calibration
   rmw_channel(((channel << 10) + 0x000), 0xFF, 0x01);

   // f. Read bits [1] and [0]  of 0x281 to become 0
   do
   {
      temp = rd_channel((channel << 10) + 0x281);
      cal_busy_bits = 0x0003 & (temp); //Bit 0 is tx_cal_busy, bit 1 is rx_cal_busy
   }
   while (cal_busy_bits != 0);

   // g. When bits[1] and [0] of 0x281 are  0 channel calibration has been completed
   if (DEBUG_CALIBRATION == 1)
   {
	   printf("\nChannel %d recalibrated", channel);
   }
}


// Recalibrate receiver
void recalibrate_rx(int channel, int rate_switch)
{
   int temp;
   int control_bit;
   int cal_busy_bit;

   // a. Do direct write of 0x02 to address  0x000 to request access to internal configuration bus (do not use RMW).
   wr_channel(((channel << 10) + 0x000), 0x02);

   // b. Read bit[2] of 0x281 to check it is zero (user has control)
   do
   {
      temp = rd_channel((channel << 10) + 0x281);
      control_bit = 0x0001 & (temp >> 2); //Bit 2
   }
   while (control_bit != 0);

   // c. Do RMW 0x00 with mask 0x10 to address 0x281 to set bit 4 to zero to mask out tx_cal_busy.
   rmw_channel(((channel << 10) + 0x281), 0x10, 0x00);

   // d. Do RMW 0x02 with mask 0x42 to address 0x100 to set the Rx calibration bit. (note: bit[6] needs to be masked as well).).
   rmw_channel(((channel << 10) + 0x100), 0x42, 0x02);

   // e. Set the rate switch flag register for PMA Rx calibration (*)
   //		 If no CDR rate switch is done do RMW 0x80 with mask 0x80 to address 0x166.
   // 	 If CDR rate switch  is done do RMW 0x00 with mask 0x80 to address 0x166
   if (rate_switch == 0)
   {
	   rmw_channel(((channel << 10) + 0x166), 0x80, 0x80);
   }
   else
   {
	   rmw_channel(((channel << 10) + 0x166), 0x80, 0x00);
   }

   // f. Do RMW 0x01 with mask 0xFF to address 0x000 to let the PreSice doing the calibration
   rmw_channel(((channel << 10) + 0x000), 0xFF, 0x01);

   // g. Read bit [1] of 0x281 to become 0
   do
   {
      temp = rd_channel((channel << 10) + 0x281);
      cal_busy_bit = 0x0001 & (temp >> 1); //bit 1 is rx_cal_busy
   }
   while (cal_busy_bit != 0);

   // h. When bit[1]  of 0x281 is 0 receiver channel calibration has been completed
   if (DEBUG_CALIBRATION == 1)
   {
	   printf("\nReceiver channel %d recalibrated", channel);
   }
   
   // i. Do RMW 0x10 with mask 0x10 to address 0x281 to set bit 4 to one again to enable again the tx_cal_busy.
   rmw_channel(((channel << 10) + 0x281), 0x10, 0x10);
}


// Recalibrate transmitter
void recalibrate_tx(int channel)
{
   int temp;
   int control_bit;
   int cal_busy_bit;

   // a. Do direct write of 0x02 to address  0x000 to request access to internal configuration bus (do not use RMW).
   wr_channel(((channel << 10) + 0x000), 0x02);

   // b. Read bit[2] of 0x281 to check it is zero (user has control)
   do
   {
      temp = rd_channel((channel << 10) + 0x281);
      control_bit = 0x0001 & (temp >> 2); //Bit 2
   }
   while (control_bit != 0);

   // c. Do RMW 0x00 with mask 0x20 to address 0x281 to set bit 5 to zero to mask out rx_cal_busy.
   rmw_channel(((channel << 10) + 0x281), 0x20, 0x00);

   // d. Do RMW 0x20 with mask 0x60 to address 0x100 to set the Tx calibration bit (note: bit[6] needs to be masked as well).).
   rmw_channel(((channel << 10) + 0x100), 0x60, 0x20);

   // e. Do RMW 0x01 with mask 0xFF to address 0x000 to let the PreSice doing the calibration
   rmw_channel(((channel << 10) + 0x000), 0xFF, 0x01);

   // f. Read bit [0] of 0x281 to become 0
   do
   {
      temp = rd_channel((channel << 10) + 0x281);
      cal_busy_bit = 0x0001 & (temp); //bit 0 is tx_cal_busy
   }
   while (cal_busy_bit != 0);

   // g. When bit[0]  of 0x281 is 0 transmitter channel calibration has been completed
   if (DEBUG_CALIBRATION == 1)
   {
	   printf("\nTransmitter channel %d recalibrated", channel);
   }

   // h. Do RMW 0x20 with mask 0x20 to address 0x281 to set bit 5 to one again to enable again the rx_cal_busy.
   rmw_channel(((channel << 10) + 0x281), 0x20, 0x20);

}


// Recalibrate transmitter
void recalibrate_pll(int pll_type)
{
   int temp;
   int control_bit;
   int cal_busy_bit;

   // a. Do direct write of 0x02 to address  0x000 to request access to internal configuration bus (do not use RMW).
   wr_pll(0x000, 0x02);

   // b. Read bit[2] of 0x280 to check it is zero (user has control)
   do
   {
      temp = rd_pll(0x280);
      control_bit = 0x0001 & (temp >> 2); //Bit 2
   }
   while (control_bit != 0);

   // c. Do RMW 0x01 with mask 0x01 to address 0x100 to enable ATX PLL calibration
   // or
   // c. Do RMW 0x02 with mask 0x02 to address 0x100 to enable fPLL calibration
   if (pll_type == ATX_PLL)
   {
	   rmw_pll(0x100, 0x01, 0x01);
   }
   else
   {
	   rmw_pll(0x100, 0x02, 0x02);
   }

   // d. Do write 0x01 to address 0x000 to let the PreSice doing the calibration (No RMW)
   wr_pll(0x000, 0x01);

   // e. Read bit[1] of 0x280 to become 0
   do
   {
      temp = rd_pll(0x280);
      cal_busy_bit = 0x0001 & (temp >> 1);
   }
   while (cal_busy_bit != 0);

   // g. When bit[1]  of 0x280 is 0 transmitter channel calibration has been completed
   if (DEBUG_CALIBRATION == 1)
   {
      if (pll_type == ATX_PLL)
	  {
		  printf("\nATX PLL recalibrated");
	  }	  
      else
	  {
		  printf("\nfPLL recalibrated");
	  }
   }
}
