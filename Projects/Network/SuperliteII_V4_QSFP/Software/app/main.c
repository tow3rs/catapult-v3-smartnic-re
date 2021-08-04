#include <stdio.h>
#include "system.h"
#include "string.h"
#include "altera_avalon_pio_regs.h"
#include <unistd.h>
#include "io.h"
#include "altera_avalon_jtag_uart_regs.h"
#include <ctype.h>
#include <time.h>
#include <math.h>
#include "sys/alt_timestamp.h"
#include "alt_types.h"
#include <fcntl.h>
#include "altera_avalon_i2c.h"
#include "sys/alt_stdio.h"

///////////////////////////////////////////////////////////////////////
// Global parameters.h
///////////////////////////////////////////////////////////////////////

#include "parameters.h"

///////////////////////////////////////////////////////////////////////
// Local parameters
///////////////////////////////////////////////////////////////////////

#define NUMBER_OF_LINKS 1
#define READ_LENGTH 0x420 // This should match the RTL implementation
#define IDLE_LENGTH 7	  // This should match the RTL implementation

#define DEBUG 0


///////////////////////////////////////////////////////////////////////
// input_functions.c
///////////////////////////////////////////////////////////////////////

char input_char(void);
int input_number(void);
int input_byte(void);
int input_double(void);
int input_word(void);


///////////////////////////////////////////////////////////////////////
// PMA_functions.c
///////////////////////////////////////////////////////////////////////

void rmw_channel(int offset, int bitmask, int newval);
int rd_channel(int offset);
void rmw_pll(int offset, int bitmask, int newval);
int rd_pll(int offset);
int encode_pretap2(int pretap2);
int decode_pretap2(int pretap2_encoded);
int encode_pretap1(int pretap1);
int decode_pretap1(int pretap1_encoded);
int encode_posttap1(int posttap1);
int decode_posttap1(int posttap1_encoded);
int encode_posttap2(int posttap2);
int decode_posttap2(int posttap2_encoded);
int encode_dcgain(int dcgain);
int decode_dcgain(int dcgain_encoded);
void show_pma_settings(int dfe_enable[NUMBER_OF_LANES]);


///////////////////////////////////////////////////////////////////////
// channel_functions.c
///////////////////////////////////////////////////////////////////////

int Read_Channel_Reg(int SelectedChannel);
int Read_ErrorCount_L_Reg(int SelectedChannel);
int Read_ErrorCount_H_Reg(int SelectedChannel);
int Read_FEC_corr_errorcount_Reg(int SelectedChannel);
int Read_FEC_uncorr_errocount_Reg(int SelectedChannel);


///////////////////////////////////////////////////////////////////////
// ODI_functions.c
///////////////////////////////////////////////////////////////////////


int enc_horizontal_phase(int phase);
float get_odi_errorcount(int SelectedChannel, int EyeQInterval);
float get_odi_bitcount(int SelectedChannel);
void print_2D_eye(float BER_Array[][DimB], float ErrorCount_Array[][DimB], int *veye_top, int *veye_bottom, int *table_phase_start);
void print_1D_eye(float BER_Array[][DimB], int *table_phase_start);
float do_eye_measurement(int SelectedChannel, int EyeQInterval, int Bandwidth, int VCCER_Level, int DFE_Mode
, float BER_Array[][DimB], float ErrorCount_Array[][DimB], int *veye, int *veye_top, int *veye_bottom, int *table_phase_start
, int *eye_phase, int *optimum_phase, float *Totalbits_ODI, int Verbose);
float do_eye_measurement_no_acceleration(int SelectedChannel, int EyeQInterval, int Bandwidth, int VCCER_Level, int DFE_Mode
, float BER_Array[][DimB], float ErrorCount_Array[][DimB], int *veye, int *veye_top, int *veye_bottom, int *table_phase_start
, int *eye_phase, int *optimum_phase, float *Totalbits_ODI, int Verbose);

///////////////////////////////////////////////////////////////////////
// Other functions
///////////////////////////////////////////////////////////////////////

void print_alarm(int value, int ok_value);

///////////////////////////////////////////////////////////////////////
// DFE_functions.c
///////////////////////////////////////////////////////////////////////

void dfe_continous_enable(int channel, int number_of_taps, int freeze_mode);
void dfe_disable(int channel);


///////////////////////////////////////////////////////////////////////
// calibration_functions.c
///////////////////////////////////////////////////////////////////////

void recalibrate_channel(int channel, int rate_switch);
void recalibrate_rx(int channel, int rate_switch);
void recalibrate_tx(int channel);
void recalibrate_pll(int pll_type);

char rx_char;
char c;
int Control_Reg;
int Control2_Reg;
int RefClock_Reg;
int DataClock_Reg;
int DataClock_Out_Reg;

int Bitrate;
int Linerate;
float Bitrate_temp;
float Linerate_temp;
int Userdatarate;
float Userdatarate_temp;
int Channel_Reg;
int Counter_1ms_Reg;
float BER;
float Totalbits;
float Efficiency;
int Hours;
int Minutes;
int Seconds;
int temp;
int SelectedChannel;

char qsfp_cable_manufacturer [17];
char qsfp_cable_part_number [17];
char qsfp_cable_serial_number [17];

int Locked[NUMBER_OF_LINKS];
int ChannelOK[NUMBER_OF_LINKS];
int WordAligned[NUMBER_OF_LINKS];
int LaneAligned[NUMBER_OF_LINKS];
int Powerdown[NUMBER_OF_LINKS];
int PLL_Locked[NUMBER_OF_LINKS];
int Rx_FreqLocked[NUMBER_OF_LINKS];
float ErrorCount;
int ErrorCount_Reg;

int tx_vodctrl[NUMBER_OF_LANES];
int tx_pretap_1[NUMBER_OF_LANES];
int tx_pretap_2[NUMBER_OF_LANES];
int tx_posttap_1[NUMBER_OF_LANES];
int tx_posttap_2[NUMBER_OF_LANES];
int rx_eqdcgain[NUMBER_OF_LANES];
int rx_eqctrl[NUMBER_OF_LANES];
int vga_gain[NUMBER_OF_LANES];
int Lane_identifier[NUMBER_OF_LANES];

int i;
int j;
int t;
int k;
int d;
char c;
int TimeInterval;

int Reg_data;
int Ravail;
int Serial_Loop[NUMBER_OF_LANES];
int NOK;


//ODI Variables start
float ErrorCount_Array[DimA][DimB];
float BER_Array[DimA][DimB];
int table_phase_start;
int veye_top;
int veye_bottom;
float eye;
int eye_phase;
int optimum_phase;
int veye;
float Totalbits_ODI;
int EyeQInterval;
int VCCER_Level;
int Bandwidth;
int DFE_Mode;
//ODI Variables stop


//dfe variables start
int dfe_enable[NUMBER_OF_LANES];
//dfe Variables stop

