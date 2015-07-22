#!/bin/bash

# version of your package
VERSION_osmosdr=${VERSION_osmosdr:-1.3}

# dependencies of this recipe
DEPS_osmosdr=(rtlsdr)

# url of the package
URL_osmosdr=

# md5 of the package
MD5_osmosdr=

# default build path
BUILD_osmosdr=$BUILD_PATH/osmosdr

# default recipe path
RECIPE_osmosdr=$RECIPES_PATH/osmosdr

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_osmosdr() {
	mkdir -p $BUILD_PATH/build-gnuradio
	export ANDROID_STANDALONE_TOOLCHAIN=$BUILD_PATH/build-gnuradio/android-toolchain
	if [ ! -d $BUILD_PATH/build-gnuradio/android-toolchain ]; then
		$ANDROIDNDK/build/tools//make-standalone-toolchain.sh --stl=gnustl --arch=arm \
		--platform=android-$ANDROIDAPI --abis=armeabi-v7a --install-dir=$ANDROID_STANDALONE_TOOLCHAIN
	fi
	cd $BUILD_osmosdr
	if [ ! -d gr-osmosdr ]; then
		git clone git://git.osmocom.org/gr-osmosdr 

	fi
	if [ -f .patched ]; then
		# no patch needed
		return
	fi
	try patch -p0 < $RECIPE_osmosdr/patches/grc.patch
	touch .patched


}

# function called to build the source code
function build_osmosdr() {
	PATH=$PATH:$ANDROIDSDK/tools

	PATH=$ANDROID_STANDALONE_TOOLCHAIN/bin:$PATH
	export TOOLCHAIN=$BUILD_PATH/gnuradio/gnuradio/cmake/Toolchains/AndroidToolchain.cmake

	PREFIX=$BUILD_PATH/build-gnuradio
	cd $BUILD_osmosdr/gr-osmosdr
	PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig
	mkdir -p build
	cd build
	rm -rf build/*
	cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
  	-DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN \
  	-DENABLE_UHD=False -DENABLE_FCD=False -DENABLE_RFSPACE=False \
  	-DENABLE_RTL=True \
  	-DENABLE_BLADERF=False -DENABLE_HACKRF=False -DENABLE_OSMOSDR=False \
  	-DENABLE_RTL_TCP=False -DENABLE_IQBALANCE=False \
  	-Wno-dev \
  	-DBOOST_ROOT=$PREFIX \
        -DPYTHON_INCLUDE_DIR=$BUILD_PATH/python-install/include/python2.7 \
        -DPYTHON_LIBRARY=$BUILD_PATH/python-install/lib/libpython2.7.so \
  	../
	try make
	try make install
	ls -l $BUILD_PATH/python-install/lib/python2.7/site-packages
	ls -l $BUILD_PATH/python-install/lib/python2.7/
	try cp $BUILD_PATH/build-gnuradio/lib/libgnuradio-osmosdr.so $LIBS_PATH
	try cp -R $BUILD_PATH/build-gnuradio/lib/python2.7/site-packages/osmosdr $BUILD_PATH/python-install/lib/python2.7/site-packages
        ls -l $BUILD_PATH/python-install/lib/python2.7/site-packages
        ls -l $BUILD_PATH/python-install/lib/python2.7/
		 
}


# function called after all the compile have been done
function postbuild_osmosdr() {
	true
}
