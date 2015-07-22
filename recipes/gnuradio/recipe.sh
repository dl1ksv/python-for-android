#!/bin/bash


# version of your package
VERSION_gnuradio=3.7.7.1

# dependencies of this recipe
DEPS_gnuradio=(python numpy boost4gnuradio fftw volk )

# url of the package
#URL_gnuradio=http://gnuradio.org/releases/gnuradio/gnuradio-$VERSION_gnuradio.tar.gz
URL_gnuradio=
# md5 of the package
#MD5_gnuradio=ca8e47abcb01edc72014ccabe38123a3

# default build path
BUILD_gnuradio=$BUILD_PATH/gnuradio

# default recipe path
RECIPE_gnuradio=$RECIPES_PATH/gnuradio

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_gnuradio() {
	cd $BUILD_gnuradio
  	if [ ! -d gnuradio ]; then
		git clone --recursive git://git.gnuradio.org/gnuradio.git
	fi
	cd gnuradio
	git checkout android
	# check marker in our source build
	if [ -f .patched ]; then
			# no patch needed
		return
	fi
	try patch -p1 < $RECIPE_gnuradio/patches/gr-vector-blocks.patch
	try patch -p1 < $RECIPE_gnuradio/patches/version.patch
	try patch -p1 < $RECIPE_gnuradio/patches/buf.patch
	touch .patched

}

# function called to build the source code
function build_gnuradio() {
		if [ ! -f $BUILD_PATH/build-gnuradio/lib/libgnuradio-runtime.so ]; then
		export ANDROID_STANDALONE_TOOLCHAIN=$BUILD_PATH/build-gnuradio/android-toolchain
		export PATH=$ANDROID_STANDALONE_TOOLCHAIN/bin:$PATH
		export ANDROID_SDK=$ANDROIDSDK
		export PATH=$PATH:$ANDROID_SDK/tools
		cd $BUILD_gnuradio/gnuradio
		mkdir -p build
		rm -rf build/*
		cd build
		unset MAKE
		PREFIX=$BUILD_PATH/build-gnuradio
		cmake \
		-Wno-dev \
    		-DCMAKE_INSTALL_PREFIX=$PREFIX \
        	-DCMAKE_TOOLCHAIN_FILE=../cmake/Toolchains/AndroidToolchain.cmake \
	    	-DENABLE_INTERNAL_VOLK=Off \
	        -DBOOST_ROOT=$PREFIX \
		-DFFTW3F_INCLUDE_DIRS=$PREFIX/include \
		-DFFTW3F_LIBRARIES=$PREFIX/lib/libfftw3f.a \
		-DFFTW3F_THREADS_LIBRARIES=$PREFIX/lib/libfftw3f_threads.a \
		-DENABLE_DEFAULT=False \
		-DENABLE_GR_LOG=False \
		-DENABLE_VOLK=True \
		-DENABLE_GNURADIO_RUNTIME=True \
		-DENABLE_GR_BLOCKS=True \
		-DENABLE_GR_FFT=True \
		-DENABLE_GR_FILTER=True \
		-DENABLE_GR_ANALOG=True \
		-DENABLE_GR_DIGITAL=True \
		-DENABLE_GR_UHD=False \
		-DENABLE_STATIC_LIBS=False \
		-DENABLE_PYTHON=On \
		-DPYTHON_INCLUDE_DIR=$BUILD_PATH/python-install/include/python2.7 \
		-DPYTHON_LIBRARY=$BUILD_PATH/python-install/lib/libpython2.7.so \
		-DENABLE_GR_LOG=False \
		-DENABLE_DOXYGEN=Off \
		../

		make -j5
		make install
		fi
		try cp $BUILD_PATH/build-gnuradio/lib/lib*.so $LIBS_PATH
		try cp -R $BUILD_PATH/build-gnuradio/lib/python2.7/* $BUILD_PATH/python-install/lib/python2.7/
}

# function called after all the compile have been done
function postbuild_gnuradio() {
	true
}
