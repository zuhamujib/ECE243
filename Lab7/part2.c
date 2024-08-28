#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdbool.h>

int* pixel_buffer_start; // global variable
void plot_pixel(int x, int y, short int line_color);
void draw_line(int start_x, int start_y, int end_x, int end_y, short int color);
void clear_screen();

int main(void)
{
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;

    volatile int * s_bit = (int *)0xFF20302C; // Use unsigned int pointer to read 32 bits
    /* Read location of the pixel buffer from the pixel buffer controller */
    *pixel_buffer_start = *pixel_ctrl_ptr;

    //printf("Pixel buffer start address: %d\n", pixel_buffer_start);

    int row = 0; // Initial row position
    int direction = 1; // Initial direction of movement (down)
    
    clear_screen();
    // Draw the line in the new position
    draw_line(0, row, 319, row, 0xF800); // Draw line (red color)
    
    while (1) {    
		
		*pixel_ctrl_ptr  = 0x1; // write 1 into the buffer register to read the s-bit
                            // every 1/60th of a second
        // Wait for buffer swap to complete (check bit 0 of s-bit)
        while(((*s_bit) & 0x1) != 0);
        //printf("Buffer swap completed\n");
        
        // Erase the previous line by drawing it with black color
        draw_line(0, row, 319, row, 0x0000); // Erase line
        //printf("Line erased at row: %d\n", row);
        
        // Check if the line reaches the top or bottom edge of the screen
        if (row <= 0){
			direction = 1;
		} else if (row >= 239) {
            // Change direction if it reaches the edge
            direction = -1;
        }
        
        // increment or decrement the row
        row += direction;
        
        // Draw the line in the new position
        draw_line(0, row, 319, row, 0xF800); // Draw line (red color)
        //printf("Line drawn at row: %d\n", row);
    }
}

void clear_screen()
{
    int y, x;

    for (x = 0; x < 320; x++)
        for (y = 0; y < 240; y++)
            plot_pixel (x, y, 0);
}

void plot_pixel(int x, int y, short int line_color)
{
    volatile short int *one_pixel_address;

    one_pixel_address = (short int *)(*pixel_buffer_start + (y << 10) + (x << 1));

    *one_pixel_address = line_color;
}


void swap(int* point1, int* point2)
{
    int temp = *point1;
    *point1 = *point2;
    *point2 = temp;
}


void draw_line(int start_x, int start_y, int end_x, int end_y, short int color)
{
    //printf("Drawing line from (%d,%d) to (%d,%d) with color: %x\n", start_x, start_y, end_x, end_y, color);
    bool is_steep = abs(end_y - start_y) > abs(end_x - start_x);
    if (is_steep){
        swap(&start_x, &start_y);
        swap(&end_x, &end_y);
    }
    if (end_x < start_x){
        swap(&start_x, &end_x);
        swap(&start_y, &end_y);
    }
    int delta_x = end_x - start_x;
    int delta_y = abs(end_y - start_y);
    int error = -delta_x/2;
    int y = start_y;
    int y_step = start_y < end_y ? 1 : -1;

    for (int x = start_x; x <= end_x; x++){
        if (is_steep)
            plot_pixel(y, x, color);
        else
            plot_pixel(x, y, color);
        error += delta_y;
        if (error >= 0){
            y += y_step;
            error -= delta_x;
        }
    }
}
