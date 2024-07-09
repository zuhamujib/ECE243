#Nios II Assembly program to compute the sum of numbers from 1 to 30
.global _start
_start:
	#Initialize sum and end
	movi r12, 0      #Initialize sum to 0
	movi r10, 30      #Initialize end to 31

	#Loop to sum numbers 1 to 30
loop:
    addi r12, r12, 1    #Decrement counter
	ble r12, r10, loop   #Branch back to loop if counter >= 30

#Infinite loop to halt the program
fever: br fever

	
