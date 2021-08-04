/* PMA_functions.h */
void rmw_channel (int offset,int bitmask, int newval); 

int rd_channel (int offset);

void wr_channel (int offset, int value);

void rmw_pll (int offset,int bitmask, int newval);

int rd_pll (int offset);

void wr_pll (int offset,int value);

void reconfigure_channel (int channel,unsigned int mif[4]);

void switch_rx_cdr_refclock (int refclock, int channel, int VERBOSE_SWITCH);

int encode_pretap2 (int pretap2); 

int decode_pretap2 (int pretap2_encoded); 

int encode_pretap1 (int pretap1); 

int decode_pretap1 (int pretap1_encoded);

int encode_posttap1 (int posttap1); 

int decode_posttap1 (int posttap1_encoded); 

int encode_posttap2 (int posttap2); 

int decode_posttap2 (int posttap2_encoded);

int encode_dcgain (int dcgain);

int decode_dcgain (int dcgain_encoded);

void show_pma_settings (int dfe_enable[NUMBER_OF_LANES]);
