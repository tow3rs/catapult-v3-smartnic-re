/* DFE functions */

#include <stdio.h>
#include "system.h"
#include "string.h"
#include "altera_avalon_pio_regs.h"
#include <unistd.h>
#include "io.h"
#include "altera_avalon_jtag_uart_regs.h"

#include "parameters.h"
#include "PMA_functions.h"


void dfe_continous_enable(int channel, int number_of_taps, int freeze_mode)
{

   int temp;
   int control_bit;


// The following sets enable continous DFE with manual CTLE
//Enable Adaptation Slicers	0x123	1:1	1'b1
   rmw_channel(((channel << 10) + 0x123), 0x02, 0x02);

//Enable DFE Fix Tap 4 to 7	0x123	3:3

   switch (number_of_taps)
   {
   case CONTINUOUS_3TAPS  :
      rmw_channel(((channel << 10) + 0x123), 0x08, 0x00); break;
   case CONTINUOUS_7TAPS  :
      rmw_channel(((channel << 10) + 0x123), 0x08, 0x08); break;
   case CONTINUOUS_11TAPS :
      rmw_channel(((channel << 10) + 0x123), 0x08, 0x08); break;
   default:
      break;
   }

//Enable DFE Fix Tap 8 to 11	0x123	2:2

   switch (number_of_taps)
   {
   case CONTINUOUS_3TAPS  :
      rmw_channel(((channel << 10) + 0x123), 0x04, 0x00); break;
   case CONTINUOUS_7TAPS  :
      rmw_channel(((channel << 10) + 0x123), 0x04, 0x00); break;
   case CONTINUOUS_11TAPS :
      rmw_channel(((channel << 10) + 0x123), 0x04, 0x04); break;
   default:
      break;
   }

//Enable DFE Fix TAP 1 to 7 Adaptation	0x148	0:0	1'b1
   rmw_channel(((channel << 10) + 0x148), 0x00, 0x01);

//Enable DFE Fix TAP 8 to 11 Adaptation	0x148	1:1

   switch (number_of_taps)
   {
   case CONTINUOUS_3TAPS  :
      rmw_channel(((channel << 10) + 0x148), 0x02, 0x00); break;
   case CONTINUOUS_7TAPS  :
      rmw_channel(((channel << 10) + 0x148), 0x02, 0x00); break;
   case CONTINUOUS_11TAPS :
      rmw_channel(((channel << 10) + 0x148), 0x02, 0x02); break;
   default:
      break;
   }

//Enable VREF Adaptation	0x148	2:2	1'b1
   rmw_channel(((channel << 10) + 0x148), 0x04, 0x04);

//Enable VGA Adaptation	0x148	3:3	1'b1
   rmw_channel(((channel << 10) + 0x148), 0x08, 0x08);

//Enable CTLE Adaptation	0x148	4:4	1'b1
// 	0x14B	7:7	1'b0
// 	0x15B	4:4	1'b0
   rmw_channel(((channel << 10) + 0x148), 0x10, 0x10);
   rmw_channel(((channel << 10) + 0x14B), 0x80, 0x00);
   rmw_channel(((channel << 10) + 0x15B), 0x10, 0x00);

//Bypass DFE Fix TAP 1 to 7 Adaptation	0x15B	0:0	1'b0
   rmw_channel(((channel << 10) + 0x15B), 0x01, 0x00);

//Bypass DFE Fix TAP 8 to 11 Adaptation	0x15B	2:2

   switch (number_of_taps)
   {
   case CONTINUOUS_3TAPS  :
      rmw_channel(((channel << 10) + 0x15B), 0x04, 0x04); break;
   case CONTINUOUS_7TAPS  :
      rmw_channel(((channel << 10) + 0x15B), 0x04, 0x04); break;
   case CONTINUOUS_11TAPS :
      rmw_channel(((channel << 10) + 0x15B), 0x04, 0x00); break;
   default:
      break;
   }

//Bypass VREF Adaptation	0x15E	0:0	1'b0
   rmw_channel(((channel << 10) + 0x15E), 0x01, 0x00);

//Bypass VGA Adaptation	0x160	0:0	1'b1
   rmw_channel(((channel << 10) + 0x160), 0x01, 0x01);

//Bypass Single Stage CTLE	0x166	0:0	1'b1
   rmw_channel(((channel << 10) + 0x166), 0x01, 0x01);

//Bypass 4 Stage CTLE	0x167	0:0	1'b1
   rmw_channel(((channel << 10) + 0x167), 0x01, 0x01);

//CTLE Adaptation Timer Window	0x163	7:5	3'b000
   rmw_channel(((channel << 10) + 0x163), 0xE0, 0x00);

// New in 15.1.2
//DFE Adaptation Mode 	0x14D	2:0

   switch (number_of_taps)
   {
   case CONTINUOUS_3TAPS  :
      rmw_channel(((channel << 10) + 0x14D), 0x07, 0x04); break;
   case CONTINUOUS_7TAPS  :
      rmw_channel(((channel << 10) + 0x14D), 0x07, 0x00); break;
   case CONTINUOUS_11TAPS :
      rmw_channel(((channel << 10) + 0x14D), 0x07, 0x00); break;
   default:
      break;
   }

//Enable DFT	0x124	5:5	1'b0
   rmw_channel(((channel << 10) + 0x124), 0x20, 0x00);


//Adaptation Control Select= 1   (0x149 [4:4] = 1’b1)
   rmw_channel(((channel << 10) + 0x149), 0x10, 0x10);

   if (freeze_mode == 0)
   {

      //Adaptation Reset 0 => 1    (0x149 [6:6] = 1’b0 -> 1’b1)
      rmw_channel(((channel << 10) + 0x149), 0x40, 0x00);
      rmw_channel(((channel << 10) + 0x149), 0x40, 0x40);

      //Adaptation Start 0 => 1    (0x149 [5:5] = 1’b0 -> 1’b1)
      rmw_channel(((channel << 10) + 0x149), 0x20, 0x00);
      rmw_channel(((channel << 10) + 0x149), 0x20, 0x20);
   }
   else // This one uses the Nios to check automatically (available from 15.1.1.)
   {


      //Enable Adaptation Triggering Request = 1    (0x100 [6:6] = 1'b1)
      rmw_channel(((channel << 10) + 0x100), 0x40, 0x40);

      //Pass AVMM access to uC=1   (0x000 [0:0] = 1’b1)
      rmw_channel(((channel << 10) + 0x000), 0x01, 0x01);

// New step poll 0x100[6] to go LOW which confirms NIOS has completed the routine and gives the AVMM back to user


   }

   do
   {
      temp = rd_channel((channel << 10) + 0x100);
      control_bit = 0x0001 & (temp >> 6); //Bit 6
   }
   while (control_bit != 0);
}


