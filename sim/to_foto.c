/*
Transforms an image from jpeg format to hexadecimal string for simulation in vhdl
*/

#include <iostream>
#include <fstream>
#include <cstdio>
#include <cstdlib>
#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>


using namespace std; 
using namespace cv;


int main( int argc, char* argv[]){

	Mat image;
	image = imread("foto.png", CV_8U);
	
	uchar *fi=image.ptr();
	cout << "width:" << image.cols << endl;
	cout << "rows: " << image.rows << endl;
	
	imshow( "CAMERA", image);
	waitKey(1000);
	
	FILE * fp;
		
	fp = fopen ("foto","w");
	
	for(int y=0;y < image.rows;y++)
		for(int x=0; x < image.cols; x+=4){
			fprintf (fp, "%02X%02X%02X%02X\n",fi[y*image.cols+x+3],fi[y*image.cols+x+2],fi[y*image.cols+x+1],fi[y*image.cols+x]);
		}  		
	
	fclose (fp);
	
	return 0;
}
