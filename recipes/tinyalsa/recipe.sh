#!/bin/bash

# version of your package
VERSION_tinyalsa=${VERSION_tinyalsa:-1.3}

# dependencies of this recipe
DEPS_tinyalsa=(gnuradio)

# url of the package
URL_tinyalsa=

# md5 of the package
MD5_tinyalsa=

# default build path
BUILD_tinyalsa=$BUILD_PATH/tinyalsa

# default recipe path
RECIPE_tinyalsa=$RECIPES_PATH/tinyalsa

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_tinyalsa() {
	cd $BUILD_tinyalsa
	if [ ! -d $BUILD_tinyalsa/gr-tinyalsa ]; then
		git clone https://github.com/dl1ksv/gr-tinyalsa.git
	fi
}

# function called to build the source code
function build_tinyalsa() {
	ANDROID_STANDALONE_TOOLCHAIN=$BUILD_PATH/build-gnuradio/android-toolchain
	PATH=$ANDROID_STANDALONE_TOOLCHAIN/bin:$PATH
	ANDROID_SDK=$ANDROIDSDK
	PATH=$PATH:$ANDROID_SDK/tools
	PREFIX=$BUILD_PATH/build-gnuradio
	cd $BUILD_tinyalsa/gr-tinyalsa

	if [ ! -f $BUILD_PATH/build-gnuradio/lib/libgnuradio-tinyalsa.so ]; then
		mkdir -p build
		rm -rf build/*
		cd build
		OLD_MAKE=$MAKE
		unset MAKE
		cmake \
   		-DCMAKE_INSTALL_PREFIX=$PREFIX \
  		-DCMAKE_TOOLCHAIN_FILE=$BUILD_PATH/gnuradio/gnuradio/cmake/Toolchains/AndroidToolchain.cmake \
    		-DBOOST_ROOT=$PREFIX \
    		-Wno-dev \
		-DPYTHON_INCLUDE_DIR=$BUILD_PATH/python-install/include/python2.7 \
		-DPYTHON_LIBRARY=$BUILD_PATH/python-install/lib/libpython2.7.so \
    		../

		make 
		make install
		MAKE=$OLD_MAKE
		unset OLD_MAKE

	fi
	try cp $BUILD_PATH/build-gnuradio/lib/libgnuradio-tinyalsa.so $LIBS_PATH
	try cp -R $BUILD_PATH/build-gnuradio/lib/python2.7/site-packages/tinyalsa $BUILD_PATH/python-install/lib/python2.7/site-packages/tinyalsa
}


# function called after all the compile have been done
function postbuild_tinyalsa() {
	true
}
