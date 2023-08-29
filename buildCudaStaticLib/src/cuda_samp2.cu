#include "cuda_samp2.cuh"


__global__ void addKernel2(int n, int* c, const int* a, const int* b)
{
#if 0  
  int i = threadIdx.x;
  c[i] = a[i] + b[i];
#else
  int index = blockIdx.x * blockDim.x + threadIdx.x;
  int stride = blockDim.x * gridDim.x;
  for (int i = index; i < n; i += stride)
    c[i] = a[i] + b[i];    
#endif
}

//assume a,b,c are dev memo address
cudaError_t addWithCuda2(int* dev_c, const int* dev_a, const int* dev_b, unsigned int size, std::string* error_message)
{
  cudaError_t cuda_status;

  // Launch a kernel on the GPU with one thread for each element.
  int blockSize = 512;
  int numBlocks = (size + blockSize - 1) / blockSize;

  printf("addWithCuda2(): numBlocks=%d, blockSize=%d\n", numBlocks, blockSize);
  addKernel2 << <numBlocks, blockSize >> > (size, dev_c, dev_a, dev_b);
  //addKernel2 << <1, 256 >> > (size, dev_c, dev_a, dev_b);

  // Check for any errors launching the kernel
  cuda_status = cudaGetLastError();
  if (cuda_status != cudaSuccess) {
    *error_message = "addKernel launch failed: " + std::string(cudaGetErrorString(cuda_status));
    goto Error;
  }

  // cudaDeviceSynchronize waits for the kernel to finish, and returns
  // any errors encountered during the launch.
  cuda_status = cudaDeviceSynchronize();
  if (cuda_status != cudaSuccess) {
    *error_message = "cudaDeviceSynchronize returned error code " + std::to_string(cuda_status) + " after launching addKernel!";
    goto Error;
  }

Error:
  return cuda_status;
}


void addWithCpu(int* c, const int* a, const int* b, unsigned int size, std::string* error_message)
{
  for (unsigned int i = 0; i < size; ++i) {
    c[i] = a[i] + b[i];
  }
}

