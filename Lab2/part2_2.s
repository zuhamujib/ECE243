.text  # The numbers that turn into executable instructions
.global _start
_start:

/* r13 should contain the grade of the person with the student number, -1 if not found */
/* r10 has the student number being searched */
	movia r11, result
	movia r10, 718293		# r10 is where you put the student number being searched for

/* Your code goes here  */
	movi r12, Snumbers	#holds all the enrolled student numbers
	movi r13, Grades	#holds the Grades corresponding to each student number
	
loop:
	ldw r9, (r12)	#load the enrolled student numbers
	ldb r8, (r13)	#load the grades corresponding to current student number

	beq r9, r0, notfound
	beq r9, r10, found
	 
	addi r12, r12, 4	#increment to the next student number
	addi r13, r13, 1	#increment to the next student grades
	
	br loop	#branch back to the loop
found:
	stb r8, (r11)
	ldb r6, (r11)	#to see the contents of result
	#store the contents in r8 into the memory address held by r11 i.e result
.equ LEDs, 0xFF200000
	movia r24, LEDs
	stwio r6, (r24)
	br iloop
notfound:
	movi r7, -1
	stb r7, (r11)
	ldb r6, (r11)	#to see the contents of result
	#store -1 in the memory address held by r11 i.e result
.equ LEDs, 0xFF200000
	movia r24, LEDs
	stwio r6, (r24)
iloop: br iloop


.data  	# the numbers that are the data 
/* result should hold the grade of the student number put into r10, or
-1 if the student number isn't found */ 

result: .byte 0
.align 3
/* Snumbers is the "array," terminated by a zero of the student numbers  */
Snumbers: .word 10392584, 423195, 644370, 496059, 296800
        .word 265133, 68943, 718293, 315950, 785519
        .word 982966, 345018, 220809, 369328, 935042
        .word 467872, 887795, 681936, 0

/* Grades is the corresponding "array" with the grades, in the same order*/
Grades: .byte 99, 68, 90, 85, 91, 67, 80
        .byte 66, 95, 91, 91, 99, 76, 68  
        .byte 69, 93, 90, 72
	
	
