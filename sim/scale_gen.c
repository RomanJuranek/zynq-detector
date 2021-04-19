/*
Creates detect and scale tables to control row processing by the detector
*/

#include <iostream>
#include <fstream>
#include <cstdio>
#include <cstdlib>
#include <cmath>

using namespace std; 

#define WINDOWS_HEIGTH  24
#define SCALE_HEIGTH	6
#define SCALE_LEVEL		13
#define FRAME_WIDTH		1537

int main(){

	FILE *fp0, *fp1;
		
	fp0 = fopen ("scale","w");
	fp1 = fopen ("detect","w");

	int pos_scale[32] = {0};
	int pos_detect[32] = {0};
	int suma_scale = 0;
	int suma_detect = 0;

	for(int y = 0; y < FRAME_WIDTH+WINDOWS_HEIGTH; y++){
		pos_scale[0]++;
		suma_scale = 0;
		suma_detect = 0;		
		
		//printf("\n%4d  ",y);
		for(int i = 1;i < SCALE_LEVEL; i++){
			//printf("%4d  ", pos_detect[i]);
			if(pos_detect[i] > WINDOWS_HEIGTH){
				pos_detect[i] -=1;
				suma_detect = suma_detect + pow(2,i);				
			}
						
		}
		
		for(int i = 0;i < SCALE_LEVEL; i++){
			if(pos_scale[i] >= SCALE_HEIGTH){
				pos_scale[i]-=6;
				pos_scale[i+1]+=5;
				pos_detect[i+1] += 5;
				suma_scale = suma_scale + pow(2,i);				
			}
		}
		
		
		//printf("%4d:  ",y);	
		printf("%d\t%8X %8X\n", y, suma_scale, suma_detect);
		//printf("\n");	
		if(y<FRAME_WIDTH)
			fprintf (fp0,"%08X\n", suma_scale);
		if(y>WINDOWS_HEIGTH)
			fprintf (fp1,"%08X\n", suma_detect);
		/*	
		fprintf (fp0,"%08X\n", suma_scale);
		fprintf (fp1,"%08X\n", suma_detect);		
		//*/
	}

	fclose(fp0);
	fclose(fp1);
	return 0;
}
