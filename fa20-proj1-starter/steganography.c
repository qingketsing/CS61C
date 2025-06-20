/************************************************************************
**
** NAME:        steganography.c
**
** DESCRIPTION: CS61C Fall 2020 Project 1
**
** AUTHOR:      Dan Garcia  -  University of California at Berkeley
**              Copyright (C) Dan Garcia, 2020. All rights reserved.
**				Justin Yokota - Starter Code
**				Qingke
**
** DATE:        2020-08-23
**
**************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include "imageloader.h"

//Determines what color the cell at the given row/col should be. This should not affect Image, and should allocate space for a new Color.
Color *evaluateOnePixel(Image *image, int row, int col)
{
	/*
	@param:
		image : the image we need to read
		row : the row of the image 
		col : the col of the image
		rt_val : the value we need to return
		pixel : temporary store the color object
	@brief:
		read the value of the pixel which has the position of row and col,
		then get the last bit to determine black or white of this pixel.
	*/
	Color *rt_val = (Color*)malloc(sizeof(Color));
	if (rt_val == NULL) {
		exit(-1); // Memory allocation failed
	}

	Color *pixel = image->image[row * image->cols + col];
	
	if(pixel->B & 1){
		rt_val->B = 255;
		rt_val->G = 255;
		rt_val->R = 255;
	}else{
		rt_val->B = 0;
		rt_val->G = 0;
		rt_val->R = 0;
	}

	return rt_val;
}

//Given an image, creates a new image extracting the LSB of the B channel.
Image *steganography(Image *image)
{
	/*
	@param:
		image : the image object we need to edit;
		width : the size of the image's cols
		height : the size of the image's rows
		rt_img : the object we need to return

	@brief:
		allocate the memory of the image and then extract the sign of the Blue channel ,
		then evaluate the pixel by 'evaluateOnePixel' function , and return the value after evaluation.image
		then return the new image
	*/

	Image *rt_img = (Image*)malloc(sizeof(Image));
	if(rt_img == NULL){
		exit(-1);
	}

	int width = image->cols;
	int height = image->rows;
	rt_img->rows = height; 
    rt_img->cols = width;    
	rt_img->image = (Color **)malloc(sizeof(Color *) * width * height);
    if(rt_img->image == NULL){
        free(rt_img);
        exit(-1);
    }
	for(int i = 0;i < height;i++){
		for(int j = 0;j < width;j++){
			rt_img->image[i * width + j] = evaluateOnePixel(image, i, j);
		}
	}

	return rt_img;
}

/*
Loads a file of ppm P3 format from a file, and prints to stdout (e.g. with printf) a new image, 
where each pixel is black if the LSB of the B channel is 0, 
and white if the LSB of the B channel is 1.

argc stores the number of arguments.
argv stores a list of arguments. Here is the expected input:
argv[0] will store the name of the program (this happens automatically).
argv[1] should contain a filename, containing a file of ppm P3 format (not necessarily with .ppm file extension).
If the input is not correct, a malloc fails, or any other error occurs, you should exit with code -1.
Otherwise, you should return from main with code 0.
Make sure to free all memory before returning!
*/
int main(int argc, char **argv)
{
	if(argc != 2){
		printf("error input! You need to enter two value!");
		exit(-1);
	}
	Image *img = readData(argv[1]);
	Image *hidden = steganography(img);
	writeData(hidden);
	freeImage(hidden);
	freeImage(img);
	return 0;
}
