//parameters.h
//Contains all defines

#define FANCY_GRAPHICS 1

#define NUMBER_OF_MS_PER_HOUR 3600000
#define NUMBER_OF_MS_PER_MINUTE 60000
#define NUMBER_OF_MS_PER_SECOND 1000

//This parameter need to match the design.
#define NUMBER_OF_LANES 4

#define MULTIPLIER 65536.0 // 2^16

// I2C
#define I2C_RETIMER_ADDRESS 0x22
#define I2C_QSFP_CABLE_ADDRESS 0x50

//ODI Related parameters start
#define DimA 130
#define DimB 64
#define VCCER_900MV 1
#define VCCER_1030MV 2
#define VCCER_1110MV 3
#define BELOW_2GBPS 0
#define BETWEEN_2GBPS_5GBPS 1
#define BETWEEN_5GBPS_10GBPS 2
#define ABOVE_10GBPS 3
#define DEBUG_ODI 0
//ODI Related parameters Stop

//DFE related parameter
#define DFE_CONTINOUS 0


#define DEBUG 0
#define ADVANCED 1
#define RESET_CYCLES 100
#define STOP 1

#define VOD_15 15
#define VOD_20 20
#define VOD_25 25
#define VOD_28 28
#define VOD_29 29
#define VOD_30 30
#define VOD_31 31

#define PRE_TAP2_7N 0x17
#define PRE_TAP2_6N 0x16
#define PRE_TAP2_5N 0x15
#define PRE_TAP2_4N 0x14
#define PRE_TAP2_3N 0x13
#define PRE_TAP2_2N 0x12
#define PRE_TAP2_1N 0x11
#define PRE_TAP2_0  0x00 
#define PRE_TAP2_1  0x1
#define PRE_TAP2_2  0x2
#define PRE_TAP2_3  0x3
#define PRE_TAP2_4  0x4
#define PRE_TAP2_5  0x5
#define PRE_TAP2_6  0x6
#define PRE_TAP2_7  0x7

#define PRE_TAP1_16N 0x30
#define PRE_TAP1_15N 0x2F
#define PRE_TAP1_14N 0x2E
#define PRE_TAP1_13N 0x2D
#define PRE_TAP1_12N 0x2C
#define PRE_TAP1_11N 0x2B
#define PRE_TAP1_10N 0x2A
#define PRE_TAP1_9N 0x29
#define PRE_TAP1_8N 0x28
#define PRE_TAP1_7N 0x27
#define PRE_TAP1_6N 0x26
#define PRE_TAP1_5N 0x25
#define PRE_TAP1_4N 0x24
#define PRE_TAP1_3N 0x23
#define PRE_TAP1_2N 0x22
#define PRE_TAP1_1N 0x21
#define PRE_TAP1_0  0x00 
#define PRE_TAP1_1  0x1
#define PRE_TAP1_2  0x2
#define PRE_TAP1_3  0x3
#define PRE_TAP1_4  0x4
#define PRE_TAP1_5  0x5
#define PRE_TAP1_6  0x6
#define PRE_TAP1_7  0x7
#define PRE_TAP1_8  0x8
#define PRE_TAP1_9  0x9
#define PRE_TAP1_10  0xA
#define PRE_TAP1_11  0xB
#define PRE_TAP1_12  0xC
#define PRE_TAP1_13  0xD
#define PRE_TAP1_14  0xE
#define PRE_TAP1_15  0xF
#define PRE_TAP1_16  0x10

#define POST_TAP1_25N 0x59
#define POST_TAP1_24N 0x58
#define POST_TAP1_23N 0x57
#define POST_TAP1_22N 0x56
#define POST_TAP1_21N 0x55
#define POST_TAP1_20N 0x54
#define POST_TAP1_19N 0x53
#define POST_TAP1_18N 0x52
#define POST_TAP1_17N 0x51
#define POST_TAP1_16N 0x50
#define POST_TAP1_15N 0x4F
#define POST_TAP1_14N 0x4E
#define POST_TAP1_13N 0x4D
#define POST_TAP1_12N 0x4C
#define POST_TAP1_11N 0x4B
#define POST_TAP1_10N 0x4A
#define POST_TAP1_9N 0x49
#define POST_TAP1_8N 0x48
#define POST_TAP1_7N 0x47
#define POST_TAP1_6N 0x46
#define POST_TAP1_5N 0x45
#define POST_TAP1_4N 0x44
#define POST_TAP1_3N 0x43
#define POST_TAP1_2N 0x42
#define POST_TAP1_1N 0x41
#define POST_TAP1_0 0
#define POST_TAP1_1 1
#define POST_TAP1_2 2
#define POST_TAP1_3 3
#define POST_TAP1_4 4
#define POST_TAP1_5 5
#define POST_TAP1_6 6
#define POST_TAP1_7 7
#define POST_TAP1_8 8
#define POST_TAP1_9 9
#define POST_TAP1_10 10
#define POST_TAP1_11 11
#define POST_TAP1_12 12
#define POST_TAP1_13 13
#define POST_TAP1_14 14
#define POST_TAP1_15 15
#define POST_TAP1_16 16
#define POST_TAP1_17 17
#define POST_TAP1_18 18
#define POST_TAP1_19 19
#define POST_TAP1_20 20
#define POST_TAP1_21 21
#define POST_TAP1_22 22
#define POST_TAP1_23 23
#define POST_TAP1_24 24
#define POST_TAP1_25 25


