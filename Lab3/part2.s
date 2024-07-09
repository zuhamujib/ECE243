/* Program to Count the number of 1's in a 32-bit word,
located at InputWord */

.global _start
_start:
main:
	movi r4, 46510
	call ONES

endiloop: br endiloop

ONES:
	movi r10, 0	#makes sure the starting vallue of the counter is zero
	movi r3, 1	#holds the number 1
	
loop:
	beq r4, r3, end #if the input value has reached 1, (last one in the number)
					#end program
	#check if end of the number is reached, by checking r6== 1
	srli r7, r4, 1	#shift the input by 1 to the right: divided by 2
	slli r8, r7, 1	#shift input back by 1
	sub r9, r4, r8	#find the difference between the numbers
	
	mov r4, r7	#store the new shifted number back into r4
	
	beq r9, r0, loop	#if the difference is 0 the lsb was 0
	beq r9, r3, add	#if the difference is 1 the lsb was 1
	
add:
	addi r2, r2, 1
	br loop
	
end:
	addi r2, r2, 1
	ret
