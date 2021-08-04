/* Input functions */

#include <stdio.h>
#include "system.h"
#include "string.h"
#include "altera_avalon_pio_regs.h"
#include <unistd.h>
#include "io.h"
#include "altera_avalon_jtag_uart_regs.h" 

char input_char(void)
{
	char in_char, rx_char;

	rx_char = 0;
	char prev = 0;
	while (1)
	{
		in_char = getchar();
		if (in_char != '\r' && in_char != '\n')
		rx_char = in_char;
		else if ((in_char == '\n' && prev != '\r') || (in_char == '\r' && prev != '\n')) 
		break; 
		prev = in_char;

	}
	return (rx_char);
}


int input_number(void)
{
	char in_char,LSB;
	char prev = 0;
	int temp, number;

	LSB = 0;
	temp = 0;
	number = 0;
	while (1)
	{
		in_char = getchar();
		if (in_char != '\r' && in_char != '\n')
		{
			//rx_char = in_char;        
			LSB = in_char;
		}
		else if ((in_char == '\n' && prev != '\r') || (in_char == '\r' && prev != '\n'))
		break;
		prev = in_char;
		
		switch (LSB)
		{
		case '0': temp = 0; break;
		case '1': temp = 1; break;
		case '2': temp = 2; break;
		case '3': temp = 3; break;
		case '4': temp = 4; break;
		case '5': temp = 5; break;
		case '6': temp = 6; break;
		case '7': temp = 7; break;
		case '8': temp = 8; break;
		case '9': temp = 9; break;
		case 'A': 
		case 'a': temp = 0xa; break;
		case 'B': 
		case 'b': temp = 0xb; break;
		case 'C': 
		case 'c': temp = 0xc; break;
		case 'D': 
		case 'd': temp = 0xd; break;
		case 'E': 
		case 'e': temp = 0xe; break;
		case 'F': 
		case 'f': temp = 0xf; break;
			default : break;
		}
		
		
		number  = temp;         
	};	
	return (number);
} 

int input_byte(void)
{
	char in_char, MSB,LSB;
	char prev = 0;
	int temp, High_nibble, Low_nibble, Byte;
	

	MSB = 0;
	LSB = 0;
	temp = 0;
	Byte = 0;
	while (1)
	{
		in_char = getchar();
		if (in_char != '\r' && in_char != '\n')
		{
			MSB = LSB;         
			LSB = in_char;
		}
		else if ((in_char == '\n' && prev != '\r') || (in_char == '\r' && prev != '\n'))
		break;
		prev = in_char;
		
		switch (MSB)
		{
		case '0': temp = 0; break;
		case '1': temp = 1; break;
		case '2': temp = 2; break;
		case '3': temp = 3; break;
		case '4': temp = 4; break;
		case '5': temp = 5; break;
		case '6': temp = 6; break;
		case '7': temp = 7; break;
		case '8': temp = 8; break;
		case '9': temp = 9; break;
		case 'A': 
		case 'a': temp = 0xa; break;
		case 'B': 
		case 'b': temp = 0xb; break;
		case 'C': 
		case 'c': temp = 0xc; break;
		case 'D': 
		case 'd': temp = 0xd; break;
		case 'E': 
		case 'e': temp = 0xe; break;
		case 'F': 
		case 'f': temp = 0xf; break;
			default : break;
		}
		
		High_nibble = temp;
		
		switch (LSB)
		{
		case '0': temp = 0; break;
		case '1': temp = 1; break;
		case '2': temp = 2; break;
		case '3': temp = 3; break;
		case '4': temp = 4; break;
		case '5': temp = 5; break;
		case '6': temp = 6; break;
		case '7': temp = 7; break;
		case '8': temp = 8; break;
		case '9': temp = 9; break;
		case 'A': 
		case 'a': temp = 0xa; break;
		case 'B': 
		case 'b': temp = 0xb; break;
		case 'C': 
		case 'c': temp = 0xc; break;
		case 'D': 
		case 'd': temp = 0xd; break;
		case 'E': 
		case 'e': temp = 0xe; break;
		case 'F': 
		case 'f': temp = 0xf; break;
			default : break;
		}
		
		Low_nibble = temp;  
		
		Byte = (High_nibble << 4) | Low_nibble;         
	};
	return (Byte);
} 

