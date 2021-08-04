/* ODI functions */

#include <stdio.h>
#include "system.h"
#include "string.h"
#include "altera_avalon_pio_regs.h"
#include <unistd.h>
#include "io.h"
#include "altera_avalon_jtag_uart_regs.h"

#include "parameters.h"
#include "PMA_functions.h"


int enc_horizontal_phase (int phase) 
{
	int encoded_phase;

	switch (phase) 
	{
	case 1  : encoded_phase = 0x71 ; break;
	case 2  : encoded_phase = 0x70 ; break;
	case 3  : encoded_phase = 0x73 ; break;
	case 4  : encoded_phase = 0x72 ; break;
	case 5  : encoded_phase = 0x77 ; break;
	case 6  : encoded_phase = 0x76 ; break;
	case 7  : encoded_phase = 0x75 ; break;
	case 8  : encoded_phase = 0x74 ; break;
	case 9  : encoded_phase = 0x7d ; break;
	case 10 : encoded_phase = 0x7c ; break;
	case 11 : encoded_phase = 0x7f ; break;
	case 12 : encoded_phase = 0x7e ; break;
	case 13 : encoded_phase = 0x7b ; break;
	case 14 : encoded_phase = 0x7a ; break;
	case 15 : encoded_phase = 0x79 ; break;
	case 16 : encoded_phase = 0x78 ; break;
	case 17 : encoded_phase = 0x69 ; break;
	case 18 : encoded_phase = 0x68 ; break;
	case 19 : encoded_phase = 0x6b ; break;
	case 20 : encoded_phase = 0x6a ; break;
	case 21 : encoded_phase = 0x6f ; break;
	case 22 : encoded_phase = 0x6e ; break;
	case 23 : encoded_phase = 0x6d ; break;
	case 24 : encoded_phase = 0x6c ; break;
	case 25 : encoded_phase = 0x65 ; break;
	case 26 : encoded_phase = 0x64 ; break;
	case 27 : encoded_phase = 0x67 ; break;
	case 28 : encoded_phase = 0x66 ; break;
	case 29 : encoded_phase = 0x63 ; break;
	case 30 : encoded_phase = 0x62 ; break;
	case 31 : encoded_phase = 0x61 ; break;
	case 32 : encoded_phase = 0x60 ; break;
	case 33 : encoded_phase = 0x40 ; break;
	case 34 : encoded_phase = 0x41 ; break;
	case 35 : encoded_phase = 0x42 ; break;
	case 36 : encoded_phase = 0x43 ; break;
	case 37 : encoded_phase = 0x46 ; break;
	case 38 : encoded_phase = 0x47 ; break;
	case 39 : encoded_phase = 0x44 ; break;
	case 40 : encoded_phase = 0x45 ; break;
	case 41 : encoded_phase = 0x4c ; break;
	case 42 : encoded_phase = 0x4d ; break;
	case 43 : encoded_phase = 0x4e ; break;
	case 44 : encoded_phase = 0x4f ; break;
	case 45 : encoded_phase = 0x4a ; break;
	case 46 : encoded_phase = 0x4b ; break;
	case 47 : encoded_phase = 0x48 ; break;
	case 48 : encoded_phase = 0x49 ; break;
	case 49 : encoded_phase = 0x58 ; break;
	case 50 : encoded_phase = 0x59 ; break;
	case 51 : encoded_phase = 0x5a ; break;
	case 52 : encoded_phase = 0x5b ; break;
	case 53 : encoded_phase = 0x5e ; break;
	case 54 : encoded_phase = 0x5f ; break;
	case 55 : encoded_phase = 0x5c ; break;
	case 56 : encoded_phase = 0x5d ; break;
	case 57 : encoded_phase = 0x54 ; break;
	case 58 : encoded_phase = 0x55 ; break;
	case 59 : encoded_phase = 0x56 ; break;
	case 60 : encoded_phase = 0x57 ; break;
	case 61 : encoded_phase = 0x52 ; break;
	case 62 : encoded_phase = 0x53 ; break;
	case 63 : encoded_phase = 0x50 ; break;
	case 64  : encoded_phase = 0x51 ; break;
	case 65  : encoded_phase = 0x11 ; break;
	case 66  : encoded_phase = 0x10 ; break;
	case 67  : encoded_phase = 0x13 ; break;
	case 68  : encoded_phase = 0x12 ; break;
	case 69  : encoded_phase = 0x17 ; break;
	case 70 : encoded_phase = 0x16 ; break;
	case 71 : encoded_phase = 0x15 ; break;
	case 72 : encoded_phase = 0x14 ; break;
	case 73 : encoded_phase = 0x1d ; break;
	case 74 : encoded_phase = 0x1c ; break;
	case 75 : encoded_phase = 0x1f ; break;
	case 76 : encoded_phase = 0x1e ; break;
	case 77 : encoded_phase = 0x1b ; break;
	case 78 : encoded_phase = 0x1a ; break;
	case 79 : encoded_phase = 0x19 ; break;
	case 80 : encoded_phase = 0x18 ; break;
	case 81 : encoded_phase = 0x09 ; break;
	case 82 : encoded_phase = 0x08 ; break;
	case 83 : encoded_phase = 0x0b ; break;
	case 84 : encoded_phase = 0x0a ; break;
	case 85 : encoded_phase = 0x0f ; break;
	case 86 : encoded_phase = 0x0e ; break;
	case 87 : encoded_phase = 0x0d ; break;
	case 88 : encoded_phase = 0x0c ; break;
	case 89 : encoded_phase = 0x05 ; break;
	case 90 : encoded_phase = 0x04 ; break;
	case 91 : encoded_phase = 0x07 ; break;
	case 92 : encoded_phase = 0x06 ; break;
	case 93 : encoded_phase = 0x03 ; break;
	case 94 : encoded_phase = 0x02 ; break;
	case 95 : encoded_phase = 0x01 ; break;
	case 96 : encoded_phase = 0x00 ; break;
	case 97 : encoded_phase = 0x20 ; break;
	case 98 : encoded_phase = 0x21 ; break;
	case 99 : encoded_phase = 0x22 ; break;
	case 100 : encoded_phase = 0x23 ; break;
	case 101 : encoded_phase = 0x26 ; break;
	case 102 : encoded_phase = 0x27 ; break;
	case 103 : encoded_phase = 0x24 ; break;
	case 104 : encoded_phase = 0x25 ; break;
	case 105 : encoded_phase = 0x2c ; break;
	case 106 : encoded_phase = 0x2d ; break;
	case 107 : encoded_phase = 0x2e ; break;
	case 108 : encoded_phase = 0x2f ; break;
	case 109 : encoded_phase = 0x2a ; break;
	case 110 : encoded_phase = 0x2b ; break;
	case 111 : encoded_phase = 0x28 ; break;
	case 112 : encoded_phase = 0x29 ; break;
	case 113 : encoded_phase = 0x38 ; break;
	case 114 : encoded_phase = 0x39 ; break;
	case 115 : encoded_phase = 0x3a ; break;
	case 116 : encoded_phase = 0x3b ; break;
	case 117 : encoded_phase = 0x3e ; break;
	case 118 : encoded_phase = 0x3f ; break;
	case 119 : encoded_phase = 0x3c ; break;
	case 120 : encoded_phase = 0x3d ; break;
	case 121 : encoded_phase = 0x34 ; break;
	case 122 : encoded_phase = 0x35 ; break;
	case 123 : encoded_phase = 0x36 ; break;
	case 124 : encoded_phase = 0x37 ; break;
	case 125 : encoded_phase = 0x32 ; break;
	case 126 : encoded_phase = 0x33 ; break;
	case 127 : encoded_phase = 0x30 ; break;
	case 128 : encoded_phase = 0x31 ; break;  
		default : encoded_phase = 0x31; break;			  
	}
	return(encoded_phase);
}	

