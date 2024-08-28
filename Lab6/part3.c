#include <stdbool.h>

#define AUDIO_BASE          0xFF203040
//#define SAMPLE_RATE         20000	// sampling rate of audio told by prof

// Audio port structure 
struct audio_t {
	volatile unsigned int control;  // The control/status register
	volatile unsigned char rarc;    // the 8 bit RARC register
	volatile unsigned char ralc;    // the 8 bit RALC register
	volatile unsigned char wsrc;    // the 8 bit WSRC register
	volatile unsigned char wslc;    // the 8 bit WSLC register
	volatile unsigned int ldata;    // the 32 bit (really 24) left data register
	volatile unsigned int rdata;    // the 32 bit (really 24) right data register
};

struct audio_t *const audiop = ((struct audio_t *) AUDIO_BASE);
volatile int *SW_ptr = (volatile int*)0xFF200040;
int SAMPLE_RATE = 8000;
int freq = 2000;
int value;
int prev_value = 2000;

void generateSquareWave(int FREQ){
	   // Variables for square wave generation
    //bool high = false;
    int counter = 0;
	
	while (1){
		value = *SW_ptr;
		if (value != prev_value){
			// setting different sample rates according to the switches
			if (value == 1){
				freq = 100;
			} else if (value == 2){
				freq = 300;
			} else if (value == 4){
				freq = 500;
			} else if (value == 8){
				freq = 700;
			} else if (value == 16){
				freq = 900;
			} else if (value == 32){
				freq = 1100;
			} else if (value == 64){
				freq = 1300;
			} else if (value == 128){
				freq = 1500;
			} else if (value == 256){
				freq = 1600;
			} else if (value == 512){
				freq = 1800;
			} else if (value == 1024){
				freq = 2000;
			}
			prev_value = value;
			return;
		}
		
		int samplesPerPeriod = SAMPLE_RATE/freq;
		// Check if there is space in the output FIFO
		if (audiop->wsrc) {
			// for square wave
			// setting rdata and ldata to max for half period
			if (counter < samplesPerPeriod / 2) {
				audiop->ldata = 0x7FFFFFFF; // Set left output to maximum
				audiop->rdata = 0x7FFFFFFF; // Set right output to maximum
			} // setting rdata and ldata to zero for the next half period
			else {	
				audiop->ldata = 0; // Set left output to 0
				audiop->rdata = 0; // Set right output to 0
			}

			// resetting the counter after one period
			counter++;
			if (counter >= samplesPerPeriod) {
				counter = 0;
			}
		}
	}
}

int main(void) {
	while(1){
		generateSquareWave(freq);
	}
}
