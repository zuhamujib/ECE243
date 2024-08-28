.section .exceptions, "ax"
                         # code not shown
IRQ_HANDLER:
        # save registers on the stack (et, ra, ea, others as needed)
        subi    sp, sp, 60         # make room on the stack
        stw     et, 0(sp)  # stores the exception type
        stw     ra, 4(sp)  # stores the address of the return of the subroutine onto the stack
                            # because it calls abother subroutine inside this so prevents any overwriting and keeping
                            # which instruction the processor must go to when eret or ret happens
        stw     r4, 8(sp) # save r16
        stw     r5, 12(sp) # save r17
        stw     r6, 16(sp) # save r18
        stw     r7, 20(sp) # save r19
        stw     r8, 24(sp) # save r20
        stw     r9, 28(sp) # save r21
        stw     r10, 32(sp) # save r22
        stw     r11, 36(sp) # save r23
		stw 	r12, 40(sp)
		stw		r2,  44(sp)
		stw 	r13, 48(sp)
		stw 	r14, 52(sp)
		stw 	r3, 56(sp)

        rdctl   et, ctl4            # read exception type
        beq     et, r0, SKIP_EA_DEC # not external?
        subi    ea, ea, 4           # decrement ea by 4 for external interrupts

SKIP_EA_DEC:
        stw     ea, 60(sp)  # storing the return address for the subroutine onto the stack
        andi    r12, et, 0x2        # check if interrupt is from keys
		srli    r12, r12, 1
        beq     r12, r0, SKIP    # if not, ignore this interrupt
		stw 	r12, 0(sp)
		call 	KEY_ISR

	SKIP:
		movia r13, RUN
		ldw r14, 0(r13)
		beq r14, r0, END_ISR

	NEXT:
		andi	r12, et, 1			# check if the interupt is from the timer
		beq 	r12, r0, END_ISR	# if not, ignore this interrupt
        call    TIMER_ISR             # if yes, call the pushbutton ISR

END_ISR:
        ldw     et, 0(sp)  # stores the exception type
        ldw     ra, 4(sp)  # stores the address of the return of the subroutine onto the stack
                            # because it calls abother subroutine inside this so prevents any overwriting and keeping
                            # which instruction the processor must go to when eret or ret happens
        ldw     r4, 8(sp) # restore r16
        ldw     r5, 12(sp) # restore r17
        ldw     r6, 16(sp) # restore r18
        ldw     r7, 20(sp) # restore r19
        ldw     r8, 24(sp) # restore r20
        ldw     r9, 28(sp) # restore r21
        ldw     r10, 32(sp) # restore r22
        ldw     r11, 36(sp) # restore r23
		ldw 	r12, 40(sp)
		ldw		r2,  44(sp)
		ldw 	r13, 48(sp)
		ldw 	r14, 52(sp)
		ldw 	r3, 56(sp)
		
        ldw     ea, 60(sp)  # storing the return address for the subroutine onto the stack

        addi    sp, sp, 60          # restore stack pointer
        eret                        # return from exception

		
.section .reset, "ax"
        movia   r8, _start
        jmp     r8	
	
.text
.global  _start
_start:
    /* Set up stack pointer */
	movia 	r6, DELAY
	movia 	r3, DELAYSTART
	ldw	r2, (r3)
	stw	r2, 0(r6)
	
    call    CONFIG_TIMER        # configure the Timer
	movi	r4, 0b1111
    call    CONFIG_KEYS         # configure the KEYs port
    /* Enable interrupts in the NIOS-II processor */

    movia   r8, LED_BASE        # LEDR base address (0xFF200000)
    movia   r9, COUNT           # global variable
	movia 	sp, 200000
	br LOOP
    # movia r13, RUN
# main loop that writes the value of the COUNT to the red lights LEDR
TIMER_ISR:
		subi sp, sp, 8
		stw ra, 0(sp)
		
        movia   r4, TIMER_BASE
        movia   r5, LED_BASE
        movia   r6, COUNT
		
        ldwio   r7, (r5)    # read the current state of the LEDs
		movia   r10, ENDCOUNTER_DATA
		ldw 	r11, 0(r10)
        beq     r7, r11, reset     # reset the COUNT to zero
	continue:
        addi    r8, r7, 1         # else increment the counter
        stw     r8, 0(r6)
        # ACK Timer Interrupt
        movi    r9, 0
        stwio   r9, 0(r4) # clear Status TO bit
		
		ldw 	ra, 0(sp)
		addi	sp, sp, 8
        ret
reset:
        stw     r0, 0(r6)    # store 0 into the LEDs
		br continue 