float get_odi_errorcount (int SelectedChannel,int EyeQInterval) 
{
	//int Counter_1ms_Reg;
	int temp0;
	int temp1;
	int temp2;
	int temp3;
	int temp4;
	int temp5;
	int ErrorCount_Reg_L;
	int ErrorCount_Reg_H;
	float ErrorCount;
	
	
	
	//Start Pattern Checker (with ODI enabled)
	
	//Set ODI Accelerator Counter Reset to 1'b1 and then to 1'b0 
	rmw_channel( ((SelectedChannel << 10) + 0x320),0x02,0x02);
	usleep(10);
	rmw_channel( ((SelectedChannel << 10) + 0x320),0x02,0x00);						

	//Set ODI Accelerator Counter Enable to 1'b1 to start the counting
	rmw_channel( ((SelectedChannel << 10) + 0x320),0x01,0x01);
	

	// Reset Counter_1MS register (alternate method, no longer used as this is design dependant

	//	     Control_Reg = Control_Reg | (0x2000);
	//        IOWR_ALTERA_AVALON_PIO_DATA(CONTROL_REG_BASE,Control_Reg);
	//        
	//        Control_Reg = Control_Reg & (0xDFFF);
	//        IOWR_ALTERA_AVALON_PIO_DATA(CONTROL_REG_BASE,Control_Reg);
	//						
	//	
	//			// Wait for programmed time interval
	//			do
	//			{
	//			Counter_1ms_Reg     = IORD_ALTERA_AVALON_PIO_DATA(COUNTER_1MS_REG_BASE);
	//			} while (Counter_1ms_Reg < EyeQInterval);   

	usleep(EyeQInterval); //EyeQInterval is in us.
	
	
	//Take a snapshot of the counters
	rmw_channel( ((SelectedChannel << 10) + 0x320),0x04,0x04);
	rmw_channel( ((SelectedChannel << 10) + 0x320),0x04,0x00);
	
	//Set ODI Accelerator Counter Enable to 1'b0 to stop the counting
	rmw_channel( ((SelectedChannel << 10) + 0x320),0x01,0x00);			
	
	//Read out the counters [42:0]
	temp0 =  rd_channel( ((SelectedChannel << 10) + 0x321)); 
	temp1 = (rd_channel( ((SelectedChannel << 10) + 0x322)) << 8);
	temp2 = (rd_channel( ((SelectedChannel << 10) + 0x323)) << 16);
	temp3 = (rd_channel( ((SelectedChannel << 10) + 0x324)) << 24);
	temp4 = rd_channel( ((SelectedChannel << 10) + 0x325));
	temp5 = (rd_channel ((SelectedChannel << 10) + 0x326) & 0x07) << 8;			


	
	ErrorCount_Reg_L     = temp0 + temp1 + temp2 + temp3;
	ErrorCount_Reg_H     = temp4 + temp5;
	
	if (DEBUG_ODI == 1)	
	{
		printf("\n   ErrorCount_Reg_L :%d",ErrorCount_Reg_L);
		printf("     ErrorCount_Reg_H :%d",ErrorCount_Reg_H);
	}

	ErrorCount = ((float) (ErrorCount_Reg_H) *  MULTIPLIER * MULTIPLIER) + (float) (ErrorCount_Reg_L);

	return(ErrorCount);		
	
}


float get_odi_errorcount_not_accelerated (int SelectedChannel,int EyeQInterval) 
{
	//int Counter_1ms_Reg;
	int temp0;
	int temp1;

	int ErrorCount_Reg;
	float ErrorCount;
	int temp;
	int done;
	

	//		copied from odi_for_prbs.tcl	  
	//	      # Begin odi capture
	//    #	odi_start = rodi_start_0
	//    #	odi_start = rodi_start_1
	//    rmw $channel $lcl_slave 0x169 0x01 0x00
	//    rmw $channel $lcl_slave 0x169 0x02 0x00
	//    rmw $channel $lcl_slave 0x169 0x02 0x02
	//    rmw $channel $lcl_slave 0x169 0x01 0x01
	//    rmw $channel $lcl_slave 0x169 0x01 0x00
	
	// Set ODI Pattern Reset to 1'b0 then set it to 1'b1 to reset the ODI capture
	rmw_channel( ((SelectedChannel << 10) + 0x169),0x02,0x00); // odi_rstn = '0' => ODI reset
	usleep(10);
	rmw_channel( ((SelectedChannel << 10) + 0x169),0x02,0x02); // odi_rstn = '1' => ODI out of reset

	
	// Set ODI Pattern Start to 1'b0 then set it to 1'b1 to Start the ODI capture
	rmw_channel( ((SelectedChannel << 10) + 0x169),0x01,0x00); // odi_start

	rmw_channel( ((SelectedChannel << 10) + 0x169),0x01,0x01); // rising edge on odi_start to trigger the capture		

	
	//
	//    # set the mux to read the status of ODI
	//    rmw $channel $lcl_slave 0x14c 0x7F 0x2d

	rmw_channel( ((SelectedChannel << 10) + 0x14C),0x7F,0x2D); // ODI status bits
	usleep(10);
	//
	//    # Wait for the done bit
	//    while { [expr [lindex [master_read_32 $lcl_slave [expr 0x177 * 4] 1] 0] & 0x02] != 0x02 } {} 

	do
	{
		temp = rd_channel((SelectedChannel << 10) + 0x177);
		done = 0x0001 & (temp >> 1); //Bit 1
		//printf("\n done is %2d", done);	 
	} while (done == 0); 


	
	//
	//    # Set mux for upper bits
	//    # Read the upper error bits
	//    rmw $channel $lcl_slave 0x14c 0x7F 0x2C
	
	rmw_channel( ((SelectedChannel << 10) + 0x14C),0x7F,0x2C); // ODI Pattern Error bits[15:8]
	usleep(10);  // Note this is mandatory for the mux to have the time to put the data available.
	
	//    set lcl_error [master_read_32 $lcl_slave [expr 0x177 * 4] 1]
	//    set lcl_error [expr $lcl_error * 2**8]
	
	temp1 = (rd_channel( ((SelectedChannel << 10) + 0x177)) << 8); 
	

	//    # read lower error bits
	//    rmw $channel $lcl_slave 0x14c 0x7F 0x2B

	rmw_channel( ((SelectedChannel << 10) + 0x14C),0x7F,0x2B); // ODI Pattern Error bits[7:0]	
	usleep(10);	  
	
	//    set lcl_error [expr $lcl_error + [master_read_32 $lcl_slave [expr 0x177 * 4] 1]]

	temp0 = (rd_channel( ((SelectedChannel << 10) + 0x177))); 
	

	ErrorCount_Reg     = temp0 + temp1;

	
	if (DEBUG_ODI == 1)	
	{
		printf("\n   ErrorCount_Reg :%d  temp1 : %d  temp0 : %d ",ErrorCount_Reg, temp1, temp0);
	}

	ErrorCount =  (float) (ErrorCount_Reg);			


	return(ErrorCount);		
	
}


float get_odi_bitcount (int SelectedChannel)
{
	int temp0;
	int temp1;
	int temp2;
	int temp3;
	int temp4;
	int temp5;
	int BitCount_L;
	int BitCount_H;
	float Totalbits;
	
	temp0 =  rd_channel( ((SelectedChannel << 10) + 0x32D)); 
	temp1 = (rd_channel( ((SelectedChannel << 10) + 0x32E)) << 8);
	temp2 = (rd_channel( ((SelectedChannel << 10) + 0x32F)) << 16);
	temp3 = (rd_channel( ((SelectedChannel << 10) + 0x330)) << 24);
	temp4 = rd_channel( ((SelectedChannel << 10) + 0x331));
	temp5 = (rd_channel ((SelectedChannel << 10) + 0x332) & 0x07) << 8;	
	
	BitCount_L     		  = temp0 + temp1 + temp2 + temp3;
	BitCount_H     		  = temp4 + temp5;		

	if (DEBUG_ODI == 1)	
	{				
		printf("\n   BitCount_L %d:",BitCount_L);
		printf("   BitCount_H %d:",BitCount_H);
	}

	
	
	Totalbits = ((float) (BitCount_H ) *  MULTIPLIER * MULTIPLIER) + (float) (BitCount_L ); 

	return(Totalbits);
}


float get_odi_bitcount_not_accelerated (int SelectedChannel)
{
	int temp0;
	int temp1;

	int BitCount;

	float Totalbits;
	
	rmw_channel( ((SelectedChannel << 10) + 0x14C),0x7F,0x2A); // ODI Pattern Counter bits[15:8]
	usleep(10);
	
	temp1 = (rd_channel( ((SelectedChannel << 10) + 0x177)) << 8); 
	

	rmw_channel( ((SelectedChannel << 10) + 0x14C),0x7F,0x29); // ODI Pattern Counter bits[7:0]	
	usleep(10);  

	temp0 = (rd_channel( ((SelectedChannel << 10) + 0x177))); 
	
	
	
	BitCount     		  = temp0 + temp1;

	if (DEBUG_ODI == 1)	
	{				
		printf("\n   BitCount : %d  temp1 : %d  temp0 : %d",BitCount,temp1, temp0);
	}

	
	
	Totalbits = (float) (BitCount ); 

	return(Totalbits);
}



