/* I2C functions */

#include <stdio.h>
#include <unistd.h>
#include "altera_avalon_i2c.h"
#include "system.h"
#include "parameters.h"

int i2c_set_retimer_rate(int rate)
{
	uint8_t tx[2];
	uint8_t rx[1];
	ALT_AVALON_I2C_STATUS_CODE status;

	ALT_AVALON_I2C_DEV_t *device = alt_avalon_i2c_open(I2C_0_NAME);
	if(device == 0)
	{
		return -1;
	}

	// set target device
	alt_avalon_i2c_master_target_set(device, I2C_RETIMER_ADDRESS);

	// Enable channel register and broadcast changes to all channels
	tx[0] = 0xFF;
	tx[1] = 0x3;
	status = alt_avalon_i2c_master_tx(device, tx, 2, 0);
	if (status != ALT_AVALON_I2C_SUCCESS)
	{
		return -1 ;
	}
	
	// Set new bitrate
	tx[0] = 0x2F;
	status=alt_avalon_i2c_master_tx_rx(device, tx, 1, rx, 0x1, ALT_AVALON_I2C_NO_INTERRUPTS);	
	if (status != ALT_AVALON_I2C_SUCCESS)
	{
		return -1;
	}
	rx[0] = rx[0] & (0xFF & (~0xF0));	
	switch(rate)
	{
	case 0:
		tx[1] = rx[0] | 0x0;   // 10.3125 Gbps
		break;

	case 1:
		tx[1] = rx[0] | 0x10;  // 10.9375 Gbps
		break;

	case 2:
		tx[1] = rx[0] | 0x20;  // 12.5000 Gbps
		break;
	}
	status = alt_avalon_i2c_master_tx(device, tx, 2, 0);
	if (status != ALT_AVALON_I2C_SUCCESS)
	{
		return -1;
	}
	return 0;
}


int i2c_get_cable_info(char *qsfp_cable_manufacturer , char *qsfp_cable_part_number , char *qsfp_cable_serial_number) 
{
	uint8_t tx[1];
	ALT_AVALON_I2C_STATUS_CODE status;
	ALT_AVALON_I2C_DEV_t *device = alt_avalon_i2c_open(I2C_0_NAME);

	// set target device
	alt_avalon_i2c_master_target_set(device, I2C_QSFP_CABLE_ADDRESS);

	tx[0] = 148;
	status = alt_avalon_i2c_master_tx_rx(device, tx, 1, (unsigned char*) qsfp_cable_manufacturer, 16, 0);	
	if (status != ALT_AVALON_I2C_SUCCESS)
	{
		return -1;
	}
	
	tx[0] = 168;
	status = alt_avalon_i2c_master_tx_rx(device, tx, 1, (unsigned char*) qsfp_cable_part_number, 16, 0);	
	if (status != ALT_AVALON_I2C_SUCCESS)
	{
		return -1;
	}
	
	tx[0] = 196;
	status = alt_avalon_i2c_master_tx_rx(device, tx, 1, (unsigned char*) qsfp_cable_serial_number, 16, 0);	
	if (status != ALT_AVALON_I2C_SUCCESS)
	{		
		return -1;
	}
	return 0;
}
