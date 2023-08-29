#ifndef __CUDA_SAMP2_H__
#define __CUDA_SAMP2_H__

#include <string>
#include <stdio.h>
#include <cuda_runtime.h>
#include <vector_types.h>
#include <vector_functions.h>
#include <device_launch_parameters.h>

cudaError_t addWithCuda2(int* c_dev, const int* a_dev, const int* b_dev, unsigned int size, std::string* error_message);
void addWithCpu(int* c, const int* a, const int* b, unsigned int size, std::string* error_message);

#endif