void print_2D_eye (float BER_Array[][DimB], float ErrorCount_Array[][DimB],int *veye_top, int *veye_bottom, int *table_phase_start)
{
	
	int i;
	int j;
	int index;
	//int ErrorCount;

	
	printf("\nPhase    ");
	for (i =0;i <64; i++)
	//for (i =0;i <128; i++)
	{
		index = *table_phase_start + i;
		if (index > 128)
		index = index -128;
		if (index < 100)
		printf("  ");
		else if ((index >= 100) && (index <= 128))
		printf(" 1");
	}
	printf("\n         ");
	for (i =0;i <64; i++)
	//for (i =0;i <128; i++)
	{
		index = *table_phase_start + i;
		if (index > 128)
		index = index -128;
		if (index < 10) 
		printf("  ");
		else if ((index >= 10) && (index < 20))
		printf(" 1");
		else if ((index >= 20) && (index < 30))
		printf(" 2");
		else if ((index >= 30) && (index < 40))
		printf(" 3");
		else if ((index >= 40) && (index < 50))
		printf(" 4");
		else if ((index >= 50) && (index < 60))
		printf(" 5");
		else if ((index >= 60) && (index < 70))
		printf(" 6");
		else if ((index >= 70) && (index < 80))
		printf(" 7");
		else if ((index >= 80) && (index < 90))
		printf(" 8");
		else if ((index >= 90) && (index < 100))
		printf(" 9");
		else if ((index >= 100) && (index < 110))
		printf(" 0");
		else if ((index >= 110) && (index < 120))
		printf(" 1");
		else if ((index >= 120) && (index <= 128))
		printf(" 2");
		else
		printf(" 3");
	}
	printf("\nStep     ");
	for (i =0;i <64; i++)
	{
		index = *table_phase_start + i;
		if (index > 128)
		index = index -128;
		if (index < 10) 
		printf("%2d",index);
		else if ((index >= 10) && (index < 20))
		printf("%2d",index-10);
		else if ((index >= 20) && (index < 30))
		printf("%2d",index-20);
		else if ((index >= 30) && (index < 40))
		printf("%2d",index-30);
		else if ((index >= 40) && (index < 50))
		printf("%2d",index-40);
		else if ((index >= 50) && (index < 60))
		printf("%2d",index-50);
		else if ((index >= 60) && (index < 70))
		printf("%2d",index-60);
		else if ((index >= 70) && (index < 80))
		printf("%2d",index-70);
		else if ((index >= 80) && (index < 90))
		printf("%2d",index-80);
		else if ((index >= 90) && (index < 100))
		printf("%2d",index-90);
		else if ((index >= 100) && (index < 110))
		printf("%2d",index-100);
		else if ((index >= 110) && (index < 120))
		printf("%2d",index-110);
		else if ((index >= 120) && (index <= 128))
		printf("%2d",index-120);
		else
		printf("%2d",index-120);
	}			
	printf("\n========================================================================");
	printf("=================================================================\n");



	for (j = *veye_top; j > 32 ; j--)
	{   
		printf("\n%3d     :",j-32);
		for (i = 0; i < 64 ; i++)
		{   
			
			index = *table_phase_start + i;
			if (index > 128)
			index = index -128;
			if (FANCY_GRAPHICS)
			{
				if (BER_Array[index][j] == 0.0f)
				{
					if (i == 32)
					printf(COLOR_LIGHT_BLUE COLOR_INVERSE " │" COLOR_RESET);
					else
					printf(COLOR_LIGHT_BLUE COLOR_INVERSE "  " COLOR_RESET);
				}
				else if ( (BER_Array[index][j] < 0.00001f))
				printf(COLOR_LIGHT_CYAN COLOR_INVERSE "  " COLOR_RESET );
				else if ( (BER_Array[index][j] < 0.0001f) && (BER_Array[index][j] >= 0.00001f) )
				printf(COLOR_LIGHT_GREEN COLOR_INVERSE "  " COLOR_RESET );
				else if ( (BER_Array[index][j] < 0.001f) && (BER_Array[index][j] >= 0.0001f) )
				printf(COLOR_YELLOW COLOR_INVERSE "  " COLOR_RESET );
				else if ( (BER_Array[index][j] >= 0.001f))
				printf(COLOR_LIGHT_RED COLOR_INVERSE "  " COLOR_RESET );
				else
				printf("..");
			}
			else
			{				
				if (BER_Array[index][j] == 0.0f)
				printf("  ");
				else
				printf("xx");
			}
		}
	}

	for (j = 1; j < *veye_bottom ; j++)
	{   
		printf("\n-%3d    :",j);
		for (i = 0; i < 64 ; i++)
		{ 
			index = *table_phase_start + i;
			if (index > 128)
			index = index -128;				
			if (FANCY_GRAPHICS)
			{
				if (BER_Array[index][j] == 0.0f)
				{
					if (i == 32)
					printf(COLOR_LIGHT_BLUE COLOR_INVERSE " │" COLOR_RESET);
					else
					printf(COLOR_LIGHT_BLUE COLOR_INVERSE "  " COLOR_RESET);
				}
				else if ( (BER_Array[index][j] < 0.00001f))
				printf(COLOR_LIGHT_CYAN COLOR_INVERSE "  " COLOR_RESET );
				else if ( (BER_Array[index][j] < 0.0001f) && (BER_Array[index][j] >= 0.00001f) )
				printf(COLOR_LIGHT_GREEN COLOR_INVERSE "  " COLOR_RESET );
				else if ( (BER_Array[index][j] < 0.001f) && (BER_Array[index][j] >= 0.0001f) )
				printf(COLOR_YELLOW COLOR_INVERSE "  " COLOR_RESET );
				else if ( (BER_Array[index][j] >= 0.001f))
				printf(COLOR_LIGHT_RED COLOR_INVERSE "  " COLOR_RESET );
				else
				printf("..");
			}
			else
			{

				if (BER_Array[index][j] == 0.0f)
				printf("  ");
				else
				printf("xx");
			}
		}
	}		
	printf("\n\n");
	
	if (FANCY_GRAPHICS)
	{
		//Print legend

		printf("\n");
		printf("         ");
		printf(COLOR_LIGHT_RED COLOR_INVERSE 	"                    " COLOR_RESET );
		printf(COLOR_YELLOW COLOR_INVERSE 		"                    " COLOR_RESET );
		printf(COLOR_LIGHT_GREEN COLOR_INVERSE	"                    " COLOR_RESET );
		printf(COLOR_LIGHT_CYAN COLOR_INVERSE	"                    " COLOR_RESET );
		printf(COLOR_LIGHT_BLUE COLOR_INVERSE	"                    " COLOR_RESET );
		printf("\n");

		printf("BER      ");
		printf("1                 ");
		printf("10E-4               ");
		printf("10E-5               ");
		printf("10E-6              ");
		printf("<10E-6              ");

		printf("\n");

	}}