#define POST_TAP2_12N 0x2C
#define POST_TAP2_11N 0x2B
#define POST_TAP2_10N 0x2A
#define POST_TAP2_9N 0x29
#define POST_TAP2_8N 0x28
#define POST_TAP2_7N 0x27
#define POST_TAP2_6N 0x26
#define POST_TAP2_5N 0x25
#define POST_TAP2_4N 0x24
#define POST_TAP2_3N 0x23
#define POST_TAP2_2N 0x22
#define POST_TAP2_1N 0x21
#define POST_TAP2_0  0x00 
#define POST_TAP2_1  0x1
#define POST_TAP2_2  0x2
#define POST_TAP2_3  0x3
#define POST_TAP2_4  0x4
#define POST_TAP2_5  0x5
#define POST_TAP2_6  0x6
#define POST_TAP2_7  0x7
#define POST_TAP2_8  0x8
#define POST_TAP2_9  0x9
#define POST_TAP2_10  0xA
#define POST_TAP2_11  0xB
#define POST_TAP2_12  0xC

#define EQ_CTRL_0 0
#define EQ_CTRL_1 1
#define EQ_CTRL_2 2
#define EQ_CTRL_3 3
#define EQ_CTRL_4 4
#define EQ_CTRL_5 5
#define EQ_CTRL_6 6
#define EQ_CTRL_7 7
#define EQ_CTRL_8 8
#define EQ_CTRL_9 9
#define EQ_CTRL_10 10
#define EQ_CTRL_11 11
#define EQ_CTRL_12 12
#define EQ_CTRL_13 13
#define EQ_CTRL_14 14
#define EQ_CTRL_15 15
#define EQ_CTRL_16 16
#define EQ_CTRL_17 17
#define EQ_CTRL_18 18
#define EQ_CTRL_19 19
#define EQ_CTRL_20 20
#define EQ_CTRL_21 21
#define EQ_CTRL_22 22
#define EQ_CTRL_23 23
#define EQ_CTRL_24 24
#define EQ_CTRL_25 25
#define EQ_CTRL_26 26
#define EQ_CTRL_27 27
#define EQ_CTRL_28 28
#define EQ_CTRL_29 29
#define EQ_CTRL_30 30
#define EQ_CTRL_31 31

//11C[3:0],11A[7:0]

#define EQ_GAIN_0 0x0
#define EQ_GAIN_1 0xE00
#define EQ_GAIN_2 0xFC0
#define EQ_GAIN_3 0xFF8
#define EQ_GAIN_4 0xFFF

//160 [3:1]
#define RADP_VGA_SEL_0 0
#define RADP_VGA_SEL_1 1
#define RADP_VGA_SEL_2 2
#define RADP_VGA_SEL_3 3
#define RADP_VGA_SEL_4 4
#define RADP_VGA_SEL_5 5
#define RADP_VGA_SEL_6 6
#define RADP_VGA_SEL_7 7

#define PRBS_7 0
#define PRBS_23 1
#define PRBS_31 2
#define PRBS_15 3
#define HIGH_FREQUENCY 4
#define LOW_FREQUENCY 5
#define PRBS_9 6

#define CONTINUOUS_3TAPS 0
#define CONTINUOUS_7TAPS 1
#define CONTINUOUS_11TAPS 2

#define ATX_PLL 0
#define fPLL 1

#define NO_RATE_SWITCH 0
#define RATE_SWITCH 1
#define COLOR_INVERSE 		"\033[7m"
#define COLOR_RESET 			"\033[m"

#define COLOR_BLUE			"\033[22;34m"
#define COLOR_LIGHT_BLUE	"\033[01;34m"

#define COLOR_LIGHT_CYAN	"\033[01;36m"

#define COLOR_GREEN 			"\033[22;32m"
#define COLOR_LIGHT_GREEN	"\033[01;32m"

#define COLOR_YELLOW 		"\033[01;33m"

#define COLOR_RED 			"\033[22;31m"
#define COLOR_LIGHT_RED 	"\033[01;31m"


#define COLOR_ALARM_INVERT	"\033[7m\033[01;31m"
#define COLOR_ALARM			"\033[01;31m"
#define COLOR_OK				"\033[01;32m"

#define COLOR_CORRECTABLE  "\033[01;33m"

#define DEGREES				"\xC2\xB0"
#define BLACKBOX			   "\xE2\x96\xA0"

#define BOX_LEFT_DOWN	   "\xE2\x94\x8C"
#define BOX_HORIZONTAL     "\xE2\x94\x80"