int Temperature;
int Error_Deskew;
int Error_Decoder;
int Latency_Max[NUMBER_OF_LINKS];
int Latency_Min[NUMBER_OF_LINKS];
int Latency_Max_Reg[NUMBER_OF_LINKS];
int Latency_Min_Reg[NUMBER_OF_LINKS];
float latency_max_measure_temp[NUMBER_OF_LINKS];
float latency_min_measure_temp[NUMBER_OF_LINKS];
int dump_register_before[600];
int dump_register_after[600];

int Latency_Memory[RESET_CYCLES];
int Latency_Minimum;
int Latency_Maximum;
int hist[256];
float Ratio;
int LinkUp[NUMBER_OF_LINKS];
int XOFF_Received[NUMBER_OF_LINKS];
int XOFF;
int HWVersion_Day;
int HWVersion_Month;
int HWVersion_Year;
int HWSubversion;
float ClockRatio[NUMBER_OF_LINKS];
int throttle_datarate[NUMBER_OF_LINKS];
int ppm_difference[NUMBER_OF_LINKS];
int random_number;
int fd;
int flags;
int exit_loop;
int selected_profile;
int qsfp_cable_plugged;
int use_odi_acceleration;
int ref_clock_multiplier;
int rcfg_busy;

///////////////////////////////////////////////////////////////////////
// Randomize functions
///////////////////////////////////////////////////////////////////////

void srand(unsigned int seed);
int rand(void);

///////////////////////////////////////////////////////////////////////
// I2C functions
///////////////////////////////////////////////////////////////////////
int i2c_set_retimer_rate(int rate);
int i2c_get_cable_info(char *qsfp_cable_manufacturer , char *qsfp_cable_part_number , char *qsfp_cable_serial_number);

void toogle_loopback()
{
	printf("\n    Current Status of Serial Loopback :\n");
	printf("    ===================================\n");
	printf("    Lane              |");
	for (i = 0; i < NUMBER_OF_LANES; i++)
	{
		printf("%2X|", i);
	}
	printf("\n");
	printf("                      |");
	for (i = 0; i < NUMBER_OF_LANES; i++)
	{
		printf("--|");
	}
	printf("\n");

	printf("    Serial Loop       |");
	for (i = 0; i < NUMBER_OF_LANES; i++)
	{
		printf("%2d|", Serial_Loop[i]);
	}
	printf("\n");

	do
	{
		printf("\n");

		printf("    Toggling Serial Loopback               \n");
		printf("    =========================              \n");
		printf("    Toggle Loopback on Lane  0    choose  '0' \n");
		printf("    Toggle Loopback on Lane  1    choose  '1' \n");
		printf("    Toggle Loopback on Lane  2    choose  '2' \n");
		printf("    Toggle Loopback on Lane  3    choose  '3' \n\n");
		printf("    Enable Loopback on all Lanes  choose  'E' \n");
		printf("    Disable Loopback on all Lanes choose  'D' \n\n");
		printf("    No Change                     choose  'X' \n\n");
		printf("    Choice :");

		temp = 0xffffffff;

		rx_char   = input_char();
		switch (rx_char)
		{
		case '0':
			temp =  0;
			if (Serial_Loop[0] == 1) Serial_Loop[0] = 0;
			else Serial_Loop[0] = 1;
			break;
			
		case '1':
			temp =  1;
			if (Serial_Loop[1] == 1) Serial_Loop[1] = 0;
			else Serial_Loop[1] = 1;
			break;
			
		case '2':
			temp =  2;
			if (Serial_Loop[2] == 1) Serial_Loop[2] = 0;
			else Serial_Loop[2] = 1;
			break;
			
		case '3':
			temp =  3;
			if (Serial_Loop[3] == 1) Serial_Loop[3] = 0;
			else Serial_Loop[3] = 1;
			break;
			
		case 'e':
		case 'E':
			temp =  12;
			for (i = 0; i < NUMBER_OF_LANES; i++)
			{
				Serial_Loop[i] = 1;
			}
			break;

		case 'd':
		case 'D':
			temp =  16;
			for (i = 0; i < NUMBER_OF_LANES; i++)
			{
				Serial_Loop[i] = 0;
			}
			break;

		case 'x':
		case 'X':
			temp =  128;
			break;
			
			default :
			break;
		}
	}
	while (temp == 0xffffffff);

	if(temp != 128)
	{
		Control2_Reg = (Control2_Reg & (0xFFFE)) | (Serial_Loop[0]);
		Control2_Reg = (Control2_Reg & (0xFFFD)) | (Serial_Loop[1] << 1);
		Control2_Reg = (Control2_Reg & (0xFFFB)) | (Serial_Loop[2] << 2);
		Control2_Reg = (Control2_Reg & (0xFFF7)) | (Serial_Loop[3] << 3);

		Control2_Reg = (Control2_Reg & 0xFFCF) | ((selected_profile+1) << 4);
		IOWR_ALTERA_AVALON_PIO_DATA(CONTROL2_REG_BASE, Control2_Reg);	

		Control_Reg = Control_Reg | (0x8000);
		IOWR_ALTERA_AVALON_PIO_DATA(CONTROL_REG_BASE, Control_Reg);
		usleep(10);

		Control_Reg = Control_Reg & (0x7FFF);
		IOWR_ALTERA_AVALON_PIO_DATA(CONTROL_REG_BASE, Control_Reg);

		printf("\nChanged serial loop and Link Resetted.\n\n\n");
	}
}


void set_bitrate(int br)
{
	selected_profile = br;
	int status = 0;	

	// Reset PLL & XCVR
	Control_Reg = Control_Reg | (0x8000);
	IOWR_ALTERA_AVALON_PIO_DATA(CONTROL_REG_BASE,Control_Reg);
	
	// I2C set retimer bitrate
	status = i2c_set_retimer_rate(selected_profile);
	if(status != 0)
	{
		printf(COLOR_ALARM "\nFailed to set retimer bitrate" COLOR_RESET);
	}
	
	// Reconfigure ATX PLL
	do
	{
		rcfg_busy = 0x0001 & rd_pll(0x341);
	} while (rcfg_busy == 1);	

	rmw_pll(0x340, 0x80 | 0x7, 0x80 | selected_profile); // Write new profile and kick off the streamer	

	do
	{
		rcfg_busy = 0x0001 & rd_pll(0x341);
	} while (rcfg_busy == 1);
	
	
	// Reconfigure Transceivers
	do
	{
		rcfg_busy = 0x0001 & rd_channel(0x341);
	} while (rcfg_busy == 1);

	rmw_channel(0x340, 0xC0 | 0x7, 0xC0 | selected_profile); 	// Write new profile, enable broadcast and kick off the streamer

	do
	{
		rcfg_busy = 0x0001 & rd_channel(0x341); // Read rcfg_busy of channel 0
	} while (rcfg_busy == 1);
	
	// Release reset
	Control_Reg = Control_Reg & (0x7FFF);
	IOWR_ALTERA_AVALON_PIO_DATA(CONTROL_REG_BASE, Control_Reg);
	
	// Recalibrate PLL
	recalibrate_pll(ATX_PLL);
	
	// Recalibrate Transceivers
	for (j = 0; j < NUMBER_OF_LANES; j++)
	{
		recalibrate_channel(j, RATE_SWITCH);
	}

	Control2_Reg = (Control2_Reg & 0xFFCF) | ((selected_profile+1) << 4);
	IOWR_ALTERA_AVALON_PIO_DATA(CONTROL2_REG_BASE, Control2_Reg);
}