void print_1D_eye (float BER_Array[][DimB], int *table_phase_start)
{		
	
	int Table[130][13];	
	int index;
	int i;
	int j;
	
	
	///////////////////////////////////////////////////////////////////////
	// Generate a table for the BER
	///////////////////////////////////////////////////////////////////////	

	
	for (i = 0; i < 64 ; i++)
	{
		index = *table_phase_start + i;
		if (index > 128)
		index = index -128;	
		
		if ( (BER_Array[index][0] >= 1.0f) )
		Table[index][0] = 1;
		else
		Table[index][0] = 0;

		if ( (BER_Array[index][0] < 1.0f) && (BER_Array[index][0] >= 0.1f) )
		Table[index][1] = 1;
		else
		Table[index][1] = 0;

		if ( (BER_Array[index][0] < 0.1f) && (BER_Array[index][0] >= 0.01f) )
		Table[index][2] = 1;
		else
		Table[index][2] = 0;
		
		if ( (BER_Array[index][0] < 0.01f) && (BER_Array[index][0] >= 0.001f) )
		Table[index][3] = 1;
		else
		Table[index][3] = 0;

		if ( (BER_Array[index][0] < 0.001f) && (BER_Array[index][0] >= 0.0001f) )
		Table[index][4] = 1;
		else
		Table[index][4] = 0;

		if ( (BER_Array[index][0] < 0.0001f) && (BER_Array[index][0] >= 0.00001f) )
		Table[index][5] = 1;
		else
		Table[index][5] = 0;
		
		if ( (BER_Array[index][0] < 0.00001f) && (BER_Array[index][0] >= 0.000001f) )
		Table[index][6] = 1;
		else
		Table[index][6] = 0;																									

		if ( (BER_Array[index][0] < 0.000001f) && (BER_Array[index][0] >= 0.0000001f) )
		Table[index][7] = 1;
		else
		Table[index][7] = 0;	

		if ( (BER_Array[index][0] < 0.0000001f) && (BER_Array[index][0] >= 0.00000001f) )
		Table[index][8] = 1;
		else
		Table[index][8] = 0;	

		if ( (BER_Array[index][0] < 0.00000001f) && (BER_Array[index][0] >= 0.000000001f) )
		Table[index][9] = 1;
		else
		Table[index][9] = 0;

		if ( (BER_Array[index][0] < 0.000000001f) && (BER_Array[index][0] >= 0.0000000001f) )
		Table[index][10] = 1;
		else
		Table[index][10] = 0;

		if ( (BER_Array[index][0] < 0.0000000001f) && (BER_Array[index][0] >= 0.00000000001f) )
		Table[index][11] = 1;
		else
		Table[index][11] = 0;

		if ( (BER_Array[index][0] < 0.00000000001f) )
		Table[index][12] = 1;
		else
		Table[index][12] = 0;
		
	} // for loop
	
	printf("\n BATHTUB CURVE ESTIMATE ACROSS 64 PHASES (one UI)\n");
	

	
	///////////////////////////////////////////////////////////////////////				
	// Print Centered Eye
	///////////////////////////////////////////////////////////////////////				
	printf("\nPhase   ");
	for (i =0;i <64; i++)
	//for (i =0;i <128; i++)
	{
		index = *table_phase_start + i;
		if (index > 128)
		index = index -128;
		if (index < 100)
		printf("  ");
		else if ((index >= 100) && (index <= 128))
		printf(" 1");
	}
	printf("\n        ");
	for (i =0;i <64; i++)
	//for (i =0;i <128; i++)
	{
		index = *table_phase_start + i;
		if (index > 128)
		index = index -128;
		if (index < 10) 
		printf("  ");
		else if ((index >= 10) && (index < 20))
		printf(" 1");
		else if ((index >= 20) && (index < 30))
		printf(" 2");
		else if ((index >= 30) && (index < 40))
		printf(" 3");
		else if ((index >= 40) && (index < 50))
		printf(" 4");
		else if ((index >= 50) && (index < 60))
		printf(" 5");
		else if ((index >= 60) && (index < 70))
		printf(" 6");
		else if ((index >= 70) && (index < 80))
		printf(" 7");
		else if ((index >= 80) && (index < 90))
		printf(" 8");
		else if ((index >= 90) && (index < 100))
		printf(" 9");
		else if ((index >= 100) && (index < 110))
		printf(" 0");
		else if ((index >= 110) && (index < 120))
		printf(" 1");
		else if ((index >= 120) && (index <= 128))
		printf(" 2");
		else
		printf(" 3");
	}
	printf("\nStep    ");
	for (i =0;i <64; i++)
	{
		index = *table_phase_start + i;
		if (index > 128)
		index = index -128;
		if (index < 10) 
		printf("%2d",index);
		else if ((index >= 10) && (index < 20))
		printf("%2d",index-10);
		else if ((index >= 20) && (index < 30))
		printf("%2d",index-20);
		else if ((index >= 30) && (index < 40))
		printf("%2d",index-30);
		else if ((index >= 40) && (index < 50))
		printf("%2d",index-40);
		else if ((index >= 50) && (index < 60))
		printf("%2d",index-50);
		else if ((index >= 60) && (index < 70))
		printf("%2d",index-60);
		else if ((index >= 70) && (index < 80))
		printf("%2d",index-70);
		else if ((index >= 80) && (index < 90))
		printf("%2d",index-80);
		else if ((index >= 90) && (index < 100))
		printf("%2d",index-90);
		else if ((index >= 100) && (index < 110))
		printf("%2d",index-100);
		else if ((index >= 110) && (index < 120))
		printf("%2d",index-110);
		else if ((index >= 120) && (index <= 128))
		printf("%2d",index-120);
		else
		printf("%2d",index-120);
	}			
	printf("\n========================================================================");
	printf("=================================================================\n");
	
	for (j = 0; j < 13 ; j++)
	{   
		printf("\n10E-%2d :",j);  
		for (i = 0; i < 64 ; i++)
		{ 
			index = *table_phase_start + i;
			if (index > 128)
			index = index -128;				    
			if (Table[index][j] == 1)
			if (FANCY_GRAPHICS)
			{
				printf("■■");
				//printf("%2d",Table[index][j])
			}
			else
			{
				printf("**");
			}
			else
			if ((i == 32) && (j < 12))
			printf(" │");
			else
			printf("  ");
		}
	}
	printf("\n");
}


