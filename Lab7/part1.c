#include <stdio.h>
#include <math.h>
#include <stdbool.h>
	
int pixel_buffer_start; // global variable
void plot_pixel(int x, int y, short int line_color);
void draw_line(int start_x, int start_y, int end_x, int end_y, short int color);
void swap(int* point1, int* point2);
void clear_screen();

int main(void)
{
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    /* Read location of the pixel buffer from the pixel buffer controller */
    pixel_buffer_start = *pixel_ctrl_ptr;

    clear_screen();
    draw_line(0, 0, 150, 150, 0x001F);   // this line is blue
    draw_line(150, 150, 319, 0, 0x07E0); // this line is green
    draw_line(0, 239, 319, 239, 0xF800); // this line is red
    draw_line(319, 0, 0, 239, 0xF81F);   // this line is a pink color
}

void clear_screen()
{
        int y, x;

        for (x = 0; x < 320; x++)
                for (y = 0; y < 240; y++)
                        plot_pixel (x, y, 0);
}

// code not shown for clear_screen() and draw_line() subroutines
void plot_pixel(int x, int y, short int line_color)
{
    volatile short int *one_pixel_address;

        one_pixel_address = (short int *)(pixel_buffer_start + (y << 10) + (x << 1));

        *one_pixel_address = line_color;
}

void swap(int* point1, int* point2){
	int temp = *point1;
	*point1 = *point2;
	*point2 = temp;
}

void draw_line(int start_x, int start_y, int end_x, int end_y, short int color){
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
	int y_step;
	if (start_y < end_y)
		y_step = 1;
	else
		y_step = -1;
	
	for (int x = start_x; x <= end_x; x++){
		if (is_steep){
			plot_pixel(y, x, color);
		}
		else {
			plot_pixel(x, y, color);
		}
		error += delta_y;
		if (error >= 0){
			y += y_step;
			error -= delta_x;
		}
	}
}
	


