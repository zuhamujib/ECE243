#define AUDIO_BASE 0xFF203040
#define SAMPLE_RATE 8000 // Fixed
#define DELAY_SECONDS 0.4
#define DELAY_SAMPLES (int)(SAMPLE_RATE * DELAY_SECONDS)
#define DAMPING_FACTOR 0.4 // Example value, adjust based on experimentation

// Audio port structure
struct audio_t {
    volatile unsigned int control; // The control/status register
    volatile unsigned char rarc; // the 8 bit RARC register
    volatile unsigned char ralc; // the 8 bit RALC register
    volatile unsigned char wsrc; // the 8 bit WSRC register
    volatile unsigned char wslc; // the 8 bit WSLC register
    volatile unsigned int ldata;
    volatile unsigned int rdata;
};

// Echo buffer for left and right channels
int echoBufferLeft[DELAY_SAMPLES];
int echoBufferRight[DELAY_SAMPLES];
int echoIndex = 0;

struct audio_t *const audiop = ((struct audio_t *) AUDIO_BASE);

void addEchoEffect(int *left, int *right) {
    // Read the old value from the echo buffer
    int oldLeft = echoBufferLeft[echoIndex];
    int oldRight = echoBufferRight[echoIndex];
	
    // Update the buffer with the new output value, applying the damping factor to the old value
    echoBufferLeft[echoIndex] = *left + DAMPING_FACTOR * oldLeft;
    echoBufferRight[echoIndex] = *right + DAMPING_FACTOR * oldRight;

    // Increment and wrap the echo buffer index
    echoIndex = (echoIndex + 1) % DELAY_SAMPLES;
	
	// Apply the echo effect to the current output
   	*left = echoBufferRight[echoIndex];
    *right = echoBufferRight[echoIndex];
}

int main(void) {
    int left, right;

    // Initialize the echo buffer
    for (int i = 0; i < DELAY_SAMPLES; i++) {
        echoBufferLeft[i] = 0;
        echoBufferRight[i] = 0;
    }

    // Infinite loop checking the RARC to see if there is at least a single entry in the input FIFOs.
    while (1) {
        if (audiop->rarc > 0) { // Check RARC to see if there is data to read
            // Load both input microphone channels - just get one sample from each
            left = audiop->ldata; // Load the left input FIFO
            right = audiop->rdata; // Load the right input FIFO

            if (audiop->wsrc){
				// Add echo effect
				addEchoEffect(&left, &right);

				audiop->ldata = left; // Store to the left output FIFO
				audiop->rdata = right; // Store to the right output FIFO
			}
		}
    }
}
