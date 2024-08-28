# Nios II Architecture Labs

## Overview

This repository contains a series of labs designed to introduce students to the Nios II architecture, focusing on programming hardware devices using Nios II and C languages. The labs cover a range of topics, including working with various peripherals such as speakers, microphones, VGA displays, keyboards, LED lights, switches, and more.

## Lab Contents

Each lab in this series builds on the previous one, progressively introducing more complex concepts and devices. Below is a brief overview of the labs included:

1. **Lab 1: Introduction to Nios II and Cpulator Computer System Simulator**
   - Learn the basics of assembly programming with the Nios II processor.
   - Develop and debug assembly code using the CPUlator simulator.
   - Test and run your assembly code on the DE1-SoC hardware.
  
2. **Lab 2: Accessing Memory, Loops, Conditional Branches**
   - Introduction to basic I/O operations.
   - Writing a C program to control LEDs based on switch inputs.
   - Continue learning assembly language programming with a focus on memory access and addressing modes.
   - Develop a program to look up and display grades using lists of student numbers and grades.
     
3. **Lab 3: Logic Instructions, Subroutines, and Memory-Mapped Output**
   - Learn to use logic and shift instructions, create subroutines, and implement memory-mapped output.
   - Develop a program to count binary ones, use subroutines within loops, and display results on DE1-SoC LEDs.
   - Implement a software delay loop for timing and adjust for differences between simulation and real hardware.

4. **Lab 4: Memory Mapped I/O, Polling, and Timers**
   - Develop programs using polling to detect and respond to button presses, controlling LED displays on the DE1-SoC board.
   - Implement a binary counter using a delay loop, and modify it to use a hardware timer for precise time measurement.
   - Create a real-time binary clock by integrating polled I/O with the timer, displaying seconds and hundredths of seconds on the DE1-SoC LEDs.

5. **Lab 5: Hex Displays and Interrupt-Driven Input/Output**
   - Implementing interrupt-driven I/O, essential for synchronizing processors with external events, using assembly language on the NIOS II processor.
   - Develop a program to display hexadecimal digits on the DE1-SoC's HEX displays using a provided subroutine, demonstrating subroutine functionality without interrupts.
   - Implement an interrupt-driven input system, toggling numbers on the HEX displays based on pushbutton presses, and explore interrupt handling and modular code organization.
   - Control the LEDR lights using an interrupt-based binary counter, integrating timer interrupts to increment the counter value.
   - Extend the interrupt-driven system to allow dynamic adjustment of the counter speed, modifying timer settings through pushbutton interactions.

6. **Lab 6: Coding in C and Advanced I/O Operations: Audio Programming with Speakers and Microphones** 
   - Transition from Nios II Assembly Language to C for embedded system I/O tasks, focusing on memory-mapped I/O with C pointers and bit-level logical operations.
   - Develop a C program to interface audio input and output, connecting microphone input to speaker output, and understand the limitations of simulation environments.
   - Create a C program to generate a square wave for audio output with adjustable frequency, using the DE1-SoC's switches to select the frequency.
   - Implement an echo effect in audio processing, creating a delayed and dampened version of the input signal to simulate an echo effect.

7. **Lab 7: Introduction to Graphics and Animation**
   - Implement a line-drawing algorithm in C, specifically Bresenham’s algorithm, to draw lines on a VGA display or within CPUlator’s VGA pixel buffer.
   - Develop an animation program to move a horizontal line up and down the screen, bouncing off the edges, synchronized with the VGA controller’s refresh rate.
   - Create a more complex animation featuring eight bouncing boxes connected by lines, using dual frame buffers for smooth transitions and randomization for varied motion.