int input_double(void)
{
	char in_char, MSB,LSB;
	char prev = 0;	 
	int temp, High_nibble, Low_nibble, Double_Digit;

	MSB = 0;
	LSB = 0;
	temp = 0;
	Double_Digit = 0;
	while (1)
	{
		in_char = getchar();
		if (in_char != '\r' && in_char != '\n')
		{
			MSB = LSB;         
			LSB = in_char;
		}
		else if ((in_char == '\n' && prev != '\r') || (in_char == '\r' && prev != '\n'))
		break;
		prev = in_char;
		
		switch (MSB)
		{
		case '0': temp = 0; break;
		case '1': temp = 1; break;
		case '2': temp = 2; break;
		case '3': temp = 3; break;
		case '4': temp = 4; break;
		case '5': temp = 5; break;
		case '6': temp = 6; break;
		case '7': temp = 7; break;
		case '8': temp = 8; break;
		case '9': temp = 9; break;
			default : break;
		}
		
		High_nibble = temp;
		
		switch (LSB)
		{
		case '0': temp = 0; break;
		case '1': temp = 1; break;
		case '2': temp = 2; break;
		case '3': temp = 3; break;
		case '4': temp = 4; break;
		case '5': temp = 5; break;
		case '6': temp = 6; break;
		case '7': temp = 7; break;
		case '8': temp = 8; break;
		case '9': temp = 9; break;
			default : break;
		}
		
		Low_nibble = temp;  
		
		Double_Digit = (High_nibble *10) + Low_nibble;         
	};
	return (Double_Digit);
} 


int input_word(void)
{
	char in_char, N3,N2,N1,N0;
	char prev = 0;		 
	int temp, N3_int, N2_int,N1_int,N0_int, Word;

	N3 = 0;
	N2 = 0;
	N1 = 0;
	N0 = 0;         
	temp = 0;
	Word = 0;
	while (1)
	{
		in_char = getchar();
		if (in_char != '\r' && in_char != '\n')
		{
			N3 = N2;
			N2 = N1;
			N1 = N0;
			N0 = in_char;
		}
		else if ((in_char == '\n' && prev != '\r') || (in_char == '\r' && prev != '\n'))
		break;
		prev = in_char;
		
		switch (N3)
		{
		case '0': temp = 0; break;
		case '1': temp = 1; break;
		case '2': temp = 2; break;
		case '3': temp = 3; break;
		case '4': temp = 4; break;
		case '5': temp = 5; break;
		case '6': temp = 6; break;
		case '7': temp = 7; break;
		case '8': temp = 8; break;
		case '9': temp = 9; break;
		case 'A': 
		case 'a': temp = 0xa; break;
		case 'B': 
		case 'b': temp = 0xb; break;
		case 'C': 
		case 'c': temp = 0xc; break;
		case 'D': 
		case 'd': temp = 0xd; break;
		case 'E': 
		case 'e': temp = 0xe; break;
		case 'F': 
		case 'f': temp = 0xf; break;
			default : break;
		}
		
		N3_int = temp;
		
		switch (N2)
		{
		case '0': temp = 0; break;
		case '1': temp = 1; break;
		case '2': temp = 2; break;
		case '3': temp = 3; break;
		case '4': temp = 4; break;
		case '5': temp = 5; break;
		case '6': temp = 6; break;
		case '7': temp = 7; break;
		case '8': temp = 8; break;
		case '9': temp = 9; break;
		case 'A': 
		case 'a': temp = 0xa; break;
		case 'B': 
		case 'b': temp = 0xb; break;
		case 'C': 
		case 'c': temp = 0xc; break;
		case 'D': 
		case 'd': temp = 0xd; break;
		case 'E': 
		case 'e': temp = 0xe; break;
		case 'F': 
		case 'f': temp = 0xf; break;
			default : break;
		}
		
		N2_int = temp;  

		switch (N1)
		{
		case '0': temp = 0; break;
		case '1': temp = 1; break;
		case '2': temp = 2; break;
		case '3': temp = 3; break;
		case '4': temp = 4; break;
		case '5': temp = 5; break;
		case '6': temp = 6; break;
		case '7': temp = 7; break;
		case '8': temp = 8; break;
		case '9': temp = 9; break;
		case 'A': 
		case 'a': temp = 0xa; break;
		case 'B': 
		case 'b': temp = 0xb; break;
		case 'C': 
		case 'c': temp = 0xc; break;
		case 'D': 
		case 'd': temp = 0xd; break;
		case 'E': 
		case 'e': temp = 0xe; break;
		case 'F': 
		case 'f': temp = 0xf; break;
			default : break;
		}
		
		N1_int = temp;  

		switch (N0)
		{
		case '0': temp = 0; break;
		case '1': temp = 1; break;
		case '2': temp = 2; break;
		case '3': temp = 3; break;
		case '4': temp = 4; break;
		case '5': temp = 5; break;
		case '6': temp = 6; break;
		case '7': temp = 7; break;
		case '8': temp = 8; break;
		case '9': temp = 9; break;
		case 'A': 
		case 'a': temp = 0xa; break;
		case 'B': 
		case 'b': temp = 0xb; break;
		case 'C': 
		case 'c': temp = 0xc; break;
		case 'D': 
		case 'd': temp = 0xd; break;
		case 'E': 
		case 'e': temp = 0xe; break;
		case 'F': 
		case 'f': temp = 0xf; break;
			default : break;
		}
		
		N0_int = temp;                
		Word = (N3_int << 12) | (N2_int << 8) | (N1_int << 4) | N0_int;         
	};
	return (Word);	
} 
