/*
Reference implementation of the detector
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

// počet příznaků v klasifikátoru, pro aktuální klasifikátor 1024
#define FEATURE_COUNT	1024
// počet vyhodnocovaných příznaků, možno měnit a tím ovlivňovat chování detekce
#define FEATURE_LIMIT	484
// velikost skenovacího okna klasifikátoru, pro aktuální klasifikátor 21x21
#define WINDOW_WIDTH	90
#define WINDOW_HEIGTH	24
//hodnota posledního tresholdu, možno měnit a tím ovlivňovat chování detekce
#define FINAL_THRESHOLD 0x20000		//0x00f00	//0x00c00
#define DEFAULT_SUM		0x20000		// 0x01000 0x20000	

#define DETECT_STEP_X 	1
#define DETECT_STEP_Y	1

#define SCALE_RATIO		(5.0/6.0)

//****************************************************************
void loadData( const char* name, int *data);
int rank( int data[9], int pos);
//****************************************************************

int main( int argc, char* argv[]){

	Mat image, image2;
	image = imread("foto.png", CV_8U);
	uchar *fi=image.ptr();
	cout<<"Resolution: "<<image.rows<<" x "<<image.cols<< endl;
	
	// 	načítaní tabulek s hodnotami, jsou použity stejné soubory které slouží pro vstup simulaci v modelSim
	int table[17*FEATURE_COUNT];	
	int instruct[FEATURE_COUNT];
	int threshold[FEATURE_COUNT];
	loadData("table", table);
	loadData("instruct", instruct);
	loadData("treshold", threshold);

	int max = 0;
	int max_x = 0;
	int max_y = 0;	
	int max_s = 0;
	int cnt = 0;
	
 	//Point2f pt(image.cols/2.0, image.rows/2.0);
	//Mat r = getRotationMatrix2D(pt, 0.0, 1.0);
	//warpAffine(image, image, r, Size(image.cols, image.rows));
	
	//resize(image, image, Size(), 2.0, 2.0, INTER_LINEAR);
	
	image.copyTo(image2);
	
	for(int scale = 0;scale <1; scale++){
		uchar *fi=image.ptr();
	
		// pro všechny pozice skenovacího okna v obraze
		for (int y =0; y<image.rows-WINDOW_HEIGTH-1; y+=DETECT_STEP_Y){
			for(int x =0;x < image.cols-WINDOW_WIDTH-1; x+=DETECT_STEP_X){
				int suma = DEFAULT_SUM;			
				for(int i =0; i < FEATURE_LIMIT; i++){
					// nactení instrukce pro vyhodnocení priznaku
					int i_posX = (instruct[i] >> 17) & 0x07F;
					int i_posy = (instruct[i] >> 10) & 0x07F;
					int i_rankA = (instruct[i] >> 4) & 0x0F;
					int i_rankB = (instruct[i] >> 0) & 0x0F;
					int i_dsp = (instruct[i] >> 8) & 0x03;
				
					//if(y == 51 && x == 350 && i==2)printf("%d  %d\n", y+i_posy,x+i_posX);
				
					// nactení bloku 6x6 z obrazu 
					int data6[6][6];				
					for(int y_pos = 0; y_pos < 6; y_pos++){
						for(int x_pos = 0; x_pos < 6; x_pos++){
							data6[y_pos][x_pos] = fi[(y+y_pos + i_posy)*image.cols +(x+x_pos + i_posX)];	
							//if(y == 51 && x == 350 && i==2)printf("%02X\t",data6[y_pos][x_pos]);					
						}		
						//if(y == 51 && x == 350 && i==2)printf("\n");			
					}
					//if(y == 51 && x == 350 && i==2)printf("\n");
				
					// dsp operace, uprava na blok 3x3	
					int data3[9];
					for(int y_pos = 0; y_pos < 3; y_pos++){
						for(int x_pos = 0; x_pos < 3; x_pos++){
							switch(i_dsp){
								case 0 :
									data3[3*y_pos+x_pos] = data6[y_pos][x_pos];
									break;
								case 1 :
									data3[3*y_pos+x_pos] = (data6[y_pos][2*x_pos] + data6[y_pos][2*x_pos+1])/2;
									break;
								case 2 :
									data3[3*y_pos+x_pos] = (data6[2*y_pos][x_pos] + data6[2*y_pos+1][x_pos])/2;
									break;
								case 3 :
									data3[3*y_pos+x_pos] = 	(data6[2*y_pos][2*x_pos] + data6[2*y_pos][2*x_pos+1] +
															data6[2*y_pos+1][2*x_pos] + data6[2*y_pos+1][2*x_pos+1])/4;
									break;	
								default:
									break;
							}
						}
					}
					/*if(y == 51 && x == 350 && i==2){
						for(int y_pos = 0; y_pos < 3; y_pos++){
							for(int x_pos = 0; x_pos < 3; x_pos++){
								printf("%02X\t",data3[3*y_pos+x_pos]);
							}
							printf("\n");
						}
					}*/
				
				
					// vypocet LRD priznaku
					int feature = rank(data3, i_rankA) - rank(data3, i_rankB) + 8;				
				
				
					// vypocet sumy priznaku
					suma = (table[i*17+ feature] + suma + 0x03ff00) & 0x03ffff;
					/*if(y == 51 && x == 350){
						printf("%3d %08X\n",i,suma);	
					}*/
					// pokud je suma mensi nez prah, pozici zamítneme, neobsahuje hledaný objekt
					if( suma < threshold[i])
						break;
					
					// pokud vyhodnotíme pozitivne vsechny priznaky a suma je vetsi nez prah, na pozici se nachazi hledany objekt
					if(i >= (FEATURE_LIMIT-1) && suma >= FINAL_THRESHOLD){				
						printf("%08X\tx:%d\ty:%d\tindex:%d\t%05X %d\n", ((y<<13)+x),x,y,i, suma, scale);//*/
						Point pt1;
						Point pt2;
						float px = x;
						float py = y;
						float pw = WINDOW_WIDTH;
						float ph = WINDOW_HEIGTH;
						for(int s_level = 0; s_level < scale; s_level++){
							px= px/SCALE_RATIO;
							py= py/SCALE_RATIO;
							pw = pw/SCALE_RATIO;
							ph = ph/SCALE_RATIO;
						}
						
						pt1.x = px;
						pt1.y = py;
						pt2.x = px+pw;
						pt2.y = py+ph;
						rectangle(image2, pt1, pt2, Scalar(255,255,255));
						cnt++;
						if(suma > max){
							max = suma;	
							max_x = x;
							max_y = y;
							max_s = scale;
						}
					}
				}
			}
		
		}
		resize(image, image, Size(), SCALE_RATIO, SCALE_RATIO, INTER_LINEAR);
	}
	cout<< "x:"<<max_x << "\ty:" << max_y <<"\tscale:"<<max_s<< "\t" << hex<<max<<" count:"<<dec<<cnt<<endl;

	
	imshow( "CAMERA", image2);
	waitKey();
	
	return 0;
}

/***************************************************
načítaní tabulek s hodnotami, jsou použity stejné soubory které slouží pro vstup simulaci v modelSim
*/
void loadData( const char* name, int *data){

	int position = 0;	
	int number;		
	fstream fp;
	
	fp.open(name,fstream::in|fstream::app);
	if(fp.is_open()){
  		while (fp >> hex >> number)
			  {
				data[position++] = number;
			  }
	}
	fp.close();
}
/***************************************************
vypočet ranku => kolik pixelů z okolí je menších než daný pixel 
*/
int rank( int data[9], int pos){
	int sum = 0;
	for(int i = 0; i<9;i++){
		if(data[pos] > data[i])
			sum++;
	}
	return sum;
}
