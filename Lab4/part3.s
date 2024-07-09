.global _start
	.equ KEY_BASE, 0xFF200050
	.equ LEDs, 0xFF200000
	.equ TIMER_BASE, 0xFF202000
	.equ COUNTER_DELAY, 100000000
	
_start:  movia	r6, KEY_BASE		# set r8 to base KEY port
	 	 movia	r7, LEDs	# set r9 to base of LEDR port
		 movia	r8, COUNTER_DELAY    # load the delay value
		 movia	r9, TIMER_BASE	# r20 is the base address of the timer

		 movi	r3, 0	#initializing counter to 0
		 movi	r4, 255	# initializing stop value of the counter
		  
		 stwio	r0, 0(r9)         # clear the TO (Time Out) bit in case it is on
         srli	r5, r8, 16          # shift right by 16 bits
         andi	r8, r8, 0xFFFF      # mask to keep the lower 16 bits
         stwio	r8, 0x8(r9)         # write to the timer period register (low)
         stwio	r5, 0xc(r9)         # write to the timer period register (high)
	
poll:	ldwio	r11, 0xC(r6)	# load the edge capture 
    	beq		r11, r0, poll	# if no button press detected, keep waiting
    	stwio	r11, 0xC(r6)  # clear the edge capture
    	movi	r5, 0			# change state to start counting

main:	ldwio	r11, 0xC(r6)			# Load the Edge Capture register value again
    	bne		r11, r0, edge_capture 	# If any bit is set, button was pressed
    	beq		r5, r0, ploop			# If counting state is active, update LEDs
    	br main						# Loop continuously

edge_capture:	movi r10, 1
				xor r5, r5, r10
				stwio r11, 0xC(r6)	# Reset Edge Capture register
				br main             # Return to the main loop
			
tloop:	stwio	r3, 0(r7)	# write into LED0
		beq		r3, r4, reset
		addi	r3, r3, 1	# increment counter	
		br main
	
ploop:	movi	r8, 0b0110           # enable continuous mode and start timer
        stwio	r8, 0x4(r9)         # write to the timer control register to 
									# and go into continuous mode
		ldwio	r8, 0x0(r9)         # read the timer status register
		andi	r8, r8, 0b1          # mask the TO bit
		beq		r8, r0, ploop		# if TO bit is 0, wait
		stwio	r0, 0x0(r9)         # clear the TO bit
	
		br tloop
	
reset:	movi r3, 0	# reset counter back to 0
		br tloop