void choose_bitrate()
{
	do
	{
		if (selected_profile == 0)
		{
			printf("\n\n    Current Bitrate:   10.3125 Gbps \n\n");
		}
		else if (selected_profile == 1)
		{
			printf("\n\n    Current Bitrate:   10.9375 Gbps \n\n");
		}
		else
		{
			printf("\n\n    Current Bitrate:   12.5000 Gbps \n\n");
		}

		printf("    =========================              \n");
		printf("    Set new Bitrate               \n");
		printf("    =========================              \n");
		printf("    10.3125 Gbps   choose '1' \n");
		printf("    10.9375 Gbps   choose '2' \n");
		printf("    12.5000 Gbps   choose '3' \n\n");
		printf("    No Change      choose '0' \n\n");
		printf("    Choice :");

		temp = 0xffffffff;

		rx_char = input_char();
		switch (rx_char)
		{

		case '1':
			temp =  1;
			set_bitrate(0);
			break;

		case '2':
			temp =  2;
			set_bitrate(1);
			break;

		case '3':
			temp =  3;
			set_bitrate(2);
			break;

		case '0':
			temp = 0;
			break;

		default :
			break;
		}
	}
	while (temp == 0xffffffff);
}


void transceiver_parameters()
{
	//Read settings first (as they can have been set differnetly in e.g. Transceiver toolkit or through scripts

	tx_vodctrl[SelectedChannel] = rd_channel((SelectedChannel << 10) + 0x109) & 0x1F;
	tx_pretap_2[SelectedChannel] = rd_channel((SelectedChannel << 10) + 0x108) & 0x17;
	tx_pretap_1[SelectedChannel] = rd_channel((SelectedChannel << 10) + 0x107) & 0x3F;
	tx_posttap_1[SelectedChannel] = rd_channel((SelectedChannel << 10) + 0x105) & 0x7F;
	tx_posttap_2[SelectedChannel] = rd_channel((SelectedChannel << 10) + 0x106) & 0x2F;
	rx_eqctrl[SelectedChannel] = (rd_channel((SelectedChannel << 10) + 0x167) & 0x3E) >> 1;
	rx_eqdcgain[SelectedChannel] = ((rd_channel((SelectedChannel << 10) + 0x11C) & 0x0F) << 8) + (rd_channel((SelectedChannel << 10) + 0x11A) & 0xFF);
	vga_gain[SelectedChannel] = (rd_channel((SelectedChannel << 10) + 0x160) & 0xE) >> 1;

	printf("\n4. Transceiver PMA Settings of Channel %1d\n", SelectedChannel);
	printf("    VOD Level             : %2d\n", tx_vodctrl[SelectedChannel]);
	printf("    Pre Tap 2 Level       : %2d\n", decode_pretap2(tx_pretap_2[SelectedChannel]));
	printf("    Pre Tap 1 Level       : %2d\n", decode_pretap1(tx_pretap_1[SelectedChannel]));
	printf("    Post Tap 1 Level      : %2d\n", decode_posttap1(tx_posttap_1[SelectedChannel]));
	printf("    Post Tap 2 Level      : %2d\n", decode_posttap2(tx_posttap_2[SelectedChannel]));
	printf("    CTLE DC Gain          : %2d\n", decode_dcgain(rx_eqdcgain[SelectedChannel]));
	printf("    CTLE AC Gain          : %2d\n", rx_eqctrl[SelectedChannel]);
	printf("    VGA Gain              : %2d\n", vga_gain[SelectedChannel]);

	printf("\n");

	printf("    New VOD Level Channel %2d               \n", SelectedChannel);
	printf("    ==================================              \n");
	printf("    Provide number from 12-31 : ");
	do
	{
		temp = input_double();
	}
	while ((temp < 12) || (temp > 31));

	printf("%2d", temp);
	tx_vodctrl[SelectedChannel] = temp;

	printf("\n\n");


	printf("    New Pre Tap 2 Level Channel %2d               \n", SelectedChannel);
	printf("    ==================================               \n");
	printf("    Provide number from 0-7 : ");
	do
	{
		temp = input_number();
	}
	while (temp > 7);
	printf("%2d", temp);
	printf("\n\n");

	printf("    New Pre Tap 2 Polarity Channel %2d               \n", SelectedChannel);
	printf("    ==================================               \n");
	printf("    Provide either + or -   : ");
	rx_char = input_char();

	if (rx_char == '-') tx_pretap_2[SelectedChannel] = 0x10 + temp;
	else tx_pretap_2[SelectedChannel] = temp;

	printf("\n\n");


	printf("    New Pre Tap 1 Level Channel %2d               \n", SelectedChannel);
	printf("    ==================================                \n");
	printf("    Provide number from 0-12 : ");
	do
	{
		temp = input_double();
	}
	while ((temp < 0) || (temp > 12));
	printf("%2d", temp);
	printf("\n\n");
	printf("    New Pre Tap 1 Polarity Channel %2d               \n", SelectedChannel);
	printf("    ==================================                \n");
	printf("    Provide either + or -    : ");
	rx_char = input_char();


	if (rx_char == '-') tx_pretap_1[SelectedChannel] = 0x20 + temp;
	else tx_pretap_1[SelectedChannel] = temp;

	printf("\n\n");


	printf("    New Post Tap 1 Level Channel %2d               \n", SelectedChannel);
	printf("    ==================================              \n");
	printf("    Provide number from 0-25 : ");
	do
	{
		temp = input_double();
	}
	while ((temp < 0) || (temp > 25));
	printf("%2d", temp);
	printf("\n\n");

	printf("    New Post Tap 1 Polarity Channel %2d               \n", SelectedChannel);
	printf("    ==================================              \n");
	printf("    Provide either + or -    : ");
	rx_char = input_char();


	if (rx_char == '-') tx_posttap_1[SelectedChannel] = 0x40 + temp;
	else tx_posttap_1[SelectedChannel] = temp;

	printf("\n\n");


	printf("    New Post Tap 2 Level Channel %2d               \n", SelectedChannel);
	printf("    ==================================                \n");
	printf("    Provide number from 0-12 : ");
	do
	{
		temp = input_double();
	}
	while ((temp < 0) || (temp > 12));
	printf("%2d", temp);
	printf("\n\n");

	printf("    New Post Tap 2 Polarity Channel %2d               \n", SelectedChannel);
	printf("    ==================================                \n");
	printf("    Provide either + or -    : ");
	rx_char = input_char();


	if (rx_char == '-') tx_posttap_2[SelectedChannel] = 0x20 + temp;
	else tx_posttap_2[SelectedChannel] = temp;

	printf("\n\n");

	printf("    New CTLE AC Gain Channel %2d               \n", SelectedChannel);
	printf("    ==================================               \n");
	printf("    Provide number from 0-31 : ");
	do
	{
		temp = input_double();
	}
	while ((temp < 0) || (temp > 31));
	printf("%2d", temp);
	printf("\n\n");

	rx_eqctrl[SelectedChannel] = temp;

	printf("\n");


	printf("    New CTLE DC Gain Channel %2d               \n", SelectedChannel);
	printf("    ==================================               \n");
	printf("    Provide number from 0-4 : ");
	do
	{
		temp = input_number();
	}
	while (temp > 4);
	printf("%2d", temp);
	printf("\n\n");

	rx_eqdcgain[SelectedChannel] = encode_dcgain(temp);

	printf("\n");


	printf("    New VGA Gain Channel %2d               \n", SelectedChannel);
	printf("    ==================================               \n");
	printf("    Provide number from 0-7 : ");
	do
	{
		temp = input_number();
	}
	while ((temp < 0) || (temp > 7));
	printf("%2d", temp);
	printf("\n\n");

	vga_gain[SelectedChannel] = temp;


	printf("\n");

	// Debug Purposes
	printf("    tx_vodctrl   = %d               \n", tx_vodctrl[SelectedChannel]);
	printf("    tx_pretap_2  = %x              \n", tx_pretap_1[SelectedChannel]);
	printf("    tx_pretap_1  = %x              \n", tx_pretap_1[SelectedChannel]);
	printf("    tx_posttap_1 = %x              \n", tx_posttap_1[SelectedChannel]);
	printf("    tx_posttap_2 = %x              \n", tx_posttap_2[SelectedChannel]);
	printf("    rx_eqdcgain  = %x              \n", rx_eqdcgain[SelectedChannel]);
	printf("    rx_eqctrl    = %d              \n", rx_eqctrl[SelectedChannel]);
	printf("    vga_gain     = %d              \n", vga_gain[SelectedChannel]);

	//Set VOD 0x109 bit [4:0]
	rmw_channel(((SelectedChannel << 10) + 0x109), 0x1F, tx_vodctrl[SelectedChannel]);

	//Set PRETAP2 0x108 bit [4] and [2:0]
	rmw_channel(((SelectedChannel << 10) + 0x108), 0x17, tx_pretap_2[SelectedChannel]);

	//Set PRETAP1 0x107 bit [5:0]
	rmw_channel(((SelectedChannel << 10) + 0x107), 0x3F, tx_pretap_1[SelectedChannel]);

	//Set POSTTAP1 0x105 bit [6:0]
	rmw_channel(((SelectedChannel << 10) + 0x105), 0x7F, tx_posttap_1[SelectedChannel]);

	//Set POSTTAP2 0x106 bit [5] and [3:0]
	rmw_channel(((SelectedChannel << 10) + 0x106), 0x2F, tx_posttap_2[SelectedChannel]);

	//Set AC Gain 0x167 bit [5:1]
	rmw_channel(((SelectedChannel << 10) + 0x167), 0x3E, rx_eqctrl[SelectedChannel] << 1);

	//Set DC Gain 0x11C bit [3:0] 0x11A bit [7:0]
	rmw_channel(((SelectedChannel << 10) + 0x11C), 0x0F, rx_eqdcgain[SelectedChannel] >> 8);
	rmw_channel(((SelectedChannel << 10) + 0x11A), 0xFF, rx_eqdcgain[SelectedChannel]);

	//Set VGA Gain 0x160 bit [3:1]
	rmw_channel(((SelectedChannel << 10) + 0x160), 0xE, vga_gain[SelectedChannel] << 1);
	
	printf("\nTransceiver PMA parameters of Channel %1d updated\n\n", SelectedChannel);
}