KEY_ISR:
		subi 	sp, sp, 8
		stw 	ra, 4(sp)
		
		movia r2, KEY_BASE

		# setting operations
		ldwio r3, 12(r2)	 # load the edge capture register
		andi r3, r3, 1		# extract bit 0
		beq r3, r0, not0
		br STOP
	
	not0:
		ldwio r3, 12(r2)	 # load the edge capture register
		andi r3, r3, 2		# extract bit 1
		srli r3, r3, 1
		beq r3, r0, not1
		br FASTER
		
	not1:
		ldwio r3, 12(r2)	 # load the edge capture register
		andi r3, r3, 4		# extract bit 2
		srli r3, r3, 2
		beq r3, r0, RETUR
		br SLOWER
	
	FASTER:
		movia 	r4, TIMER_BASE
		stwio r0, 0(r4)
		
		movi    r2, 0x8 # stop it
		stwio   r0, 0(r4) # clear TO
		stwio   r2, 4(r4) # stop timer
		movia 	r3, DELAY
		ldw		r2, 0(r3)	# load the current speed
		srli	r2, r2, 0x1	# half the delay
		stw		r2, 0(r3)
		movia r4, TIMER_BASE
		stwio r0, 0(r4)
		
		stwio   r3, 8(r4) # periodlo
		srli    r3, r3, 16
		stwio   r3, 12(r4) # periodhi

		stwio   r0, 0(r4) # clear TO
		movi    r2, 0x7 # START | CONT | ITO
		stwio   r2, 4(r4)
		br RETUR
		
	SLOWER:
		movia r4, TIMER_BASE
		stwio r0, 0(r4)
		
		movi    r2, 0x8 # stop it
		stwio   r0, 0(r4) # clear TO
		stwio   r2, 4(r4) # stop timer
		movia 	r3, DELAY
		ldw		r2, 0(r3)	# load the current speed
		slli	r2, r2, 0x1	# double the the delay
		stw		r2, 0(r3)
		movia r4, TIMER_BASE
		stwio r0, 0(r4)
		
		stwio   r3, 8(r4) # periodlo
		srli    r3, r3, 16
		stwio   r3, 12(r4) # periodhi

		stwio   r0, 0(r4) # clear TO
		movi    r2, 0x7 # START | CONT | ITO
		stwio   r2, 4(r4)
		br RETUR

		
	STOP:
		# need to set RUN to 1 or 0 depending on a negative edge
		movia 	r13, RUN
		ldw		r14, 0(r13)	# load RUN
		
		# toggle the RUN
		xori 	r14, r14, 1
		stw		r14, 0(r13)	# store back into RUN
	RETUR:
		# clear the edge capture register/ need to acknowlegde the key interupt
		movia r2, KEY_BASE
		ldwio r3, 0(r2)
		movi r14, 0xF
		stwio r14, 12(r2)
		
		ldw 	ra, 4(sp)
		addi 	sp, sp, 8
		ret

LOOP:
    ldw     r10, 0(r9)          # global variable
    stwio   r10, 0(r8)          # write to the LEDR lights
    br      LOOP

CONFIG_TIMER:               # code not shown
                        # DEVICE SIDE
    movia   r4, TIMER_BASE
    movia   r5, DELAY
    movi    r2, 0x8 # stop it
    stwio   r0, 0(r4) # clear TO
    stwio   r2, 4(r4) # stop timer
    stwio   r5, 8(r4) # periodlo
    srli    r5, r5, 16
    stwio   r5, 12(r4) # periodhi

    stwio   r0, 0(r4) # clear TO
    movi    r2, 0x7 # START | CONT | ITO
    stwio   r2, 4(r4)

    # CPU SIDE
    rdctl   r4, ctl3
    ori     r4, r4, 1
    wrctl   ctl3, r4 # enable ints for IRQ0/timer
    wrctl   ctl0, r4 # enable ints globally
    ret

CONFIG_KEYS:                # code not shown
    movia   r2, KEY_BASE # buttons
    stwio   r4, 12(r2) # reset EDGE bits
    stwio   r4, 8(r2)  # set mask bits
    rdctl   r5, ctl3
    ori     r5, r5, 2
    wrctl   ctl3, r5 # enable ints for IRQ1/buttons
    movi    r4, 1
    wrctl   ctl0, r4 # enable ints globally
    ret

.data
/* Global variables */
.equ    LED_BASE, 0xff200000
.equ 	KEY_BASE, 0xff200050
.equ    TIMER_BASE, 0xff202000
.equ    DELAY, 0x1000000

.global  COUNT
COUNT:  .word    0x0            # used by timer

.global  RUN                    # used by pushbutton KEYs
RUN:    .word    0x1            # initial value to increment COUNT

.global  DELAYSTART
DELAYSTART:  .word     25000000           # used by timer

.global ENDCOUNTER_DATA
ENDCOUNTER_DATA:  .word    255    # Allocate space for ENDCOUNTER
.end
