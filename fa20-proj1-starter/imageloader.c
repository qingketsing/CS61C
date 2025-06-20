/************************************************************************
**
** NAME:        imageloader.c
**
** DESCRIPTION: CS61C Fall 2020 Project 1
**
** AUTHOR:      Dan Garcia  -  University of California at Berkeley
**              Copyright (C) Dan Garcia, 2020. All rights reserved.
**              Justin Yokota - Starter Code
**				Qingke
**
**
** DATE:        2020-08-15
**
**************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include <string.h>
#include "imageloader.h"

//Opens a .ppm P3 image file, and constructs an Image object. 
//You may find the function fscanf useful.
//Make sure that you close the file with fclose before returning.
Image *readData(char *filename) 
{
	/*
	@param : 
		filename: the name of what we want to open and read
		fp : a pointer point to the file which has the name of 'filename'
		type_name : obviously it is "P3"
		width : the width of the img
		height : the height of the img
		rt_img : the value we need to return
		maxval : the max color value
		r, g, b : three color value
		
	@brief :
		Open the file and read the data of it, then close the file.
	*/

	// First of all , open the file
	FILE *fp = fopen(filename, "r");
	if(fp == NULL){
		printf("There's no such a file!");
	}
	// Second , use fscanf to read the file's content;

	char type_name[10];
	int width, height;
	fscanf(fp,"%s %d %d",type_name,&width,&height);

	if (strcmp(type_name, "P3") != 0) {
		printf("Unsupported file format: %s\n", type_name);
		fclose(fp);
		return NULL;
	}

	Image *rt_img = malloc(sizeof(Image));

    rt_img->cols = width;
    rt_img->rows = height;
    rt_img->image = malloc(width * height * sizeof(Color*));

	int maxval;
	fscanf(fp,"%d",&maxval);

	for (int i = 0; i < width * height; i++) {
        rt_img->image[i] = malloc(sizeof(Color));

        int r, g, b;
        fscanf(fp, "%d %d %d", &r, &g, &b);

        rt_img->image[i]->R = r;
        rt_img->image[i]->G = g;
        rt_img->image[i]->B = b;
    }

	fclose(fp);

	return rt_img;
}

//Given an image, prints to stdout (e.g. with printf) a .ppm P3 file with the image's data.
void writeData(Image *image)
{
	/*
	@param:
		height : same as other functions
		width : same as other functions
		image : the object we need to starderd output
		*c : temperary store the paramaters that we need to printf
	@brief:
		print the images paramaters as the format it has given, pay attention to the space and format XD.
	*/

	printf("P3\n");

	int width = image->cols;
	int height = image->rows;
	printf("%d %d\n", width, height);
	printf("255\n");
	for(int i = 0; i < height;i++){
		printf("  ");
		for(int j = 0;j < width;j++){
			Color *c = image->image[i*width+j];
			printf("%3d %3d %3d", c->R, c->G, c->B);
			if (j != width - 1) {
                printf("   ");
            }
		}
		printf("\n");
	}

}

//Frees an image
void freeImage(Image *image)
{
	/*
	@param:
		height : same as other functions
		width : same as other functions
		image : the object we need to free memory

	@brief:
		for this function, we need to free the object of image.	
	*/
	int height = image->rows;
	int width = image->cols;
	for(int i = 0; i < height*width; i++){
		free(image->image[i]);
	}
	free(image->image);
	free(image);
}