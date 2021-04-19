/*
Transforms detection results to the correct scales and renders them into an image
*/
#include <iostream>
#include <fstream>
#include <cstdio>
#include <cstdlib>
#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>


#define WINDOW_WIDTH	21
#define WINDOW_HEIGTH	21

using namespace std; 
using namespace cv;


int loadData( const char* name, int *data);

int main( int argc, char* argv[]){

	Mat image, image2;
	image = imread("foto.png", CV_8U);
	image2 = imread("foto.png");
	uchar *fi=image.ptr();
	
	
	
	imshow( "CAMERA", image);
	waitKey(2000);
	
	int table[3*1024];	
	int len = loadData("out-orig", table);
	
	cout<< len/3<< endl;
	/*
	for(int x = 0; x < image.cols-WINDOW_WIDTH-1; x++){
		printf("%02x", fi[53*image.cols +x]);
		if((x%16)==15) printf("\n");
	}
	//*/
	
	for(int i = 0; i < len; i+=3){
		
		float x = table[i];
		float y = table[i+1];
		int col = table[i+2];
		int s = table[i+2];
		float width = WINDOW_WIDTH;
		float height = WINDOW_HEIGTH;
		
		
		
		//printf("%f %f  %d\t\t", y, x, s);
		while(s > 0){
			x= x*6.0/5.0;
			y= y*6.0/5.0;
			width = width *6.0/5.0;
			height = height*6.0/5.0;
			s--;
		}
		//printf("%f %f  %d\n", y, x, s);
		
		Point pt1;
		Point pt2;
		pt1.x = x;
		pt1.y = y;
		pt2.x = x+width;
		pt2.y = y+height;
		rectangle(image2, pt1, pt2, CV_RGB(255,0,0));
			
	}
	
	
	len = loadData("out", table);
	
	cout<< len/3<< endl;
	/*
	for(int x = 0; x < image.cols-WINDOW_WIDTH-1; x++){
		printf("%02x", fi[53*image.cols +x]);
		if((x%16)==15) printf("\n");
	}
	//*/
	
	for(int i = 0; i < len; i+=3){
		
		float x = table[i];
		float y = table[i+1];
		int col = table[i+2];
		int s = table[i+2];
		float width = WINDOW_WIDTH;
		float height = WINDOW_HEIGTH;
		bool was_s = s>0 ? 1:0;
		if(was_s>0)
			printf("%f %f  %d\t\t", y, x, s);
		while(s > 0){
			x= x*6.0/5.0;
			y= y*6.0/5.0;
			width = width *6.0/5.0;
			height = height*6.0/5.0;
			s--;
		}
		if(was_s)
			printf("%f %f  %d\n", y, x, s);
		
		Point pt1;
		Point pt2;
		pt1.x = x;
		pt1.y = y;
		pt2.x = x+width;
		pt2.y = y+height;
		if(was_s)
			rectangle(image2, pt1, pt2, CV_RGB(0,0,255));
		else
			rectangle(image2, pt1, pt2, CV_RGB(0,255,0));
			
	}


	imshow( "CAMERA", image2);
	waitKey();
	
	return 0;
}


int loadData( const char* name, int *data){

	int position = 0;	
	int64_t number;		
	fstream fp;
	
	fp.open(name,fstream::in|fstream::app);
	
	if(fp.is_open()){
  		while (fp >> hex >> number){
  			data[position++] = (number)&0x1fff;
  			data[position++] = (number>>13)&0x1fff;
			data[position++] = (number>>27)&0xf;
		}
	}
	fp.close();
	return position;
}

