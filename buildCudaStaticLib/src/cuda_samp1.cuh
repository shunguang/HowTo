#ifndef __CUDA_SAMP1_H__
#define __CUDA_SAMP1_H__

#include <string>
#include <stdio.h>
#include <cuda_runtime.h>
#include <vector_types.h>
#include <vector_functions.h>
#include <device_launch_parameters.h>

cudaError_t addWithCuda(int* c, const int* a, const int* b, unsigned int size, std::string* error_message);

#endif


