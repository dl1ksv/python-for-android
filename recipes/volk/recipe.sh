#!/bin/bash

# version of your package
VERSION_volk=""

# dependencies of this recipe
DEPS_volk=(python boost4gnuradio)

# url of the package
URL_volk=

# md5 of the package
MD5_volk=""

# default build path
BUILD_volk=$BUILD_PATH/volk

# default recipe path
RECIPE_volk=$RECIPES_PATH/volk

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_volk() {
	mkdir -p $BUILD_PATH/build-gnuradio
	export ANDROID_STANDALONE_TOOLCHAIN=$BUILD_PATH/build-gnuradio/android-toolchain
	if [ ! -d $BUILD_PATH/build-gnuradio/android-toolchain ]; then
		$ANDROIDNDK/build/tools//make-standalone-toolchain.sh --stl=gnustl --arch=arm \
		--platform=android-$ANDROIDAPI --abis=armeabi-v7a --install-dir=$ANDROID_STANDALONE_TOOLCHAIN
	fi

	cd $BUILD_volk
  	if [ ! -d volk ]; then
		git clone https://github.com/trondeau/volk.git
	fi
	cd volk
	git checkout android

	cd $BUILD_PATH/volk
	# check marker in our source build
	if [ -f .patched ]; then
		# no patch needed
		return
	fi
	try patch -p0 < $RECIPE_volk/patches/cmakelists.patch
#	try patch -p0 < $RECIPE_volk/patches/lib-cmakelists.patch
	touch .patched
}


# function called to build the source code
function build_volk() {
	if [ ! -f $BUILD_PATH/build-gnuradio/lib/libvolk.a ]; then
		export ANDROID_STANDALONE_TOOLCHAIN=$BUILD_PATH/build-gnuradio/android-toolchain
		export PATH=$ANDROID_STANDALONE_TOOLCHAIN/bin:$PATH
		export ANDROID_SDK=$ANDROIDSDK
		export PATH=$PATH:$ANDROID_SDK/tools
		cd $BUILD_volk/volk
		mkdir -p build
		rm -rf build/*
		cd build
		export CMAKE_TOOLCHAIN_FILE="../cmake/Toolchains/AndroidToolchain.cmake"
		unset MAKE
		cmake	-Wno-dev \
			-DCMAKE_INSTALL_PREFIX=$BUILD_PATH/build-gnuradio \
      			-DCMAKE_TOOLCHAIN_FILE=../cmake/Toolchains/AndroidToolchain.cmake \
            		-DENABLE_ORC=False \
	        	-DPYTHON_EXECUTABLE=/usr/bin/python \
			-DENABLE_STATIC_LIBS=True \
			-DENABLE_TESTING=Off \
		../

	make
	make install
	fi
	try cp $BUILD_PATH/build-gnuradio/lib/libvolk.so $LIBS_PATH
}



# function called after all the compile have been done
function postbuild_volk() {
	true
}