float do_eye_measurement(int SelectedChannel, int EyeQInterval,int Bandwidth, int VCCER_Level, int DFE_Mode 
, float BER_Array[][DimB], float ErrorCount_Array[][DimB],int *veye, int *veye_top,int *veye_bottom, int *table_phase_start
, int *eye_phase, int *optimum_phase, float *Totalbits_ODI, int Verbose)
{

	int i, j;
	int start_value;
	int start_value_found;
	int end_value;


	int encoded_phase;
	
	int x,y;  

	float eye;
	float BER_Minimum;
	int BER_Minimum_phase;	
	float ErrorCount_pat0;
	float ErrorCount_pat1;	
	float ErrorCount_pat_top;
	float ErrorCount_pat_bot;
	float ErrorCount_pat_top_dfe = 0 ;
	float ErrorCount_pat_bot_dfe = 0 ;
	float Totalbits_ODI_top;
	float Totalbits_ODI_bot;	
	
	/**********************************************************************/
	/* Step 1 : Enable ODI																 */
	/**********************************************************************/
	
	//Enable ODI
	rmw_channel( ((SelectedChannel << 10) + 0x143),0x03,0x02);
	
	//Set ODI Vertical scale based on VCCER level (1 = 0.9V,2 = 1.03V,3 = 1.11V)
	switch (VCCER_Level)
	{
	case VCCER_900MV 	: rmw_channel( ((SelectedChannel << 10) + 0x144),0x03,0x01); break;
	case VCCER_1030MV : rmw_channel( ((SelectedChannel << 10) + 0x144),0x03,0x02); break;
	case VCCER_1110MV : rmw_channel( ((SelectedChannel << 10) + 0x144),0x03,0x03); break;
		default : rmw_channel( ((SelectedChannel << 10) + 0x144),0x03,0x01); break;
	}		
	
	//Set ODI bandwidth (0x144[7],0x145[7]) 00 is below 2 Gbps,01 = 2 to 5 Gbps,10 = 5 to 10 Gbps, 11 = above 10 Gbps)
	switch (Bandwidth)
	{
	case BELOW_2GBPS 				: 
		rmw_channel( ((SelectedChannel << 10) + 0x144),0x80,0x00); 
		rmw_channel( ((SelectedChannel << 10) + 0x145),0x80,0x00); 
		break;
	case BETWEEN_2GBPS_5GBPS 	: 
		rmw_channel( ((SelectedChannel << 10) + 0x144),0x80,0x00); 
		rmw_channel( ((SelectedChannel << 10) + 0x145),0x80,0x80); 
		break;				
	case BETWEEN_5GBPS_10GBPS 	: 
		rmw_channel( ((SelectedChannel << 10) + 0x144),0x80,0x80); 
		rmw_channel( ((SelectedChannel << 10) + 0x145),0x80,0x00); 
		break;
	case ABOVE_10GBPS 	: 
		rmw_channel( ((SelectedChannel << 10) + 0x144),0x80,0x80); 
		rmw_channel( ((SelectedChannel << 10) + 0x145),0x80,0x80); 
		break;			
		default : 
		rmw_channel( ((SelectedChannel << 10) + 0x144),0x80,0x80); 
		rmw_channel( ((SelectedChannel << 10) + 0x145),0x80,0x80); 
		break;				
	}				

	//Set Reserved bits for normal operation 0x144[6:3] = 0x0001
	rmw_channel( ((SelectedChannel << 10) + 0x144),0x78,0x08);		
	
	//Enable ODI SIgnal Processing Block and EODI for normal signal processing mode
	rmw_channel( ((SelectedChannel << 10) + 0x168),0x03,0x03);		
	
	//Set ODI DFE mode, 0 is off)
	if (DFE_Mode == 0)
	rmw_channel( ((SelectedChannel << 10) + 0x168),0x04,0x00);	
	else
	rmw_channel( ((SelectedChannel << 10) + 0x168),0x04,0x04);
	
	//Set ODI Pattern Counter tresshold (set to maximum, 3'b110 :32K bits)
	rmw_channel( ((SelectedChannel << 10) + 0x168),0xE0,0xC0);			
	
	//Set ODI Signal processing control Mode to 1
	rmw_channel( ((SelectedChannel << 10) + 0x169),0x04,0x04);	
	
	// Set Offset cancellation of ODI to zero (This is done automatically now)
	//		rmw_channel( ((SelectedChannel << 10) + 0x146),0xFF,0x0);	
	//		rmw_channel( ((SelectedChannel << 10) + 0x147),0xFF,0x0);


	/**********************************************************************/
	/* Step 2 : Find eye center by sweeping only horizontal							*/
	/**********************************************************************/		
	
	///////////////////////////////////////////////////////////////////////				
	// Go through all horizontal phase steps to determine the eye opening center
	///////////////////////////////////////////////////////////////////////	
	

	//Set ODI vertical phase to zero
	rmw_channel( ((SelectedChannel << 10) + 0x143),0xFC, 0 << 2);
	
	for (x = 1; x <= 128 ; x++)
	{
		
		if (DEBUG_ODI == 1)		
		printf("\nx : %2d",x);
		
		
		
		//Set ODI horizontal phase (after encoding it)
		encoded_phase = enc_horizontal_phase (x); //phases are from 1 to 128.
		if (DEBUG_ODI == 1)	
		printf("    encoded_phase = 0x%2x",encoded_phase);
		
		rmw_channel( ((SelectedChannel << 10) + 0x145),0x7F, encoded_phase);	
		
		
		//Set ODI pattern filter to 2'b00 (pattern filter "0")  {0x119[4],0x144[2]}
		rmw_channel( ((SelectedChannel << 10) + 0x119),0x10,0x0);
		rmw_channel( ((SelectedChannel << 10) + 0x144),0x04,0x0);	

		//Take snapshot of the errorcounters
		ErrorCount_pat0 = get_odi_errorcount (SelectedChannel,EyeQInterval);		
		

		//Set ODI pattern filter to 2'b01 (pattern filter "1")  {0x119[4],0x144[2]}
		rmw_channel( ((SelectedChannel << 10) + 0x119),0x10,0x0);
		rmw_channel( ((SelectedChannel << 10) + 0x144),0x04,0x04);
		
		//Take snapshot of the errorcounters
		ErrorCount_pat1 = get_odi_errorcount (SelectedChannel,EyeQInterval);		
		
		//Read the Bitcount of the latest snapshot
		*Totalbits_ODI = get_odi_bitcount(SelectedChannel);

		ErrorCount_Array[x][0] = ErrorCount_pat0 + ErrorCount_pat1;
		
		
		if (ErrorCount_Array[x][0] > 0)
		{
			BER_Array[x][0] = (ErrorCount_Array[x][0])/ *Totalbits_ODI;
		}
		else 
		BER_Array[x][0] = 0;  

		if (DEBUG_ODI == 1)	
		{
			printf("\n ErrorCount : %5f   Totalbits : %5f   BER : %e \n", ErrorCount_Array[x][0], *Totalbits_ODI, BER_Array[x][0]);
		}				
		
		
		
	} // for loop x		
	

	///////////////////////////////////////////////////////////////////////				
	// Determine horizontal eye opening
	///////////////////////////////////////////////////////////////////////				
	
	*eye_phase = 0;
	BER_Minimum = 1;
	BER_Minimum_phase = 0;
	
	for (i = 1; i <= 128 ;i++)
	{
		if (BER_Array[i][0] == 0)
		*eye_phase = *eye_phase + 1;
		if (BER_Array[i][0] < BER_Minimum )
		{
			BER_Minimum = BER_Array[i][0];
			BER_Minimum_phase = i;
		}
	}
	
	

	eye = (float) *eye_phase/64;
	
	if (Verbose == 1)
	printf("\nHoriz. Eye opening  : %2d steps  %2f UI", *eye_phase,eye);
	
	start_value = 0;
	start_value_found = 0;
	end_value = 0;
	
	for (i = 2; i <= 128 ;i++)
	{
		//printf("\ni:%2d,BER_Array[i][0] : %e,BER_Array[i-1][0] : %e",i,BER_Array[i][0],BER_Array[i-1][0])	;
		if (BER_Array[i][0] != BER_Array[i-1][0]) 	 
		{
			if ((BER_Array[i][0] == 0) && (start_value_found == 0))
			{
				start_value = i;
				start_value_found = 1; // This is to avoid a glitch generating a new wrong startvalue.
			}
			else if (BER_Array[i-1][0] == 0)
			end_value = i-1;
		}
	}

	if (Verbose == 1)
	{
		printf("\nStart_phase         : %3d",start_value);
		printf("\nEnd_phase           : %3d",end_value);
	}
	if (start_value > end_value )
	end_value = end_value + 128;
	

	//printf("\nend_value   : %2d",end_value);	
	if (*eye_phase == 0)
	*optimum_phase = BER_Minimum_phase ;
	else	
	*optimum_phase = start_value + *eye_phase/2;
	
	//printf("\noptimum phase   : %2d",optimum_phase );
	if (*optimum_phase >= 128 )
	{
		*table_phase_start = *optimum_phase - 32;
		*optimum_phase = *optimum_phase -128;
	}
	else
	{
		*table_phase_start = *optimum_phase -32;
		if (*table_phase_start < 0)
		*table_phase_start = *table_phase_start + 128;
	}
	if (DEBUG_ODI == 1)
	printf("\nOptimum phase       : %3d",*optimum_phase );
	if (DEBUG_ODI == 1)
	printf("\nTable_phase_start   : %3d",*table_phase_start );
	


	
	/**********************************************************************/
	/* Step 3 : Measure 2D eye                          						*/
	/**********************************************************************/		
	
	
	///////////////////////////////////////////////////////////////////////				
	// Go through all horizontal phase steps and all vertical phase steps one by one and measure the BER around +/-32 phases around optimum phase
	///////////////////////////////////////////////////////////////////////	
	
	int tmp = 0;

	
	for (i = 0; i < 64 ; i++)
	{
		///////////////////////////////////////////////////////////////////////				
		// Top Half
		///////////////////////////////////////////////////////////////////////	
		for (j = 31; j > 0 ; j--) 
		{ 
			
			x = *table_phase_start + i;
			if (x > 128)
			x = x - 128; // Modulo 128
			y = j+32;
			
			if (DEBUG_ODI == 1)		
			printf("\nx : %2d y : %2d",x,y);
			
			tmp = tmp+1;
			
			if (Verbose == 1)
			{
				switch (tmp)
				{
				case 410: printf("\n...10%% done..."); break;
				case 820: printf("\n...20%% done..."); break;
				case 1260: printf("\n...30%% done..."); break;
				case 1640: printf("\n...40%% done..."); break;
				case 2050: printf("\n...50%% done..."); break;
				case 2460: printf("\n...60%% done..."); break;
				case 2870: printf("\n...70%% done..."); break;
				case 3280: printf("\n...80%% done..."); break;
				case 3690: printf("\n...90%% done..."); break;

					default : break;
				}	
			}		
			
			//Set ODI vertical phase
			rmw_channel( ((SelectedChannel << 10) + 0x143),0xFC, y << 2);	
			
			
			//Set ODI horizontal phase (after encoding it)
			encoded_phase = enc_horizontal_phase (x); //phases are from 1 to 128.
			if (DEBUG_ODI == 1)	
			printf("    encoded_phase = 0x%2x",encoded_phase);
			
			rmw_channel( ((SelectedChannel << 10) + 0x145),0x7F, encoded_phase);	
			
			
			//Set ODI pattern filter to 2'b01 (pattern filter "1")  {0x119[4],0x144[2]}
			rmw_channel( ((SelectedChannel << 10) + 0x119),0x10,0x0);
			rmw_channel( ((SelectedChannel << 10) + 0x144),0x04,0x4);	

			//Take snapshot of the errorcounters
			ErrorCount_pat_top = get_odi_errorcount (SelectedChannel,EyeQInterval);		

			if (DFE_Mode == 1)
			{
				//Set ODI pattern filter to 2'b11 (pattern filter "1" for DFE)  {0x119[4],0x144[2]}
				rmw_channel( ((SelectedChannel << 10) + 0x119),0x10,0x10);
				rmw_channel( ((SelectedChannel << 10) + 0x144),0x04,0x04);	
				ErrorCount_pat_top_dfe = get_odi_errorcount (SelectedChannel,EyeQInterval);	
			}

			//Read the Bitcount of the latest snapshot
			Totalbits_ODI_top = get_odi_bitcount(SelectedChannel);
			

			if (DFE_Mode == 0)
			{
				ErrorCount_Array[x][y] = ErrorCount_pat_top ;
			}
			else
			{
				ErrorCount_Array[x][y] = ErrorCount_pat_top + ErrorCount_pat_top_dfe ;
			}
			
			
			if (ErrorCount_Array[x][y] > 0)
			{
				BER_Array[x][y] = (ErrorCount_Array[x][y]) / Totalbits_ODI_top;
			}
			else 
			{
				BER_Array[x][y] = 0;  
			}

			if (DEBUG_ODI == 1)	
			{
				printf("\n ErrorCount : %5f   Totalbits top : %5f   BER : %e \n", ErrorCount_Array[x][y], Totalbits_ODI_top, BER_Array[x][y]);
			}		
			
		} // Top Half
		

		///////////////////////////////////////////////////////////////////////				
		// Bottom Half
		///////////////////////////////////////////////////////////////////////	
		for (j = 0; j < 32 ; j++) 
		{ 
			
			x = *table_phase_start + i;
			if (x > 128)
			x = x - 128; // Modulo 128
			y = 32-j;
			
			if (DEBUG_ODI == 1)		
			printf("\nx : %2d y : %2d",x,y);
			
			tmp = tmp+1;

			if (Verbose == 1)
			{			
				switch (tmp)
				{
				case 410: printf("\n...10%% done..."); break;
				case 820: printf("\n...20%% done..."); break;
				case 1260: printf("\n...30%% done..."); break;
				case 1640: printf("\n...40%% done..."); break;
				case 2050: printf("\n...50%% done..."); break;
				case 2460: printf("\n...60%% done..."); break;
				case 2870: printf("\n...70%% done..."); break;
				case 3280: printf("\n...80%% done..."); break;
				case 3690: printf("\n...90%% done..."); break;

					default : break;
				}			
			}			
			//Set ODI vertical phase
			rmw_channel( ((SelectedChannel << 10) + 0x143),0xFC, y << 2);	
			
			
			//Set ODI horizontal phase (after encoding it)
			encoded_phase = enc_horizontal_phase (x); //phases are from 1 to 128.
			if (DEBUG_ODI == 1)	
			printf("    encoded_phase = 0x%2x",encoded_phase);
			
			rmw_channel( ((SelectedChannel << 10) + 0x145),0x7F, encoded_phase);	
			
			
			//Set ODI pattern filter to 2'b00   {0x119[4],0x144[2]}
			rmw_channel( ((SelectedChannel << 10) + 0x119),0x10,0x0);
			rmw_channel( ((SelectedChannel << 10) + 0x144),0x04,0x0);	

			//Take snapshot of the errorcounters
			ErrorCount_pat_bot = get_odi_errorcount (SelectedChannel,EyeQInterval);		

			if (DFE_Mode == 1)
			{
				//Set ODI pattern filter to 2'b10   {0x119[4],0x144[2]}
				rmw_channel( ((SelectedChannel << 10) + 0x119),0x10,0x10);
				rmw_channel( ((SelectedChannel << 10) + 0x144),0x04,0x00);	
				ErrorCount_pat_bot_dfe = get_odi_errorcount (SelectedChannel,EyeQInterval);	
			}

			//Read the Bitcount of the latest snapshot
			Totalbits_ODI_bot = get_odi_bitcount(SelectedChannel);
			

			if (DFE_Mode == 0)
			{
				ErrorCount_Array[x][y] = ErrorCount_pat_bot ;
			}
			else
			{
				ErrorCount_Array[x][y] = ErrorCount_pat_bot + ErrorCount_pat_bot_dfe ;
			}
			
			
			if (ErrorCount_Array[x][y] > 0)
			{
				BER_Array[x][y] = (ErrorCount_Array[x][y]) / Totalbits_ODI_bot;
			}
			else 
			{
				BER_Array[x][y] = 0;  
			}

			if (DEBUG_ODI == 1)	
			{
				printf("\n ErrorCount : %5f   Totalbits bottom : %5f   BER : %e \n", ErrorCount_Array[x][y], Totalbits_ODI_bot, BER_Array[x][y]);
			}		
			
		} // Bottom Half
		
		
		*Totalbits_ODI	= Totalbits_ODI_top + Totalbits_ODI_bot;
		
		
		
		
		
		
	} // for loop x


	

	///////////////////////////////////////////////////////////////////////				
	// Find Vertical Eye Opening using optimum horizontal phase
	///////////////////////////////////////////////////////////////////////					
	
	*veye = 0;
	
	for (i = 32; i <64 ;i++)
	{
		if (BER_Array[*optimum_phase][i] == 0)
		*veye = *veye + 1;
	}	
	for (i = 0; i <32 ;i++)
	{
		if (BER_Array[*optimum_phase][i] == 0)
		*veye = *veye + 1;
	}		  
	
	*veye_top = *veye/2 + 10  + 32;
	*veye_bottom = *veye/2 + 10;
	if (Verbose == 1)
	{
		printf("\nveye at optimum phase : %2d steps",*veye);
		printf("\n");	
	}
	

	/**********************************************************************/
	/* Step 4 : Disable ODI																 */
	/**********************************************************************/

	//Disable ODI
	rmw_channel( ((SelectedChannel << 10) + 0x143),0x03,0x03);
	
	return eye;
}


