int main(void)
{
    volatile int *LEDR_ptr = (int*)0xFF200000;
    volatile int *KEYs_ptr = (int*)0xFF200050;
    int edge_cap;
	
    while (1){
        edge_cap = *(KEYs_ptr + 3);
		if ((edge_cap & 1) > 0){	// extracting bit0 of the keys
			
			*LEDR_ptr = 0x3ff;	// turning on all the LEDs
			*(KEYs_ptr + 3) = 0xffff;	// clearing the edge_cap
			
		} else if ((edge_cap & 2) > 0){	// extracting bit1 of the keys
			
			*LEDR_ptr = 0x0;	// turning off all the LEDs
			*(KEYs_ptr + 3) = 0xffff;	// clearing the edge_cap
			
		}
			// keep the previous state	
	}
	return 0;
}


