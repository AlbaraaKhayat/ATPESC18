#include "cuda.h"

#include <stdio.h>
#include <stdlib.h>

__global__ void simpleKernel(int N, float *d_a, float *d_b){
	   
  // Convert thread and thread-block indices into array index 
  const int n  = threadIdx.x + blockDim.x*blockIdx.x;
	   
  // If index is in [0,N-1] add entries
  if(n<N)
    d_a[N-1-n] = d_b[n];
}

int main(int argc,char **argv){
  int N = 512; // size of array for this DEMO
     // HOST array
  float *h_a = (float*) calloc(N, sizeof(float));
  float *h_b = (float*) calloc(N, sizeof(float)); 
     // Allocate DEVICE array
  float *d_a, *d_b; 
  cudaMalloc((void**) &d_a, N*sizeof(float));
  cudaMalloc((void**) &d_b, N*sizeof(float));
  dim3 dimBlock(512,1,1);          // 512 threads per thread-block
  dim3 dimGrid((N+511)/512, 1, 1); // Enough thread-blocks to cover N
  
    // Init. HOST array    
  for(int n=0;n<N;++n){
      h_b[n] = n;
  }
  cudaMemcpy(d_b, h_b, N*sizeof(float), cudaMemcpyDeviceToHost);    
  // Queue kernel on DEVICE
  simpleKernel <<< dimGrid, dimBlock >>> (N, d_a, d_b);
    


  // Transfer result from DEVICE to HOST
  cudaMemcpy(h_a, d_a, N*sizeof(float), cudaMemcpyDeviceToHost);
    
  // Print out result
  for(int n=0;n<N;++n) printf("h_a[%d] = %f\n", n, h_a[n]);
}