void dfe_disable(int channel)
{


//Powerdown DFE 0x123 0:0	1'b0
//	rmw_channel( ((channel<<10) + 0x123),0x01,0x00);

// The following sets enable continous DFE with manual CTLE
//Enable Adaptation Slicers	0x123	1:1	1'b0
   rmw_channel(((channel << 10) + 0x123), 0x02, 0x00);

//Enable DFE Fix Tap 4 to 7	0x123	3:3   1'b0
   rmw_channel(((channel << 10) + 0x123), 0x08, 0x00);

//Enable DFE Fix Tap 8 to 11	0x123	2:2 1'b0

   rmw_channel(((channel << 10) + 0x123), 0x04, 0x00);

//Enable DFE Fix TAP 1 to 7 Adaptation	0x148	0:0	1'b0
   rmw_channel(((channel << 10) + 0x148), 0x00, 0x00);

//Enable DFE Fix TAP 8 to 11 Adaptation	0x148	1:1 1'b0

   rmw_channel(((channel << 10) + 0x148), 0x02, 0x00);

//Enable VREF Adaptation	0x148	2:2	1'b0
   rmw_channel(((channel << 10) + 0x148), 0x04, 0x00);

//Enable VGA Adaptation	0x148	3:3	1'b1
   rmw_channel(((channel << 10) + 0x148), 0x08, 0x00);

//Enable CTLE Adaptation	0x148	4:4	1'b0
// 	0x14B	7:7	1'b0
// 	0x15B	4:4	1'b0
   rmw_channel(((channel << 10) + 0x148), 0x10, 0x00);
   rmw_channel(((channel << 10) + 0x14B), 0x80, 0x00);
   rmw_channel(((channel << 10) + 0x15B), 0x10, 0x00);

//Bypass DFE Fix TAP 1 to 7 Adaptation	0x15B	0:0	1'b1
   rmw_channel(((channel << 10) + 0x15B), 0x01, 0x01);

//Bypass DFE Fix TAP 8 to 11 Adaptation	0x15B	2:2 1'b1

   rmw_channel(((channel << 10) + 0x15B), 0x04, 0x04);

//Bypass VREF Adaptation	0x15E	0:0	1'b1
   rmw_channel(((channel << 10) + 0x15E), 0x01, 0x01);

//Bypass VGA Adaptation	0x160	0:0	1'b1
   rmw_channel(((channel << 10) + 0x160), 0x01, 0x01);

//Bypass Single Stage CTLE	0x166	0:0	1'b1
   rmw_channel(((channel << 10) + 0x166), 0x01, 0x01);

//Bypass 4 Stage CTLE	0x167	0:0	1'b1
   rmw_channel(((channel << 10) + 0x167), 0x01, 0x01);

//CTLE Adaptation Timer Window	0x163	7:5	3'b111
   rmw_channel(((channel << 10) + 0x163), 0xE0, 0xE0);

// New in 15.1.2
//DFE Adaptation Mode 	0x14D	2:0	3'b111

   rmw_channel(((channel << 10) + 0x14D), 0x07, 0x07);

//Enable DFT	0x124	5:5	1'b1
   rmw_channel(((channel << 10) + 0x124), 0x20, 0x20);


////Adaptation Control Select= 1   (0x149 [4:4] = 1’b1)
//	rmw_channel( ((channel<<10) + 0x149),0x10,0x10);
//
////Enable Adaptation Triggering Request = 1    (0x100 [6:6] = 1'b1)
//	rmw_channel( ((channel<<10) + 0x100),0x40,0x40);
//
////Pass AVMM access to uC=1   (0x000 [0:0] = 1’b1)
//	rmw_channel( ((channel<<10) + 0x000),0x01,0x01);

}
