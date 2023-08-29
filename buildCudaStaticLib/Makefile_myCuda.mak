#this Makefile outputs image as a static lib for <PLTF> machine

PROJ_NAME=libMyCuda
include Makefile_app_header.mak

OBJS = \
	$(ODIR_OBJ)/cuda_samp1_a.o \
	$(ODIR_OBJ)/cuda_samp1_b.o \
	$(ODIR_OBJ)/cuda_samp2_a.o \
	$(ODIR_OBJ)/cuda_samp2_b.o

	
default:  directories $(TARGETFILE)

directories:    
	mkdir -p $(CGE_ODIR_ROOT)
	mkdir -p $(ODIR_OBJ)
	mkdir -p $(ODIR_LIB)


#the output lib file name is <$(TARGETFILE)>
$(TARGETFILE) : $(OBJS)
	ar rcu $(TARGETFILE) $(OBJS)
  
$(ODIR_OBJ)/cuda_samp1_a.o: $(SDIR_PROJ)/cuda_samp1.cu $(SDIR_PROJ)/cuda_samp1.cuh
	$(NVCC) -rdc=true -c -o $(ODIR_OBJ)/cuda_samp1_a.o $(SDIR_PROJ)/cuda_samp1.cu

$(ODIR_OBJ)/cuda_samp2_a.o: $(SDIR_PROJ)/cuda_samp2.cu $(SDIR_PROJ)/cuda_samp2.cuh
	$(NVCC) -rdc=true -c -o $(ODIR_OBJ)/cuda_samp2_a.o $(SDIR_PROJ)/cuda_samp2.cu


$(ODIR_OBJ)/cuda_samp1_b.o: $(ODIR_OBJ)/cuda_samp1_a.o
	$(NVCC) -dlink -o $(ODIR_OBJ)/cuda_samp1_b.o $(ODIR_OBJ)/cuda_samp1_a.o -lcudart_static

$(ODIR_OBJ)/cuda_samp2_b.o: $(ODIR_OBJ)/cuda_samp2_a.o
	$(NVCC) -dlink -o $(ODIR_OBJ)/cuda_samp2_b.o $(ODIR_OBJ)/cuda_samp2_a.o -lcudart_static
 

clean:
	\rm -r $(ODIR_OBJ)/*.o $(TARGETFILE)

ranlib:
	\ranlib $(TARGETFILE)

