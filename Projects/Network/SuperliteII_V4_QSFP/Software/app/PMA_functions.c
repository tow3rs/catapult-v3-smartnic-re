/* PMA functions */

#include <stdio.h>
#include "system.h"
#include "string.h"
#include "altera_avalon_pio_regs.h"
#include <unistd.h>
#include "io.h"
#include "altera_avalon_jtag_uart_regs.h"

#include "parameters.h"


void rmw_channel(int offset, int bitmask, int newval)
{

   int value;

   //Read data from data register at offset

   value = IORD(RECONFIG_MGMT_0_BASE, offset);

   // bitwise-AND and clear out bitmask bits

   value = value & (0xff & (~bitmask));

   value = 0x000000ff & value; // keep only lower 8 bits.

   value = value | newval;

   IOWR(RECONFIG_MGMT_0_BASE, offset, value);
}

int rd_channel(int offset)
{
   int value;
   value = IORD(RECONFIG_MGMT_0_BASE, offset);
   return (value);
}

void wr_channel(int offset, int value)
{
   IOWR(RECONFIG_MGMT_0_BASE, offset, value);
}


void rmw_pll(int offset, int bitmask, int newval)
{

   int value;

   //Read data from data register at offset

   value = IORD(RECONFIG_MGMT_PLL_BASE, offset);

   // bitwise-AND and clear out bitmask bits

   value = value & (0xff & (~bitmask));

   value = 0x000000ff & value; // keep only lower 8 bits.

   value = value | newval;

   IOWR(RECONFIG_MGMT_PLL_BASE, offset, value);
}

int rd_pll(int offset)
{
   int value;
   value = IORD(RECONFIG_MGMT_PLL_BASE, offset);
   return (value);
}

void wr_pll(int offset, int value)
{
   IOWR(RECONFIG_MGMT_PLL_BASE, offset, value);
}


// PRE TAP 2
int encode_pretap2(int pretap2)
{
   int encoded_pretap2;

   if (pretap2 < 0) encoded_pretap2 = 16 - pretap2; // 0x10 ,use negative as pretap2 is negative in thix case
   else encoded_pretap2 = pretap2;
   return (encoded_pretap2);
}

int decode_pretap2(int pretap2_encoded)
{
   int decoded_pretap2;

   if (pretap2_encoded > 0x10) decoded_pretap2 = -(pretap2_encoded - 0x10);
   else decoded_pretap2 = pretap2_encoded;
   return (decoded_pretap2);
}

// PRE TAP 1
int encode_pretap1(int pretap1)
{
   int encoded_pretap1;

   if (pretap1 < 0) encoded_pretap1 = 32 - pretap1; // 0x20 ,use negative as pretap1 is negative in thix case
   else encoded_pretap1 = pretap1;
   return (encoded_pretap1);
}

int decode_pretap1(int pretap1_encoded)
{
   int decoded_pretap1;

   if (pretap1_encoded > 0x20) decoded_pretap1 = -(pretap1_encoded - 0x20);
   else decoded_pretap1 = pretap1_encoded;
   return (decoded_pretap1);
}


// POST TAP 1
int encode_posttap1(int posttap1)
{
   int encoded_posttap1;

   if (posttap1 < 0) encoded_posttap1 = 64 - posttap1; // 0x40 ,use negative as posttap1 is negative in thix case
   else encoded_posttap1 = posttap1;
   return (encoded_posttap1);
}

int decode_posttap1(int posttap1_encoded)
{
   int decoded_posttap1;

   if (posttap1_encoded > 0x40) decoded_posttap1 = -(posttap1_encoded - 0x40);
   else decoded_posttap1 = posttap1_encoded;
   return (decoded_posttap1);
}

// POST TAP 2
int encode_posttap2(int posttap2)
{
   int encoded_posttap2;

   if (posttap2 < 0) encoded_posttap2 = 32 - posttap2; // 0x20 ,use negative as posttap2 is negative in thix case
   else encoded_posttap2 = posttap2;
   return (encoded_posttap2);
}

int decode_posttap2(int posttap2_encoded)
{
   int decoded_posttap2;

   if (posttap2_encoded > 0x20) decoded_posttap2 = -(posttap2_encoded - 0x20);
   else decoded_posttap2 = posttap2_encoded;
   return (decoded_posttap2);
}


