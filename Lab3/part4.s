.text
/* Program to Count the number of 1’s in a 32-bit word,
located at InputWord */
# used Lecture 7: Bitwise operations shift

/*
Idea:
- Shift bits as many times as the number of bits (32b)
- Each iteration check if LSB is 1
	- If it is, increment counter and continue
	- Otherwise continue with next iteration
*/

.text
.global _start

_start:
    movia r3, TEST_NUM  # the address of TEST_NUM is in r3
	movia r5, LargestOnes # the address of LargestOnes is in r5
	movia r6, LargestZeroes # the address of LargestZeroes is in r6
	
	movi r9, 0 # the value of LargestOnes is in r9
	movi r10, 0 # the value of LargestZeroes is in r10
	movi r11, 0xFFFFFFFF

loop:
# for each word:
	ldw r4, 0(r3)         # update the value of input word
	beq r4, r0, iloop # check if at end of list
				
determine_ones:
	ldw r4, 0(r3)         # update the value of input word
	call ONES             # call ONES subroutine
	blt r2, r9, determine_zeroes  # if current ones count is less than prev found, skip updating LargestOnes and proceed to determine ones
	# otherwise, update the value of largest ones so far and the address
	mov r9, r2  # update LargestOnes value
	ldw r5, (r3)  # update LargestOnes address

determine_zeroes:
	ldw r4, 0(r3)         # update the value of input word
	xor r4, r4, r11 # flip all the bits to count the zeroes (which get switched to ones to use ONES subroutine)
	call ONES             # call ONES subroutine
	blt r2, r10, next_iteration  # if current count is less, skip updating LargesetZeroes and proceed to next iteration
	# otherwise, update the value of largest zeroes so far and the address
	mov r10, r2  # update LargestZeroes value
	ldw r6, (r3)  # update LargestZeroes address
	
next_iteration:
	addi r3, r3, 4 # add 4 to point to next word
	br loop # if not at end of list, loop again

iloop:
	movia r9, 2000000 /* set starting point for delay counter */
LED1:
	#light up LED 1
.equ LEDs, 0xFF200000
	movia r24, LEDs
	stwio r5, (r24)
	call DELAY

	movia r9, 2000000
LED2:
	#light up LED 2
.equ LEDs, 0xFF200000
	movia r24, LEDs
	stwio r6, (r24)
	call DELAY
	br iloop
	#Added delay 
DELAY:
	subi r9,r9,1       # subtract 1 from delay
	bne r9,r0, DELAY   # continue subtracting if delay has not elapsed
	ret
	
finished:
	br endiloop
		
endiloop: br endiloop

#Subroutine that counts bits
ONES: 
    movi r2, 0            # store the value of the counter in r2
    movi r7, 32           # 32 bits to check (num of times to shift)

# Loop to check each bit
check:
	andi r8, r4, 1    # get LSB of r4 into r8
    beq r8, r0, skip # skip if LSB is not 1
    addi r2, r2, 1    # increment counter in r2

skip:
   	srai r4, r4, 1        # shift r4 right by 1 bit
   	subi r7, r7, 1        # decrement num bits left to check
	bne r7, r0, check
    ret                  # return from subroutine

.data
TEST_NUM: .word 0x4a01fead, 0xF677D671,0xDC9758D5,0xEBBD45D2,0x8059519D
.word 0x76D8F0D2, 0xB98C9BB5, 0xD7EC3A9E, 0xD9BADC01, 0x89B377CD
.word 0 # end of list
LargestOnes: .word 0
LargestZeroes: .word 0
	
	
