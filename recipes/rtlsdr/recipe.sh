#!/bin/bash

# version of your package
VERSION_rtlsdr=${VERSION_rtlsdr:-1.3}

# dependencies of this recipe
DEPS_rtlsdr=(libusb gnuradio)

# url of the package
URL_rtlsdr=

# md5 of the package
MD5_rtlsdr=

# default build path
BUILD_rtlsdr=$BUILD_PATH/rtlsdr

# default recipe path
RECIPE_rtlsdr=$RECIPES_PATH/rtlsdr

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_rtlsdr() {
	mkdir -p $BUILD_PATH/build-gnuradio
	export ANDROID_STANDALONE_TOOLCHAIN=$BUILD_PATH/build-gnuradio/android-toolchain
	if [ ! -d $BUILD_PATH/build-gnuradio/android-toolchain ]; then
		$ANDROIDNDK/build/tools//make-standalone-toolchain.sh --stl=gnustl --arch=arm \
		--platform=android-$ANDROIDAPI --abis=armeabi-v7a --install-dir=$ANDROID_STANDALONE_TOOLCHAIN
	fi
	cd $BUILD_rtlsdr
	if [ ! -d rtl-sdr ]; then
		git clone  git://git.osmocom.org/rtl-sdr.git
	#	git clone https://github.com/trondeau/rtl-sdr.git 

	fi
	if [ -f .patched ]; then
	# no patch needed
		return
	fi
	try patch -p0 < $RECIPE_rtlsdr/patches/android.patch
	touch .patched
		
}

# function called to build the source code
function build_rtlsdr() {
	PATH=$PATH:$ANDROIDSDK/tools

	PATH=$ANDROID_STANDALONE_TOOLCHAIN/bin:$PATH
	export TOOLCHAIN=$BUILD_PATH/gnuradio/gnuradio/cmake/Toolchains/AndroidToolchain.cmake

	PREFIX=$BUILD_PATH/build-gnuradio
	cd $BUILD_rtlsdr/rtl-sdr
	mkdir -p build
	rm -rf build/*

	cd build

	OLD_MAKE=$MAKE
	unset MAKE

	cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
  	-DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN \
  	-DLIBUSB_INCLUDE_DIR=$PREFIX/include \
  	-DLIBUSB_LIBRARIES=$PREFIX/lib/libusb.0.so \
	-Wno-dev \
   	../

	cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
  	-DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN \
    	-DLIBUSB_INCLUDE_DIR=$PREFIX/include \
      	-DLIBUSB_LIBRARIES=$PREFIX/lib/libusb.0.so \
	-Wno-dev \
         ../

	 MAKE=$OLD_MAKE
	 unset OLD_MAKE

	try make
	try make install

	try cp $BUILD_PATH/build-gnuradio/lib/librtlsdr.so $LIBS_PATH
}
# function called after all the compile have been done
function postbuild_rtlsdr() {
	true
}