// DC Gain
int encode_dcgain(int dcgain)
{
   int encoded_dcgain;
   switch (dcgain)
   {
   case 0 :
      encoded_dcgain = EQ_GAIN_0; break;
   case 1 :
      encoded_dcgain = EQ_GAIN_1; break;
   case 2 :
      encoded_dcgain = EQ_GAIN_2; break;
   case 3 :
      encoded_dcgain = EQ_GAIN_3; break;
   case 4 :
      encoded_dcgain = EQ_GAIN_4; break;
   default :
      encoded_dcgain = EQ_GAIN_0; break;
   }
   return (encoded_dcgain);
}

int decode_dcgain(int dcgain_encoded)
{
   int decoded_dcgain;

   switch (dcgain_encoded)
   {
   case EQ_GAIN_0 :
      decoded_dcgain = 0; break;
   case EQ_GAIN_1 :
      decoded_dcgain = 1; break;
   case EQ_GAIN_2 :
      decoded_dcgain = 2; break;
   case EQ_GAIN_3 :
      decoded_dcgain = 3; break;
   case EQ_GAIN_4 :
      decoded_dcgain = 4; break;
   default :
      decoded_dcgain = 0; break;
   }
   return (decoded_dcgain);
}

void show_pma_settings(int dfe_enable[NUMBER_OF_LANES])
{
   int tx_vodctrl[NUMBER_OF_LANES];
   int tx_pretap_1[NUMBER_OF_LANES];
   int tx_pretap_2[NUMBER_OF_LANES];
   int tx_posttap_1[NUMBER_OF_LANES];
   int tx_posttap_2[NUMBER_OF_LANES];
   int rx_eqdcgain[NUMBER_OF_LANES];
   int rx_eqctrl[NUMBER_OF_LANES];
   int vga_gain[NUMBER_OF_LANES];
   int fix[NUMBER_OF_LANES];
   int dyn[NUMBER_OF_LANES];
   int ipd[NUMBER_OF_LANES];
   int tap1[NUMBER_OF_LANES];
   int tap2[NUMBER_OF_LANES];
   int tap3[NUMBER_OF_LANES];
   int tap4[NUMBER_OF_LANES];
   int tap5[NUMBER_OF_LANES];
   int tap6[NUMBER_OF_LANES];
   int tap7[NUMBER_OF_LANES];
   int tap8[NUMBER_OF_LANES];
   int tap9[NUMBER_OF_LANES];
   int tap10[NUMBER_OF_LANES];
   int tap11[NUMBER_OF_LANES];
   int i;
   int temp;

   for (i = 0; i < NUMBER_OF_LANES; i++)
   {
      tx_vodctrl[i] = rd_channel((i << 10) + 0x109) & 0x1F;
      tx_pretap_2[i] = rd_channel((i << 10) + 0x108) & 0x17;
      tx_pretap_1[i] = rd_channel((i << 10) + 0x107) & 0x3F;
      tx_posttap_1[i] = rd_channel((i << 10) + 0x105) & 0x7F;
      tx_posttap_2[i] = rd_channel((i << 10) + 0x106) & 0x2F;
      rx_eqctrl[i] = (rd_channel((i << 10) + 0x167) & 0x3E) >> 1;
      rx_eqdcgain[i] = ((rd_channel((i << 10) + 0x11C) & 0x0F) << 8) + (rd_channel((i << 10) + 0x11A) & 0xFF);
      vga_gain[i] = (rd_channel((i << 10) + 0x160) & 0xE) >> 1;
      if (ADVANCED == 1)
      {
         //set_cdr_vco_speed bit 0x137 [6:2]
         dyn[i] = (rd_channel((i << 10) + 0x137) & 0x7C) >> 2;
         //set_cdr_vco_speed_fix[4] 0x134 bit 6 and set_cdr_vco_speed_fix[3:0] 0x136 bit [3:0]
         fix[i] = ((rd_channel((i << 10) + 0x134) & 0x40) >> 2) + (rd_channel((i << 10) + 0x136) & 0x0F);
         // IPD set_cp_current_pd_setting  0x139 [5:3]
         ipd[i] = (rd_channel((i << 10) + 0x139) & 0x38) >> 3;
      }


      //read out DFEtaps
      rmw_channel((i << 10) + 0x171, 0x1E, 0x14);
      usleep(10);

      //tap 1
      rmw_channel((i << 10) + 0x130, 0x0F, 0x01);
      usleep(10);
      tap1[i] = (rd_channel((i << 10) + 0x176) & 0x7F);

      //tap 2
      rmw_channel((i << 10) + 0x130, 0x0F, 0x02);
      usleep(10);
      tap2[i] = (rd_channel((i << 10) + 0x176));

      //tap 3
      rmw_channel((i << 10) + 0x130, 0x0F, 0x03);
      usleep(10);
      tap3[i] = (rd_channel((i << 10) + 0x176));

      //tap 4
      rmw_channel((i << 10) + 0x130, 0x0F, 0x04);
      usleep(10);
      tap4[i] = (rd_channel((i << 10) + 0x176));

      //tap 5
      rmw_channel((i << 10) + 0x130, 0x0F, 0x05);
      usleep(10);
      tap5[i] = (rd_channel((i << 10) + 0x176));

      //tap 6
      rmw_channel((i << 10) + 0x130, 0x0F, 0x06);
      usleep(10);
      tap6[i] = (rd_channel((i << 10) + 0x176));

      //tap 7
      rmw_channel((i << 10) + 0x130, 0x0F, 0x07);
      usleep(10);
      tap7[i] = (rd_channel((i << 10) + 0x176));

      //access taps 8 - 11
      rmw_channel((i << 10) + 0x171, 0x1E, 0x16);
      usleep(10);

      //tap 8
      rmw_channel((i << 10) + 0x14C, 0x3F, 0x25);
      usleep(10);
      tap8[i] = (rd_channel((i << 10) + 0x176));

      //tap 9
      rmw_channel((i << 10) + 0x14C, 0x3F, 0x26);
      usleep(10);
      tap9[i] = (rd_channel((i << 10) + 0x176));

      //tap 10
      rmw_channel((i << 10) + 0x14C, 0x3F, 0x27);
      usleep(10);
      tap10[i] = (rd_channel((i << 10) + 0x176));

      //tap 11
      rmw_channel((i << 10) + 0x14C, 0x3F, 0x28);
      usleep(10);
      tap11[i] = (rd_channel((i << 10) + 0x176));

      //Determine sign of DFE taps

      if ((tap2[i] >> 7) == 1) tap2[i] = -(tap2[i] & 0x7F);
      else tap2[i] = (tap2[i] & 0x7F);

      if ((tap3[i] >> 7) == 1) tap3[i] = -(tap3[i] & 0x7F);
      else tap3[i] = (tap3[i] & 0x7F);

      if ((tap4[i] >> 6) == 1) tap4[i] = -(tap4[i] & 0x3F);
      else tap4[i] = (tap4[i] & 0x3F);

      if ((tap5[i] >> 6) == 1) tap5[i] = -(tap5[i] & 0x3F);
      else tap5[i] = (tap5[i] & 0x3F);

      if ((tap6[i] >> 5) == 1) tap6[i] = -(tap6[i] & 0x1F);
      else tap6[i] = (tap6[i] & 0x1F);


      if ((tap7[i] >> 5) == 1) tap7[i] = -(tap7[i] & 0x1F);
      else tap7[i] = (tap7[i] & 0x1F);


      if ((tap8[i] >> 6) == 1) tap8[i] = -(tap8[i] & 0x3F);
      else tap8[i] = (tap8[i] & 0x3F);

      if ((tap9[i] >> 6) == 1) tap9[i] = -(tap9[i] & 0x3F);
      else tap9[i] = (tap9[i] & 0x3F);

      if ((tap10[i] >> 5) == 1) tap10[i] = -(tap10[i] & 0x1F);
      else tap10[i] = (tap10[i] & 0x1F);

      if ((tap11[i] >> 5) == 1) tap11[i] = -(tap11[i] & 0x1F);
      else tap11[i] = (tap11[i] & 0x1F);



   }

   printf("\n\n");
   printf("Channel         :|");
   for (i = 0; i < NUMBER_OF_LANES; i++)
   {
      printf("%4X|", i);
   }
   printf("\n");
   printf("                 |");
   for (i = 0; i < NUMBER_OF_LANES; i++)
   {
      printf("----|");
   }
   printf("\n");


   printf("VOD             :|");
   for (i = 0; i < NUMBER_OF_LANES; i++)
   {
      printf("%4d|", tx_vodctrl[i]);
   }
   printf("\n");

   printf("Pre Tap 2 Level :|");
   for (i = 0; i < NUMBER_OF_LANES; i++)
   {
      printf("%4d|", decode_pretap2(tx_pretap_2[i]));
   }
   printf("\n");

   printf("Pre Tap 1 Level :|");
   for (i = 0; i < NUMBER_OF_LANES; i++)
   {
      printf("%4d|", decode_pretap1(tx_pretap_1[i]));
   }
   printf("\n");

   printf("Post Tap 1 Level:|");
   for (i = 0; i < NUMBER_OF_LANES; i++)
   {
      printf("%4d|", decode_posttap1(tx_posttap_1[i]));
   }
   printf("\n");

   printf("Post Tap 2 Level:|");
   for (i = 0; i < NUMBER_OF_LANES; i++)
   {
      printf("%4d|", decode_posttap2(tx_posttap_2[i]));
   }
   printf("\n");

   printf("CTLE DC Gain    :|");
   for (i = 0; i < NUMBER_OF_LANES; i++)
   {
      printf("%4d|", decode_dcgain(rx_eqdcgain[i]));
   }
   printf("\n");

   printf("CTLE AC Gain    :|");
   for (i = 0; i < NUMBER_OF_LANES; i++)
   {
      printf("%4d|", rx_eqctrl[i]);
   }
   printf("\n");

   printf("VGA Gain        :|");
   for (i = 0; i < NUMBER_OF_LANES; i++)
   {
      printf("%4d|", vga_gain[i]);
   }
   printf("\n");

   if (ADVANCED == 1)
   {
      printf("Dyn             :|");
      for (i = 0; i < NUMBER_OF_LANES; i++)
      {
         printf("%4d|", dyn[i]);
      }
      printf("\n");
      printf("Fix             :|");
      for (i = 0; i < NUMBER_OF_LANES; i++)
      {
         printf("%4d|", fix[i]);
      }
      printf("\n");
      printf("Ipd             :|");
      for (i = 0; i < NUMBER_OF_LANES; i++)
      {
         printf("%4d|", ipd[i]);
      }
      printf("\n");
   }

   printf("DFE Enabled     :|");
   for (i = 0; i < NUMBER_OF_LANES; i++)
   {
      printf("%4d|", dfe_enable[i]);
   }
   printf("\n");

   printf("DFE Tap 1       :|");
   for (i = 0; i < NUMBER_OF_LANES; i++)
   {
      printf("%4d|", tap1[i]);
   }
   printf("\n");

   printf("DFE Tap 2       :|");
   for (i = 0; i < NUMBER_OF_LANES; i++)
   {
      printf("%4d|", tap2[i]);
   }
   printf("\n");

   printf("DFE Tap 3       :|");
   for (i = 0; i < NUMBER_OF_LANES; i++)
   {
      printf("%4d|", tap3[i]);
   }
   printf("\n");

   printf("DFE Tap 4       :|");
   for (i = 0; i < NUMBER_OF_LANES; i++)
   {
      printf("%4d|", tap4[i]);
   }
   printf("\n");

   printf("DFE Tap 5       :|");
   for (i = 0; i < NUMBER_OF_LANES; i++)
   {
      printf("%4d|", tap5[i]);
   }
   printf("\n");

   printf("DFE Tap 6       :|");
   for (i = 0; i < NUMBER_OF_LANES; i++)
   {
      printf("%4d|", tap6[i]);
   }
   printf("\n");

   printf("DFE Tap 7       :|");
   for (i = 0; i < NUMBER_OF_LANES; i++)
   {
      printf("%4d|", tap7[i]);
   }
   printf("\n");

   printf("DFE Tap 8       :|");
   for (i = 0; i < NUMBER_OF_LANES; i++)
   {
      printf("%4d|", tap8[i]);
   }
   printf("\n");

   printf("DFE Tap 9       :|");
   for (i = 0; i < NUMBER_OF_LANES; i++)
   {
      printf("%4d|", tap9[i]);
   }
   printf("\n");

   printf("DFE Tap 10      :|");
   for (i = 0; i < NUMBER_OF_LANES; i++)
   {
      printf("%4d|", tap10[i]);
   }
   printf("\n");

   printf("DFE Tap 11      :|");
   for (i = 0; i < NUMBER_OF_LANES; i++)
   {
      printf("%4d|", tap11[i]);
   }
   printf("\n");

   printf("Nios Decision   :|");
   for (i = 0; i < NUMBER_OF_LANES; i++)
   {
      temp = rd_channel((i << 10) + 0x14D) & 0x07;
      printf("%4d|", temp);
   }
   printf("\n");


   //3'b000 = All Taps adaptation ON
   //3'b001 = Tap1-Tap6 adaptation ON
   //3'b010 = Tap1-Tap5 adaptation ON
   //3'b011 = Tap1-Tap4 adaptation ON
   //3'b100 = Tap1-Tap3 adaptation ON
   //3'b101 = Tap1-Tap2 adaptation ON
   //3'b110 = Tap1 adaptation ON
   //3'b111 = All Tap's adaptation Off (freezed)


}
