#!/bin/bash

# version of your package
VERSION_boost4gnuradio=1.58.0

# dependencies of this recipe
DEPS_boost4gnuradio=(python)

# url of the package
URL_boost4gnuradio=http://sourceforge.net/projects/boost/files/boost/$VERSION_boost4gnuradio/boost_1_58_0.tar.bz2

# md5 of the package
MD5_boost4gnuradio=b8839650e61e9c1c0a89f371dd475546

# default build path
BUILD_boost4gnuradio=$BUILD_PATH/boost4gnuradio/$(get_directory $URL_boost4gnuradio)

# default recipe path
RECIPE_boost4gnuradio=$RECIPES_PATH/boost4gnuradio

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_boost4gnuradio() {
	mkdir -p $BUILD_PATH/build-gnuradio
	export ANDROID_STANDALONE_TOOLCHAIN=$BUILD_PATH/build-gnuradio/android-toolchain
	if [ ! -d $BUILD_PATH/build-gnuradio/android-toolchain ]; then
		$ANDROIDNDK/build/tools//make-standalone-toolchain.sh --stl=gnustl --arch=arm \
		--platform=android-$ANDROIDAPI --abis=armeabi-v7a --install-dir=$ANDROID_STANDALONE_TOOLCHAIN
	fi
}

# function called to build the source code
function build_boost4gnuradio() {
	cd $BUILD_boost4gnuradio
	if [ ! -f $BUILD_PATH/build-gnuradio/lib/libboost_wserialization.a ]; then
	cp $RECIPE_boost4gnuradio/user-config.jam ./tools/build/src/user-config.jam
	try ./bootstrap.sh --with-python=$HOSTPYTHON --with-python-root=$BUILD_PATH/python-install --with-python-version=2.7
	try ./b2 --clean --ignore-site-config
	./b2 \
	   --without-container --without-context \
	  --without-coroutine --without-graph --without-graph_parallel \
	  --without-iostreams --without-locale --without-log --without-math \
	  --without-mpi --without-signals --without-timer --without-wave \
	  --ignore-site-config \
	    link=static runtime-link=static threading=multi threadapi=pthread \
	    target-os=linux --stagedir=boost_android --build-dir=boost_android \
	    stage

	 ./b2 \
	  --without-container --without-context \
	  --without-coroutine --without-graph --without-graph_parallel \
	  --without-iostreams --without-locale --without-log --without-math \
	  --without-mpi --without-signals --without-timer --without-wave \
	  --ignore-site-config \
	  link=static runtime-link=static threading=multi threadapi=pthread \
	  target-os=linux --stagedir=boost_android --build-dir=boost_android \
	  --prefix=$BUILD_PATH/build-gnuradio install
	fi  
#        try cp $BUILD_boost4gnuradio/boost_android/lib/* $LIBS_PATH	  
}

# function called after all the compile have been done
function postbuild_boost4gnuradio() {
	true
}
