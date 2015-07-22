#!/bin/bash


# version of your package
VERSION_libusb=${VERSION_libusb:-1.3}

# dependencies of this recipe
DEPS_libusb=()

# url of the package
URL_libusb=

# md5 of the package
MD5_libusb=

# default build path
BUILD_libusb=$BUILD_PATH/libusb/

# default recipe path
RECIPE_libusb=$RECIPES_PATH/libusb

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_libusb() {
	mkdir -p $BUILD_PATH/build-gnuradio
	export ANDROID_STANDALONE_TOOLCHAIN=$BUILD_PATH/build-gnuradio/android-toolchain
	if [ ! -d $BUILD_PATH/build-gnuradio/android-toolchain ]; then
		$ANDROIDNDK/build/tools//make-standalone-toolchain.sh --stl=gnustl --arch=arm \
		--platform=android-$ANDROIDAPI --abis=armeabi-v7a --install-dir=$ANDROID_STANDALONE_TOOLCHAIN
	fi
	cd $BUILD_libusb
	if [ ! -d libusb ]; then
		git clone https://github.com/libusb/libusb.git
	fi
		
}

# function called to build the source code
function build_libusb() {
	export ANDROID_STANDALONE_TOOLCHAIN=$BUILD_PATH/build-gnuradio/android-toolchain
	export PATH=$ANDROID_STANDALONE_TOOLCHAIN/bin:$PATH
	export ANDROID_SDK=$ANDROIDSDK
	export PATH=$PATH:$ANDROID_SDK/tools
	cd $BUILD_libusb/libusb
	cd android/jni
	$ANDROIDNDK/ndk-build
	cp $BUILD_libusb/libusb/android/libs/armeabi-v7a/libusb1.0.so $BUILD_PATH/build-gnuradio/lib/libusb.0.so
	cp $BUILD_libusb/libusb/libusb/libusb.h $BUILD_PATH/build-gnuradio/include

}

# function called after all the compile have been done
function postbuild_libusb() {
	true
}
