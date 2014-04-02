#uncomment this line if a local cl.hpp is required
#LOCAL_CL_HPP=-DUSE_LOCAL_CL_HPP

INCLUDE_PATH = -I/usr/local/include -I/opt/AMDAPP/include -I/usr/local/NVIDIA_OpenCL_SDK/src/NVIDIA\ GPU\ Computing\ SDK/OpenCL/common/inc/

LIB_PARTIO_A_PATH=

#If a path for partio is provided then define USE_PARTIO
ifneq ($(LIB_PARTIO_A_PATH),)
  DEFINES=-DUSE_PARTIO
endif

MAC_INCLUDE_PATH = -I/usr/local/include 

LIB_PATH = -L/usr/local/lib -L/opt/AMDAPP/lib/x86_64
LIBS = -lOpenCL

MAC_LIB_PATH = -L/usr/local/lib
MAC_LIBS = -framework OpenCL

FLAGS = --std=c++11 -g -Wfatal-errors -Wall -Wno-deprecated-declarations $(LOCAL_CL_HPP)
MAC_FLAGS = --std=c++11 -g -Wfatal-errors -Wall -Wextra -pedantic -Wno-deprecated-declarations $(LOCAL_CL_HPP)

OUT_DIR = bin/

LIBRARY_FILES = 						\
	libclsph/sph_simulation.cpp 				\
	libclsph/file_save_delegates/houdini_file_saver.cpp 	\
	util/cl_boilerplate.cpp 				\
	libclsph/collision_volumes_loader.cpp 			\
	util/houdini_geo/HoudiniFileDumpHelper.cpp		\

_OBJECT_FILES =				\
	sph_simulation.o		\
	houdini_file_saver.o 		\
	cl_boilerplate.o		\
	collision_volumes_loader.o	\
	HoudiniFileDumpHelper.o		\

PROP_FOLDERS = fluid_properties simulation_properties scenes
KERNEL_FOLDERS = libclsph/kernels libclsph/common

OBJECT_FILES = $(patsubst %, $(OUT_DIR)%, $(_OBJECT_FILES))

all: example/particles.cpp all_lib
	g++ $(INCLUDE_PATH) -I./libclsph $(LIB_PATH) $(FLAGS)   example/particles.cpp -L./bin -lclsph $(LIBS) $(DEFINES) $(LIB_PARTIO_A_PATH) -o $(OUT_DIR)example.out -lz
	cp -r $(PROP_FOLDERS) $(OUT_DIR)

all_lib: $(LIBRARY_FILES)
	g++ -c $(INCLUDE_PATH) $(LIB_PATH) $(FLAGS)  $(LIBRARY_FILES) $(DEFINES) $(LIB_PARTIO_A_PATH) $(LIBS) -lz
	mkdir -p $(OUT_DIR)
	mv $(_OBJECT_FILES) $(OUT_DIR)
	ar rcs $(OUT_DIR)libclsph.a $(OBJECT_FILES)
	cp -r $(KERNEL_FOLDERS) $(OUT_DIR)

mac: example/particles.cpp mac_lib
	g++ $(MAC_INCLUDE_PATH) -I./libclsph $(MAC_LIB_PATH) $(MAC_FLAGS)    example/particles.cpp -L./bin -lclsph $(DEFINES) $(LIB_PARTIO_A_PATH) $(MAC_LIBS) -o $(OUT_DIR)example.out -lz
	cp -r $(PROP_FOLDERS) $(OUT_DIR)

mac_lib: $(LIBRARY_FILES)
	g++ -c $(MAC_INCLUDE_PATH) $(MAC_LIB_PATH) $(MAC_FLAGS)  $(LIBRARY_FILES) $(DEFINES) $(LIB_PARTIO_A_PATH)  $(MAC_LIBS) -lz
	mkdir -p $(OUT_DIR)
	mv $(_OBJECT_FILES) $(OUT_DIR)
	ar rcs $(OUT_DIR)libclsph.a $(OBJECT_FILES)
	cp -r $(KERNEL_FOLDERS) $(OUT_DIR)

libclsph.a: mac_lib

clean: 
	rm $(OBJECT_FILES)

clobber: clean
	rm $(OUT_DIR)libclsph.a $(OUT_DIR)example.out