float do_eye_measurement_no_acceleration(int SelectedChannel, int EyeQInterval,int Bandwidth, int VCCER_Level, int DFE_Mode 
, float BER_Array[][DimB], float ErrorCount_Array[][DimB],int *veye, int *veye_top,int *veye_bottom, int *table_phase_start
, int *eye_phase, int *optimum_phase, float *Totalbits_ODI, int Verbose)
{

	int i, j;
	int start_value;
	int start_value_found;
	int end_value;


	int encoded_phase;
	
	int x,y;  

	float eye;
	float BER_Minimum;
	int BER_Minimum_phase;	
	float ErrorCount_pat0;
	float ErrorCount_pat1;	
	float ErrorCount_pat_top;
	float ErrorCount_pat_bot;
	float ErrorCount_pat_top_dfe = 0 ;
	float ErrorCount_pat_bot_dfe = 0 ;
	float Totalbits_ODI_top;
	float Totalbits_ODI_bot;	
	float Totalbits_pat0;
	float Totalbits_pat1;
	float Totalbits_pat_bot;
	float Totalbits_pat_bot_dfe = 0;
	float Totalbits_pat_top;
	float Totalbits_pat_top_dfe = 0 ;


	
	/**********************************************************************/
	/* Step 1 : Enable ODI																 */
	/**********************************************************************/
	
	//

	//  # Offset 0x140
	//  #     [5:3] cr_deser_adapt_force[2:0] = 3'b0 (force_adaption_output = Normal Outputs)
	//  rmw $channel $slave 0x140 0x38 0x00

	//		rmw_channel( ((SelectedChannel << 10) + 0x140),0x38,0x00);

	
	//Enable ODI
	rmw_channel( ((SelectedChannel << 10) + 0x143),0x03,0x02);
	
	//Set ODI Vertical scale based on VCCER level (1 = 0.9V,2 = 1.03V,3 = 1.11V)
	switch (VCCER_Level)
	{
	case VCCER_900MV 	: rmw_channel( ((SelectedChannel << 10) + 0x144),0x03,0x01); break;
	case VCCER_1030MV : rmw_channel( ((SelectedChannel << 10) + 0x144),0x03,0x02); break;
	case VCCER_1110MV : rmw_channel( ((SelectedChannel << 10) + 0x144),0x03,0x03); break;
		default : rmw_channel( ((SelectedChannel << 10) + 0x144),0x03,0x01); break;
	}		
	
	//Set ODI bandwidth (0x144[7],0x145[7]) 00 is below 2 Gbps,01 = 2 to 5 Gbps,10 = 5 to 10 Gbps, 11 = above 10 Gbps)
	switch (Bandwidth)
	{
	case BELOW_2GBPS 				: 
		rmw_channel( ((SelectedChannel << 10) + 0x144),0x80,0x00); 
		rmw_channel( ((SelectedChannel << 10) + 0x145),0x80,0x00); 
		break;
	case BETWEEN_2GBPS_5GBPS 	: 
		rmw_channel( ((SelectedChannel << 10) + 0x144),0x80,0x00); 
		rmw_channel( ((SelectedChannel << 10) + 0x145),0x80,0x80); 
		break;				
	case BETWEEN_5GBPS_10GBPS 	: 
		rmw_channel( ((SelectedChannel << 10) + 0x144),0x80,0x80); 
		rmw_channel( ((SelectedChannel << 10) + 0x145),0x80,0x00); 
		break;
	case ABOVE_10GBPS 	: 
		rmw_channel( ((SelectedChannel << 10) + 0x144),0x80,0x80); 
		rmw_channel( ((SelectedChannel << 10) + 0x145),0x80,0x80); 
		break;			
		default : 
		rmw_channel( ((SelectedChannel << 10) + 0x144),0x80,0x80); 
		rmw_channel( ((SelectedChannel << 10) + 0x145),0x80,0x80); 
		break;				
	}				

	
	//Set Reserved bits for normal operation 0x144[6:3] = 0x0001
	rmw_channel( ((SelectedChannel << 10) + 0x144),0x78,0x08);		
	
	//Enable ODI SIgnal Processing Block and EODI for normal signal processing mode
	rmw_channel( ((SelectedChannel << 10) + 0x168),0x03,0x03);
	
	
	//  # Offset 0x148
	//  #     [2]   enable the vref
	//  #rmw $channel $slave 0x148 0x02 0x02 
	// Needed?

	//		rmw_channel( ((SelectedChannel << 10) + 0x148),0x02,0x02);

	//  # Offset 0x149
	//  #     [4]   force adp_adapt_control_sel to listen to drpio
	//  #     [6]   set the reset_n
	//  rmw $channel $slave 0x149 0x50 0x50

	//	  rmw_channel( ((SelectedChannel << 10) + 0x149),0x50,0x50);
	
	//Set ODI DFE mode, 0 is off)
	if (DFE_Mode == 0)
	rmw_channel( ((SelectedChannel << 10) + 0x168),0x04,0x00);	
	else
	rmw_channel( ((SelectedChannel << 10) + 0x168),0x04,0x04);
	
	//Set ODI Pattern Counter tresshold (set to maximum, 3'b110 :32K bits)
	rmw_channel( ((SelectedChannel << 10) + 0x168),0xE0,0xC0);
	
	
	
	//Set ODI Signal processing control Mode to 1
	rmw_channel( ((SelectedChannel << 10) + 0x169),0x04,0x04);	
	
	// Set Offset cancellation of ODI to zero (This is done automatically now)
	//		rmw_channel( ((SelectedChannel << 10) + 0x146),0xFF,0x0);	
	//		rmw_channel( ((SelectedChannel << 10) + 0x147),0xFF,0x0);

	
	//		  # Offset 0x171 Configure the Test Mux
	//  #     [4:1] Set the testmux = setting11
	//  rmw $channel $slave 0x171 0x1D 0x16

	rmw_channel( ((SelectedChannel << 10) + 0x171),0x1D,0x16);	

	/**********************************************************************/
	/* Step 2 : Find eye center by sweeping only horizontal							*/
	/**********************************************************************/		
	
	///////////////////////////////////////////////////////////////////////				
	// Go through all horizontal phase steps to determine the eye opening center
	///////////////////////////////////////////////////////////////////////	
	

	//Set ODI vertical phase to zero
	rmw_channel( ((SelectedChannel << 10) + 0x143),0xFC, 0 << 2);
	
	for (x = 1; x <= 128 ; x++)
	{
		
		if (DEBUG_ODI == 1)		
		printf("\nx : %2d",x);
		
		
		
		//Set ODI horizontal phase (after encoding it)
		encoded_phase = enc_horizontal_phase (x); //phases are from 1 to 128.
		if (DEBUG_ODI == 1)	
		printf("    encoded_phase = 0x%2x",encoded_phase);
		
		rmw_channel( ((SelectedChannel << 10) + 0x145),0x7F, encoded_phase);	
		
		
		//Set ODI pattern filter to 2'b00 (pattern filter "0")  {0x119[4],0x144[2]}
		rmw_channel( ((SelectedChannel << 10) + 0x119),0x10,0x0);
		rmw_channel( ((SelectedChannel << 10) + 0x144),0x04,0x0);	

		//Perform capture
		ErrorCount_pat0 = get_odi_errorcount_not_accelerated (SelectedChannel,EyeQInterval);		
		Totalbits_pat0 = get_odi_bitcount_not_accelerated(SelectedChannel);

		//Set ODI pattern filter to 2'b01 (pattern filter "1")  {0x119[4],0x144[2]}
		rmw_channel( ((SelectedChannel << 10) + 0x119),0x10,0x0);
		rmw_channel( ((SelectedChannel << 10) + 0x144),0x04,0x04);
		
		//Take snapshot of the errorcounters
		ErrorCount_pat1 = get_odi_errorcount_not_accelerated (SelectedChannel,EyeQInterval);		
		Totalbits_pat1 = get_odi_bitcount_not_accelerated(SelectedChannel);
		
		//Read the Bitcount of the latest snapshot
		*Totalbits_ODI = Totalbits_pat0 + Totalbits_pat1 ;

		
		
		ErrorCount_Array[x][0] = ErrorCount_pat0 + ErrorCount_pat1;
		
		
		
		if (ErrorCount_Array[x][0] > 0)
		{
			BER_Array[x][0] = (ErrorCount_Array[x][0])/ *Totalbits_ODI;
		}
		else 
		BER_Array[x][0] = 0;  

		if (DEBUG_ODI == 1)	
		{
			printf("\n ErrorCount : %5f   Totalbits : %5f   BER : %e \n", ErrorCount_Array[x][0], *Totalbits_ODI, BER_Array[x][0]);
		}				
		
		
		
	} // for loop x		
	

	///////////////////////////////////////////////////////////////////////				
	// Determine horizontal eye opening
	///////////////////////////////////////////////////////////////////////				
	
	*eye_phase = 0;
	BER_Minimum = 1;
	BER_Minimum_phase = 0;
	
	for (i = 1; i <= 128 ;i++)
	{
		if (BER_Array[i][0] == 0)
		*eye_phase = *eye_phase + 1;
		if (BER_Array[i][0] < BER_Minimum )
		{
			BER_Minimum = BER_Array[i][0];
			BER_Minimum_phase = i;
		}
	}
	
	

	eye = (float) *eye_phase/64;
	
	if (Verbose == 1)
	printf("\nHoriz. Eye opening  : %2d steps  %2f UI", *eye_phase,eye);
	
	
	//usleep(100000000);
	
	start_value = 0;
	start_value_found = 0;
	end_value = 0;
	
	for (i = 2; i <= 128 ;i++)
	{
		//printf("\ni:%2d,BER_Array[i][0] : %e,BER_Array[i-1][0] : %e",i,BER_Array[i][0],BER_Array[i-1][0])	;
		if (BER_Array[i][0] != BER_Array[i-1][0]) 	 
		{
			if ((BER_Array[i][0] == 0) && (start_value_found == 0))
			{
				start_value = i;
				start_value_found = 1; // This is to avoid a glitch generating a new wrong startvalue.
			}
			else if (BER_Array[i-1][0] == 0)
			end_value = i-1;
		}
	}

	if (Verbose == 1)
	{
		printf("\nStart_phase         : %3d",start_value);
		printf("\nEnd_phase           : %3d",end_value);
	}
	if (start_value > end_value )
	end_value = end_value + 128;
	

	//printf("\nend_value   : %2d",end_value);	
	if (*eye_phase == 0)
	*optimum_phase = BER_Minimum_phase ;
	else	
	*optimum_phase = start_value + *eye_phase/2;
	
	//printf("\noptimum phase   : %2d",optimum_phase );
	if (*optimum_phase >= 128 )
	{
		*table_phase_start = *optimum_phase - 32;
		*optimum_phase = *optimum_phase -128;
	}
	else
	{
		*table_phase_start = *optimum_phase -32;
		if (*table_phase_start < 0)
		*table_phase_start = *table_phase_start + 128;
	}
	if (DEBUG_ODI == 1)
	printf("\nOptimum phase       : %3d",*optimum_phase );
	if (DEBUG_ODI == 1)
	printf("\nTable_phase_start   : %3d",*table_phase_start );
	


	
	/**********************************************************************/
	/* Step 3 : Measure 2D eye                          						*/
	/**********************************************************************/		
	
	
	///////////////////////////////////////////////////////////////////////				
	// Go through all horizontal phase steps and all vertical phase steps one by one and measure the BER around +/-32 phases around optimum phase
	///////////////////////////////////////////////////////////////////////	
	
	int tmp = 0;

	
	for (i = 0; i < 64 ; i++)
	{
		///////////////////////////////////////////////////////////////////////				
		// Top Half
		///////////////////////////////////////////////////////////////////////	
		for (j = 31; j > 0 ; j--) 
		{ 
			
			x = *table_phase_start + i;
			if (x > 128)
			x = x - 128; // Modulo 128
			y = j+32;
			
			if (DEBUG_ODI == 1)		
			printf("\nx : %2d y : %2d",x,y);
			
			tmp = tmp+1;
			
			if (Verbose == 1)
			{
				switch (tmp)
				{
				case 410: printf("\n...10%% done..."); break;
				case 820: printf("\n...20%% done..."); break;
				case 1260: printf("\n...30%% done..."); break;
				case 1640: printf("\n...40%% done..."); break;
				case 2050: printf("\n...50%% done..."); break;
				case 2460: printf("\n...60%% done..."); break;
				case 2870: printf("\n...70%% done..."); break;
				case 3280: printf("\n...80%% done..."); break;
				case 3690: printf("\n...90%% done..."); break;

					default : break;
				}	
			}		
			
			//Set ODI vertical phase
			rmw_channel( ((SelectedChannel << 10) + 0x143),0xFC, y << 2);	
			
			
			//Set ODI horizontal phase (after encoding it)
			encoded_phase = enc_horizontal_phase (x); //phases are from 1 to 128.
			if (DEBUG_ODI == 1)	
			printf("    encoded_phase = 0x%2x",encoded_phase);
			
			rmw_channel( ((SelectedChannel << 10) + 0x145),0x7F, encoded_phase);	
			
			
			//Set ODI pattern filter to 2'b01 (pattern filter "1")  {0x119[4],0x144[2]}
			rmw_channel( ((SelectedChannel << 10) + 0x119),0x10,0x0);
			rmw_channel( ((SelectedChannel << 10) + 0x144),0x04,0x4);	

			//Take snapshot of the errorcounters
			ErrorCount_pat_top = get_odi_errorcount_not_accelerated (SelectedChannel,EyeQInterval);		
			
			Totalbits_pat_top = get_odi_bitcount_not_accelerated(SelectedChannel);
			

			if (DFE_Mode == 1)
			{
				//Set ODI pattern filter to 2'b11 (pattern filter "1" for DFE)  {0x119[4],0x144[2]}
				rmw_channel( ((SelectedChannel << 10) + 0x119),0x10,0x10);
				rmw_channel( ((SelectedChannel << 10) + 0x144),0x04,0x04);	
				ErrorCount_pat_top_dfe = get_odi_errorcount_not_accelerated (SelectedChannel,EyeQInterval);
				Totalbits_pat_top_dfe = get_odi_bitcount_not_accelerated(SelectedChannel);
			}

			if (DFE_Mode == 0)	
			{
				Totalbits_ODI_top = Totalbits_pat_top;
			}
			else
			{
				Totalbits_ODI_top = Totalbits_pat_top + Totalbits_pat_top_dfe;
			}

			if (DFE_Mode == 0)		
			{
				ErrorCount_Array[x][y] = ErrorCount_pat_top ;
			}
			else
			{
				ErrorCount_Array[x][y] = ErrorCount_pat_top + ErrorCount_pat_top_dfe ;
			}
			
			
			if (ErrorCount_Array[x][y] > 0)
			{
				BER_Array[x][y] = (ErrorCount_Array[x][y]) / Totalbits_ODI_top;
			}
			else 
			{
				BER_Array[x][y] = 0;  
			}

			if (DEBUG_ODI == 1)	
			{
				printf("\n ErrorCount : %5f   Totalbits top : %5f   BER : %e \n", ErrorCount_Array[x][y], Totalbits_ODI_top, BER_Array[x][y]);
			}		
			
		} // Top Half
		

		///////////////////////////////////////////////////////////////////////				
		// Bottom Half
		///////////////////////////////////////////////////////////////////////	
		for (j = 0; j < 32 ; j++) 
		{ 
			
			x = *table_phase_start + i;
			if (x > 128)
			x = x - 128; // Modulo 128
			y = 32-j;
			
			if (DEBUG_ODI == 1)		
			printf("\nx : %2d y : %2d",x,y);
			
			tmp = tmp+1;

			if (Verbose == 1)
			{			
				switch (tmp)
				{
				case 410: printf("\n...10%% done..."); break;
				case 820: printf("\n...20%% done..."); break;
				case 1260: printf("\n...30%% done..."); break;
				case 1640: printf("\n...40%% done..."); break;
				case 2050: printf("\n...50%% done..."); break;
				case 2460: printf("\n...60%% done..."); break;
				case 2870: printf("\n...70%% done..."); break;
				case 3280: printf("\n...80%% done..."); break;
				case 3690: printf("\n...90%% done..."); break;

					default : break;
				}			
			}			
			//Set ODI vertical phase
			rmw_channel( ((SelectedChannel << 10) + 0x143),0xFC, y << 2);	
			
			
			//Set ODI horizontal phase (after encoding it)
			encoded_phase = enc_horizontal_phase (x); //phases are from 1 to 128.
			if (DEBUG_ODI == 1)	
			printf("    encoded_phase = 0x%2x",encoded_phase);
			
			rmw_channel( ((SelectedChannel << 10) + 0x145),0x7F, encoded_phase);	
			
			
			//Set ODI pattern filter to 2'b00   {0x119[4],0x144[2]}
			rmw_channel( ((SelectedChannel << 10) + 0x119),0x10,0x0);
			rmw_channel( ((SelectedChannel << 10) + 0x144),0x04,0x0);	

			//Take snapshot of the errorcounters
			ErrorCount_pat_bot = get_odi_errorcount_not_accelerated (SelectedChannel,EyeQInterval);		
			Totalbits_pat_bot = get_odi_bitcount_not_accelerated(SelectedChannel);
			
			if (DFE_Mode == 1)
			{
				//Set ODI pattern filter to 2'b10   {0x119[4],0x144[2]}
				rmw_channel( ((SelectedChannel << 10) + 0x119),0x10,0x10);
				rmw_channel( ((SelectedChannel << 10) + 0x144),0x04,0x00);	
				ErrorCount_pat_bot_dfe = get_odi_errorcount_not_accelerated (SelectedChannel,EyeQInterval);
				Totalbits_pat_bot_dfe = get_odi_bitcount_not_accelerated(SelectedChannel);
				
			}


			if (DFE_Mode == 0)	
			{
				Totalbits_ODI_bot = Totalbits_pat_bot;
			}
			else
			{
				Totalbits_ODI_bot = Totalbits_pat_bot + Totalbits_pat_bot_dfe;
			}
			
			

			if (DFE_Mode == 0)		
			{
				ErrorCount_Array[x][y] = ErrorCount_pat_bot ;
			}
			else
			{
				ErrorCount_Array[x][y] = ErrorCount_pat_bot + ErrorCount_pat_bot_dfe ;
			}
			
			if (ErrorCount_Array[x][y] > 0)
			{
				BER_Array[x][y] = (ErrorCount_Array[x][y]) / Totalbits_ODI_bot;
			}
			else 
			{
				BER_Array[x][y] = 0;  
			}

			if (DEBUG_ODI == 1)	
			{
				printf("\n ErrorCount : %5f   Totalbits bottom : %5f   BER : %e \n", ErrorCount_Array[x][y], Totalbits_ODI_bot, BER_Array[x][y]);
			}		
			
		} // Bottom Half
		
		
		*Totalbits_ODI	= Totalbits_ODI_top + Totalbits_ODI_bot;
		
		
		
		
		
		
	} // for loop x


	

	///////////////////////////////////////////////////////////////////////				
	// Find Vertical Eye Opening using optimum horizontal phase
	///////////////////////////////////////////////////////////////////////					
	
	*veye = 0;
	
	for (i = 32; i <64 ;i++)
	{
		if (BER_Array[*optimum_phase][i] == 0)
		*veye = *veye + 1;
	}	
	for (i = 0; i <32 ;i++)
	{
		if (BER_Array[*optimum_phase][i] == 0)
		*veye = *veye + 1;
	}		  
	
	*veye_top = *veye/2 + 10  + 32;
	*veye_bottom = *veye/2 + 10;
	if (Verbose == 1)
	{
		printf("\nveye at optimum phase : %2d steps",*veye);
		printf("\n");	
	}
	

	/**********************************************************************/
	/* Step 4 : Disable ODI																 */
	/**********************************************************************/

	//Disable ODI
	rmw_channel( ((SelectedChannel << 10) + 0x143),0x03,0x03);
	
	return eye;
}