int main()
{

	srand(time(NULL));   // Initialization, should only be called once.

	for (j = 0; j < NUMBER_OF_LANES; j++)
	{
		tx_vodctrl[j] = 26;
		tx_pretap_2[j] = PRE_TAP2_0;
		tx_pretap_1[j] = PRE_TAP1_4N;
		tx_posttap_1[j] = POST_TAP1_1N;
		tx_posttap_2[j] = POST_TAP2_0;
		rx_eqdcgain[j] = EQ_GAIN_0;
		rx_eqctrl[j] = EQ_CTRL_8;
		vga_gain[j] = RADP_VGA_SEL_4;

		//Set VOD 0x109 bit [4:0]
		rmw_channel(((j << 10) + 0x109), 0x1F, tx_vodctrl[j]);

		//Set PRETAP2 0x108 bit [4] and [2:0]
		rmw_channel(((j << 10) + 0x108), 0x17, tx_pretap_2[j]);

		//Set PRETAP1 0x107 bit [5:0]
		rmw_channel(((j << 10) + 0x107), 0x3F, tx_pretap_1[j]);

		//Set POSTTAP1 0x105 bit [6:0]
		rmw_channel(((j << 10) + 0x105), 0x7F, tx_posttap_1[j]);

		//Set POSTTAP2 0x106 bit [5] and [3:0]
		rmw_channel(((j << 10) + 0x106), 0x2F, tx_posttap_2[j]);

		//Set AC Gain 0x167 bit [5:1]
		rmw_channel(((j << 10) + 0x167), 0x3E, rx_eqctrl[j] << 1);

		//Set DC Gain 0x11C bit [3:0] 0x11A bit [7:0]
		rmw_channel(((j << 10) + 0x11C), 0x0F, rx_eqdcgain[j] >> 8);
		rmw_channel(((j << 10) + 0x11A), 0xFF, rx_eqdcgain[j]);

		//Set VGA Gain 0x160 bit [3:1]
		rmw_channel(((j << 10) + 0x160), 0xE, vga_gain[j] << 1);

		Serial_Loop[j] = 0;

		dfe_enable[j] = 0;
	}

	SelectedChannel = 0; // Default Selected Channels is channel 0

	Control_Reg = 0x0000;
	IOWR_ALTERA_AVALON_PIO_DATA(CONTROL_REG_BASE, Control_Reg);
	
	Control2_Reg = 0x0000;    //Disable serial loopback control
	IOWR_ALTERA_AVALON_PIO_DATA(CONTROL2_REG_BASE, Control2_Reg);

	XOFF = 0;
	use_odi_acceleration = rd_channel(0x214) & 0x1;
	
	set_bitrate(2);
	
	do
	{
		Counter_1ms_Reg = IORD_ALTERA_AVALON_PIO_DATA(COUNTER_1MS_REG_BASE); // NUMBER_OF_MS_PER_SECOND;
	}
	while (Counter_1ms_Reg < 1000);

	EyeQInterval = 1; // Set to 1 ms as default.

	HWVersion_Day = (IORD_ALTERA_AVALON_PIO_DATA(VERSION_BASE) & (0xFF000000)) >> 24;
	HWVersion_Month = (IORD_ALTERA_AVALON_PIO_DATA(VERSION_BASE) & (0x00FF0000)) >> 16;
	HWVersion_Year = (IORD_ALTERA_AVALON_PIO_DATA(VERSION_BASE) & (0x0000FF00)) >> 8;
	HWSubversion = IORD_ALTERA_AVALON_PIO_DATA(VERSION_BASE) & (0x000000FF);

	Powerdown[0] = 0;

	/**********************************************************************/
	/*  Main Program Loop                                                 */
	/**********************************************************************/
	while (1)
	{
		Channel_Reg = IORD_ALTERA_AVALON_PIO_DATA(CHANNEL_REG_BASE);

		RefClock_Reg   = IORD_ALTERA_AVALON_PIO_DATA(BITRATE_REG_BASE);
		DataClock_Reg = IORD_ALTERA_AVALON_PIO_DATA(DATACLOCK_REG_BASE);
		DataClock_Out_Reg = IORD_ALTERA_AVALON_PIO_DATA(DATAOUT_CLOCK_REG_BASE);
		Latency_Max_Reg[0] = IORD_ALTERA_AVALON_PIO_DATA(LATENCY_MAX_REG_BASE);
		Latency_Min_Reg[0] = IORD_ALTERA_AVALON_PIO_DATA(LATENCY_MIN_REG_BASE);
		Lane_identifier[0] = IORD_ALTERA_AVALON_PIO_DATA(LANE_IDENTIFIER_0_BASE);
		Lane_identifier[1] = IORD_ALTERA_AVALON_PIO_DATA(LANE_IDENTIFIER_1_BASE);
		Lane_identifier[2] = IORD_ALTERA_AVALON_PIO_DATA(LANE_IDENTIFIER_2_BASE);
		Lane_identifier[3] = IORD_ALTERA_AVALON_PIO_DATA(LANE_IDENTIFIER_3_BASE);		
		qsfp_cable_plugged = (Channel_Reg >> 18) & 0x1;
		
		Ratio = ((float)(READ_LENGTH - IDLE_LENGTH)) / (READ_LENGTH);
		ref_clock_multiplier = (Channel_Reg >> 10) & 0xFF;	
		
		Linerate_temp =  ((float)DataClock_Reg * ref_clock_multiplier ) / (1000000);			
		Bitrate_temp =  (Linerate_temp * NUMBER_OF_LANES);		
		Userdatarate_temp = ((float)DataClock_Out_Reg * 64 * NUMBER_OF_LANES) / (1000000);

		latency_max_measure_temp[0] = ((float)Latency_Max_Reg[0] * 1000000000) / ((float)DataClock_Reg);
		latency_min_measure_temp[0] = ((float)Latency_Min_Reg[0] * 1000000000) / ((float)DataClock_Reg);

		Bitrate = (Bitrate_temp); // Convert the floats to integer numbers
		Linerate = (Linerate_temp); // Convert the floats to integer numbers
		Userdatarate = (Userdatarate_temp); // Convert the floats to integer numbers
		Latency_Max[0] = (latency_max_measure_temp[0]); // Convert the floats to integer numbers
		Latency_Min[0] = (latency_min_measure_temp[0]); // Convert the floats to integer numbers

		Efficiency  = (Userdatarate * 100) / (float)(Linerate * NUMBER_OF_LANES);
		Counter_1ms_Reg     = IORD_ALTERA_AVALON_PIO_DATA(COUNTER_1MS_REG_BASE);
		ErrorCount_Reg   =  ((0x0000FFFF) & IORD_ALTERA_AVALON_PIO_DATA(BITERRORCOUNT_REG_BASE));       // Mask the upper 16 bits as they will also be read and could contain a value
		ErrorCount = (float)(ErrorCount_Reg);
		Temperature = IORD_ALTERA_AVALON_PIO_DATA(TEMPERATURE_REG_BASE);

		for (i = 0; i < NUMBER_OF_LINKS; i++)
		{
			Locked[i] = 0x0001 & (Channel_Reg >> 9);
			PLL_Locked[i] = 0x0001 & (Channel_Reg >> 8);
			LaneAligned[i] = 0x0001 & (Channel_Reg >>  7);
			Rx_FreqLocked[i] = 0x0001 & (Channel_Reg >> 6);
			LinkUp[i] = 0x0001 & (Channel_Reg >> 5);
			XOFF_Received[i] = 0x0001 & (Channel_Reg >>  4);
			Error_Deskew = 0x0001 & (Channel_Reg >>  2);
			Error_Decoder = 0x0001 & (Channel_Reg >>  1);
			WordAligned[i] = 0x0001 & (Channel_Reg >>  0);
		}

		Totalbits = (float)(Counter_1ms_Reg)*(float)(Bitrate * 1000);

		Hours =  Counter_1ms_Reg / NUMBER_OF_MS_PER_HOUR;
		Minutes = (Counter_1ms_Reg - (Hours * NUMBER_OF_MS_PER_HOUR)) / NUMBER_OF_MS_PER_MINUTE;
		Seconds = (Counter_1ms_Reg - (Hours * NUMBER_OF_MS_PER_HOUR) - (Minutes * NUMBER_OF_MS_PER_MINUTE)) / NUMBER_OF_MS_PER_SECOND;

		if (ErrorCount > 0)
		{
			BER = ((ErrorCount)) / Totalbits;
		}
		else
		{
			BER = ((float)3) / Totalbits; /* confidence level (CL) of 95% = -ln(1-CL) = 3*/
		}

		printf("\n\n\n");
		printf("Catapult V3 SmartNIC Superlite II V4 across %d Lanes \n", NUMBER_OF_LANES);
		printf("--------------------------------------------------------------------------------\n");
		printf("|Board Revision           : Catapult V3 SmartNIC 'Dragontails Peak' & 'Longs Peak'\n");
		printf("|Hardware Revision        : %02x/%02x/20%2x variant %02x\n", HWVersion_Month, HWVersion_Day, HWVersion_Year, HWSubversion);
		printf("|Software Build Date      : %s  %s\n", __DATE__, __TIME__);
		printf("|Number of Lanes          : %d  \n", NUMBER_OF_LANES);
		printf("|Line rate                : %d Mbps \n", Linerate);
		printf("|Aggregrate Line Rate     : %d Mbps \n", Bitrate);
		printf("|Read Length              : %d \n", READ_LENGTH);
		printf("|Idle Length              : %d \n", IDLE_LENGTH);
		printf("|Ratio                    : %4.4f   \n", Ratio);
		printf("|Net User Data Bandwidth  : %4d Mbps \n", Userdatarate);
		printf("|Efficiency               : %4.2f %% \n", Efficiency);
		printf("|Measured Latency         : %d ns, %d parallel clocks (measurement only valid in serial/external loopback)\n", Latency_Max[0], Latency_Max_Reg[0]);
		if (use_odi_acceleration)
		{
			printf("|EyeQInterval             : %d ms \n", EyeQInterval);
		}
		printf("|SelectedChannel          :");
		switch (SelectedChannel)
		{
		case  0  :
			printf(" 0 (QSFP+ Lane 0) \n"); break;
		case  1  :
			printf(" 1 (QSFP+ Lane 1) \n"); break;
		case  2  :
			printf(" 2 (QSFP+ Lane 2) \n"); break;
		case  3  :
			printf(" 3 (QSFP+ Lane 3) \n"); break;
			default :
			break;
		}
		if(qsfp_cable_plugged && i2c_get_cable_info(qsfp_cable_manufacturer , qsfp_cable_part_number , qsfp_cable_serial_number) ==0)
		{
			qsfp_cable_manufacturer[16] = 0;
			qsfp_cable_part_number[16] = 0;
			qsfp_cable_serial_number[16] = 0;
			printf("|QSFP Cable Manufacturer  : %s\n", qsfp_cable_manufacturer);
			printf("|QSFP Cable Part Number   : %s\n", qsfp_cable_part_number);
			printf("|QSFP Cable Serial Number : %s\n", qsfp_cable_serial_number);
		}
		else
		{
			printf("|QSFP Cable Manufacturer  : <<QSFP cable unplugged>>\n");
			printf("|QSFP Cable Part Number   : <<QSFP cable unplugged>>\n");
			printf("|QSFP Cable Serial Number : <<QSFP cable unplugged>>\n");
		}
		printf("-------------------------------------------------------------------------------\n");
		printf("\n");
		t = 0;
		printf("Status\n");
		printf("=====================");
		for (i = 0; i < NUMBER_OF_LANES; i++)
		{
			printf("=========");
		}
		printf("\n");

		printf("Lane                |");
		for (i = 0; i < NUMBER_OF_LANES; i++)
		{
			printf("%8d|", i);
		}
		printf("\n");
		printf("                    |");
		for (i = 0; i < NUMBER_OF_LANES; i++)
		{
			printf("--------|");
		}
		printf("\n");

		printf("Lane Identifier    : ");
		for (i = 0; i < NUMBER_OF_LANES; i++)
		{
			printf("%8d|", Lane_identifier[i]);
		}
		printf("\n");

		printf("Serial Loop        : ");
		for (i = 0; i < NUMBER_OF_LANES; i++)
		{
			if (Serial_Loop[i] == 1)
			{
				printf("      ON|");
			}
			else 
			{
				printf(COLOR_YELLOW COLOR_INVERSE "     OFF" COLOR_RESET "|");
			}
		}
		printf("\n=========================================================\n");

		printf("XOFF Sent          :");

		if (XOFF == 0)
		{
			printf("        0");
		}
		else
		{
			printf(COLOR_YELLOW COLOR_INVERSE "        1" COLOR_RESET);
		}
		
		printf("\n");

		printf("XOFF Received      :");
		if (XOFF_Received[0] == 0)
		{
			printf("        0");
		}
		else
		{
			printf(COLOR_YELLOW COLOR_INVERSE "        1" COLOR_RESET);
		}
		
		printf("\n");
		
		printf("QSFP Cable Plugged :");
		print_alarm(qsfp_cable_plugged, 1);
		
		printf("PLL Locked         :");
		print_alarm(PLL_Locked[0], 1);

		printf("Freq Locked        :");
		print_alarm(Rx_FreqLocked[0], 1);

		printf("Error Deskew       :");
		print_alarm(Error_Deskew, 0);

		printf("Error Decoder      :");
		print_alarm(Error_Decoder, 0);

		printf("Word Aligned       :");
		print_alarm(WordAligned[0], 1);

		printf("Lane Aligned       :");
		print_alarm(LaneAligned[0], 1);

		printf("Link Up            :");
		print_alarm(LinkUp[0], 1);

		printf("Data Locked        :");
		print_alarm(Locked[0], 1);

		printf("Error Count        :");
		if ((Locked[0] == 0))
		{
			printf("        ");
		}
		else
		{
			if (ErrorCount == 0)
			{
				print_alarm(ErrorCount, 0);
			}
			else if (ErrorCount > 99999999)
			{
				printf(COLOR_ALARM "xxxxxxxxx" COLOR_RESET);
			}
			else
			{
				printf(COLOR_ALARM "%9d" COLOR_RESET, ErrorCount_Reg);
			}
		}

		printf("\n\n");

		if (Locked[0] == 1)
		{

			if (ErrorCount > 0) printf("BER Estimate Link          : " COLOR_ALARM "%e" COLOR_RESET "   (# Errors/Totalbits)\n", BER);
			else printf("BER (CL=0.95) Link         : " COLOR_OK "%e" COLOR_RESET "\n", BER);
		}
		else printf(COLOR_ALARM "No Data Lock achieved" COLOR_RESET "\n");

		ClockRatio[0] = ((((float)DataClock_Reg) / (float)(DataClock_Reg)) - 1) * 1000000;

		ppm_difference[0] = ClockRatio[0]; // convert float to integer

		printf("\n");

		printf("Test Time                  : %2dh %2dm %2ds\n", Hours, Minutes, Seconds);
		printf("Reference Clock Frequency  : %.4f MHz\n", RefClock_Reg / 1000000.f);
		printf("DataClock Frequency        : %.4f MHz\n", DataClock_Reg / 1000000.f);
		printf("DataClock_out Frequency    : %.4f MHz\n", DataClock_Out_Reg / 1000000.f);
		printf("Measured ppm difference    : %3d\n", ppm_difference[0]);
		printf("Temperature Arria 10       : %3d (degrees Celcius)\n", Temperature);

		printf("\n");

		printf("\nSelect Action : \n");
		printf("===============\n");

		printf("0. Refresh status\n");
		printf("1. Reset\n");
		printf("2. Force Re-Alignment on Rx Path\n");
		printf("3. Show/Control Transceiver PMA Settings on Links\n");
		printf("4. Insert Biterrors on Link (%1d at a time)\n", (NUMBER_OF_LANES));
		printf("5. Reset Error Counter\n");
		printf("B. Set new Bitrate\n");
		printf("C. Select Channel To Control\n");
		printf("E. Show Transceiver PMA Settings on all channels\n");
		printf("G. Input new EyeQInterval time\n");
		printf("L. Control Serial loopback\n");
		printf("M. Perform %d resets and measure latency and delay\n", RESET_CYCLES);
		printf("P. Redo ATX PLL calibration \n");
		printf("R. Redo Transceiver calibration \n");
		printf("S. Store all channel information in memory of Selected Channel \n");
		printf("T. Store and compare with values stored in process S \n");
		printf("X. Toggle XOFF to partner to stop/start sending traffic at remote side \n");
		printf("Z. Dump channel content of selected channel \n");
		if (use_odi_acceleration)
		{
			printf("O. Perform ODI on selected channel (using ODI acceleration)\n");
		}
		else
		{
			printf("O. Perform ODI on selected channel (not using ODI Acceleration)\n");
		}
		printf("\n  Enter Choice :");

		rx_char = input_char();

		switch (rx_char)
		{
		case '0':
			break;
			
		case '1': /* Reset Link*/
			
			Control_Reg = Control_Reg | (0x8000);
			IOWR_ALTERA_AVALON_PIO_DATA(CONTROL_REG_BASE, Control_Reg);			
			usleep(10);			
			Control_Reg = Control_Reg & (0x7FFF);
			IOWR_ALTERA_AVALON_PIO_DATA(CONTROL_REG_BASE, Control_Reg);
			
			usleep(1000000); // Wait for 1 second
			printf("\nReset toggled.\n\n\n");
			
			break;

		case '2': /*Force Re-Alignment on Rx Path */

			Control_Reg = Control_Reg | (0x1000);
			IOWR_ALTERA_AVALON_PIO_DATA(CONTROL_REG_BASE, Control_Reg);
			usleep(10);
			Control_Reg = Control_Reg & (0xEFFF);
			IOWR_ALTERA_AVALON_PIO_DATA(CONTROL_REG_BASE, Control_Reg);
			usleep(10);
			printf("\nForce Re-Alignment on Rx Path.\n\n\n");
			
			break;

		case '3': /*Show/Control Transceiver Parameters */

			transceiver_parameters();			

			break;

		case '4': /* Insert Biterrors */

			printf("\n4. Insert Biterror on Link\n\n\n");
			Control_Reg = Control_Reg | (0x4000);
			IOWR_ALTERA_AVALON_PIO_DATA(CONTROL_REG_BASE, Control_Reg);
			usleep(10);
			Control_Reg = Control_Reg & (0xBFFF);
			IOWR_ALTERA_AVALON_PIO_DATA(CONTROL_REG_BASE, Control_Reg);
			
			break;

		case '5': /* Reset ErrorCounter */

			printf("\n5. Reset ErrorCounter \n\n\n");
			Control_Reg = Control_Reg | (0x2000);
			IOWR_ALTERA_AVALON_PIO_DATA(CONTROL_REG_BASE, Control_Reg);
			usleep(10);
			Control_Reg = Control_Reg & (0xDFFF);
			IOWR_ALTERA_AVALON_PIO_DATA(CONTROL_REG_BASE, Control_Reg);
			usleep(100000);
			
			break;
		
		case 'b':
		case 'B':
			choose_bitrate();
			break;
			
		case 'C': /*Select Channel To Control*/
		case 'c':
		
			printf("\nC. Select Channel To Control\n");
			printf("Current Channel : ");
			switch (SelectedChannel)
			{
			case  0  :
				printf(" 0: QSFP+ Lane 0 \n"); break;
			case  1  :
				printf(" 1: QSFP+ Lane 1 \n"); break;
			case  2  :
				printf(" 2: QSFP+ Lane 2 \n"); break;
			case  3  :
				printf(" 3: QSFP+ Lane 3 \n"); break;
				default :
				break;
			}
			temp = 0xffffffff;

			do
			{
				printf("New Channel (0-3)         :");
				rx_char = input_char();

				switch (rx_char)
				{
				case '0':
					temp = 0; break;
				case '1':
					temp = 1; break;
				case '2':
					temp = 2; break;
				case '3':
					temp = 3; break;
					default :
					break;
				}
			}
			while (temp == 0xffffffff);

			SelectedChannel = temp;

			break;

		case 'L': /*Toggle Serial Loop SMA Lanes */
		case 'l':
			toogle_loopback();
			break;

		case 'g':
		case 'G': /* New EyeQ Interval Time Interval */

			printf("\nG. Provide EyeQ Time Interval\n");
			printf("   Current EyeQTime Interval   : %4d miliseconds\n", EyeQInterval);
			printf("   Insert new EyeQ Interval Time, Hexadecimal Number from 01 to FF :");

			EyeQInterval = input_byte();
			
			printf("\n    New EyeQTime interval is %4d miliseconds:\n", EyeQInterval);

			break;

		case 'e': /* Show Transceiver PMA Settings on all channels */
		case 'E':
			show_pma_settings(dfe_enable);
			break;

		case 'm':
		case 'M': /* Loop to measure latency and delay */

			printf("\n\nMeasuring Latency across %d cycles, this takes some time ....", RESET_CYCLES );
			NOK = 0;
			Latency_Minimum = 1000;
			Latency_Maximum = 0;

			for (j = 0; j < 256; j++)
			{
				hist[j] = 0;
			}

			for (j = 0; j < RESET_CYCLES; j++)
			{
				Control_Reg = Control_Reg | (0x8000);

				IOWR_ALTERA_AVALON_PIO_DATA(CONTROL_REG_BASE, Control_Reg);
				usleep(100);
				
				Control_Reg = Control_Reg & (0x7FFF);

				IOWR_ALTERA_AVALON_PIO_DATA(CONTROL_REG_BASE, Control_Reg);

				usleep(1000);

				do
				{
					Channel_Reg      = IORD_ALTERA_AVALON_PIO_DATA(CHANNEL_REG_BASE);
					ChannelOK[0] = 0x0001 & (Channel_Reg >> 3);
				}
				while (ChannelOK[0] == 0);
				// Problem with the loop above is that it will hang if the channel is not ok.

				usleep(1000);
				Latency_Max_Reg[0] = IORD_ALTERA_AVALON_PIO_DATA(LATENCY_MAX_REG_BASE);

				// Measure time how long it took to reach ChannelOK
				Counter_1ms_Reg = IORD_ALTERA_AVALON_PIO_DATA(COUNTER_1MS_REG_BASE); // NUMBER_OF_MS_PER_SECOND;

				Latency_Memory[j] = Latency_Max_Reg[0];

				if (ChannelOK[0] == 0)
				{
					NOK = NOK + 1;

					if (Latency_Memory[j] < Latency_Minimum) Latency_Minimum = Latency_Memory[j];
					if (Latency_Memory[j] > Latency_Maximum) Latency_Maximum = Latency_Memory[j];

					printf("\n");
					printf("%2d:   Latency:  %3d clock cycles ", j, Latency_Memory[i]);
					if (STOP == 1)
					{
						printf("\nLink NOK  press any key: %d :\n", NOK);
						rx_char = input_char();
					}
				}
				else
				{
					if (Latency_Memory[j] == 0)
					{
						printf("\nError : Latency measurement is zero");
						break;
					}
					else
					{
						if (Latency_Memory[j] < Latency_Minimum) Latency_Minimum = Latency_Memory[j];
						if (Latency_Memory[j] > Latency_Maximum) Latency_Maximum = Latency_Memory[j];
						
						hist[Latency_Memory[j]] = hist[Latency_Memory[j]] + 1;
					}
					printf("\n");
					printf("%4d:Latency:%3d clock cycles ", j, Latency_Memory[j]);
				}
			}

			printf("\n");

			for (i = Latency_Minimum; i <= Latency_Maximum; i++)
			{
				if(hist[i] != 0)
				{
					printf("\nNumber of cases Maximum Latency is equal to %2d parallel clocks is : %4d", i, hist[i]);
				}
			}
			break;

		case 'z': //Dump register space
		case 'Z':
			for (j = 0; j < NUMBER_OF_LANES; j++)
			{
				temp = rd_channel((j << 10) + 0x100); // From bit 10 it specifies the channel.
				printf("\nChannel %1d Register 0x100 : 0x%2x", j, temp);

				temp = rd_channel((j << 10) + 0x101); // From bit 10 it specifies the channel.
				printf("\nChannel %1d Register 0x101 : 0x%2x", j, temp);

				for (i = 0x134; i <= 0x139; i++)
				{
					temp = rd_channel((j << 10) + i); // From bit 10 it specifies the channel.
					printf("\nChannel %1d Register 0x%3x : 0x%2x", j, i, temp);
				}
				temp = rd_channel((j << 10) + 7);
				printf("\nChannel %1d Register 0x7 : 0x%2x", j, temp);

				temp = rd_channel((j << 10) + 0xA);
				printf("\nChannel %1d Register 0xA : 0x%2x", j, temp);

				temp = rd_channel((j << 10) + 0x110); //
				printf("\nChannel %1d Register 0x110 : 0x%2x", j, temp);

				temp = rd_channel((j << 10) + 0x111); //
				printf("\nChannel %1d Register 0x111 : 0x%2x", j, temp);

				temp = rd_channel((j << 10) + 0x119); //
				printf("\nChannel %1d Register 0x119 : 0x%2x", j, temp);

				printf("\n");
			}

			for (i = 0x100; i <= 0x117; i++)
			{
				temp = rd_pll(i);
				printf("\nATX PLL Register 0x%3x : 0x%2x", i, temp);
			}
			break;

		case 'p': //Recalibrate ATX PLL
		case 'P':

			recalibrate_pll(ATX_PLL);
			break;

		case 'r': //Recalibrate XCVR
		case 'R':

			recalibrate_channel(SelectedChannel, NO_RATE_SWITCH);
			break;
			
		case 's': //Dump register space of SelectedChannel
		case 'S':
			for (i = 0x0; i <= 0x256; i++)
			{
				dump_register_before[i] = rd_channel((SelectedChannel << 10) + i);
			}
			printf("\n\nStored all registers from channel %2d in memory\n\n", SelectedChannel);

			break;

		case 't': //Dump register space of channel 0 after and compare
		case 'T':
			for (i = 0x0; i <= 0x256; i++)
			{
				dump_register_after[i] = rd_channel((SelectedChannel << 10) + i);
				if (dump_register_after[i] != dump_register_before[i])
				{
					printf("\nChannel %2d : Register 0x%3x : Before :0x%2x  After : 0x%2x", SelectedChannel, i, dump_register_before[i], dump_register_after[i]);
				}
			}
			printf("\n\n");
			break;

			//ODI Measurement on SelectedChannel

		case 'o':
		case 'O':
		
			printf("\n");
			if (use_odi_acceleration)
			{
				printf("\nMeasuring 2D and 1D Eye , this should take around %d seconds .... \n\n", EyeQInterval * 9);
			}
			else
			{
				printf("\nMeasuring 2D and 1D Eye\n\n");
			}

			///////////////////////////////////////////////////////////////////////
			// Call Function to perform Eye measurement on selected channel
			///////////////////////////////////////////////////////////////////////

			VCCER_Level = VCCER_1030MV;
			Bandwidth = ABOVE_10GBPS;
			DFE_Mode = dfe_enable[SelectedChannel];

			if (use_odi_acceleration)
			{
				eye = do_eye_measurement(SelectedChannel, 1000 * EyeQInterval, Bandwidth, VCCER_Level, DFE_Mode, BER_Array, ErrorCount_Array
				, &veye, &veye_top, &veye_bottom, &table_phase_start, &eye_phase, &optimum_phase, &Totalbits_ODI, 1);
			}
			else
			{
				eye = do_eye_measurement_no_acceleration(SelectedChannel, 1000 * EyeQInterval, Bandwidth, VCCER_Level, DFE_Mode, BER_Array, ErrorCount_Array
				, &veye, &veye_top, &veye_bottom, &table_phase_start, &eye_phase, &optimum_phase, &Totalbits_ODI, 1);
			}

			///////////////////////////////////////////////////////////////////////
			// Print Centered 2D Eye
			///////////////////////////////////////////////////////////////////////

			print_2D_eye(BER_Array,  ErrorCount_Array, &veye_top, &veye_bottom, &table_phase_start);

			///////////////////////////////////////////////////////////////////////
			// Print Bathtub (1D)
			///////////////////////////////////////////////////////////////////////

			print_1D_eye(BER_Array, &table_phase_start);

			///////////////////////////////////////////////////////////////////////
			// Print ODI Statistics
			///////////////////////////////////////////////////////////////////////

			printf("\nHorizontal Eye Opening Ch %1d: %2d phases", SelectedChannel, eye_phase);
			printf("\nHorizontal Eye Opening Ch %1d: %.2f UI", SelectedChannel, eye);
			printf("\nOptimum Phase Ch %1d         : %2d", SelectedChannel, optimum_phase);
			printf("\nVertical Eye Opening Ch %1d  : %2d steps", SelectedChannel, veye);
			if (use_odi_acceleration)
			{
				printf("\nSampling time per sample   : %2d ms", EyeQInterval);
			}
			printf("\nBER Depth                  : %5e", (1 / Totalbits_ODI));
			
			break;

		case 'x': /* Toggle XOFF */
		case 'X':

			if (XOFF == 0)
			{
				XOFF = 1;
				printf("\nXOFF active.\n\n\n");
			}
			else
			{
				XOFF = 0;
				printf("\nXOFF not active.\n\n\n");
			}

			Control_Reg = (Control_Reg & (0xF7FF)) | (XOFF << 11);
			IOWR_ALTERA_AVALON_PIO_DATA(CONTROL_REG_BASE, Control_Reg);

			usleep(10);

			break;

		default:
			
			break;
		}
	}
	return 0;
}

void print_alarm(int value, int ok_value)
{
	if (value == ok_value) printf("%8s" COLOR_OK "%1d" COLOR_RESET, " ", ok_value);
	else printf("%8s" COLOR_ALARM "%1d" COLOR_RESET, " ", !(ok_value));

	printf("\n");
}
