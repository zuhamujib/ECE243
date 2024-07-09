.global _start

	.equ KEY_BASE, 0xFF200050
	.equ LEDs, 0xFF200000
	
/* program to copy the keys data register to the LEDs */
	
_start:  movia r8, KEY_BASE		# set r8 to base KEY port 
								# r8 is the data register
	 	  movia r9, LEDs	# set r9 to base of LEDR port
		  
		  movi r3, 1	# keeping 1 here to compare values of other buttons and start counter 
		  movi r7, 15	# initialize end of counter
		  
poll:
	ldwio r4, 0(r8)		#load the data register into r4
	
	andi r5, r4, 1	# store bit0 into r5
	bne r5, r0, resetTo1
	
	andi r5, r4, 2 # store bit1 into r5
	srli r5, r5, 1	# extract the second bit
	bne r5, r0, increment
	
	andi r5, r4, 4	#store bit2 into r5
	srli r5, r5, 2	# extract the third bit
	bne r5, r0, decrement
	
	andi r5, r4, 8	#store bit3 into r5
	bne r5, r0, resetTo0
	
	br poll
	
resetTo1:
	movi r6, 1
	br lightUp

increment:
	ldwio r4, 0(r8)
	andi r5, r4, 2
	srli r5, r5, 1	# extract the second bit
	ldwio r6, (r9)	# storing current number on the LEDs in r6
	beq r6, r7, poll
	bne r5, r0, increment
	addi r6, r6, 1
	br lightUp
		
decrement:
	ldwio r4, 0(r8)	# loading the word in again
	andi r5, r4, 4
	srli r5, r5, 2	# extract the third bit
	ldwio r6, (r9)	# storing current number on the LEDs in r6
	beq r6, r0, resetTo1
	beq r6, r3, poll
	bne r5, r0, decrement	#wait till the negative edg
	subi r6, r6, 1
	br lightUp

resetTo0:
	movi r6, 0
	br lightUp
	
lightUp:
	stwio r6, (r9)
	br poll
	 	
branch: br branch
