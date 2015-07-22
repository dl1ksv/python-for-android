#!/bin/bash


# version of your package
VERSION_fftw=${VERSION_fftw:-3.3.4}

# dependencies of this recipe
DEPS_fftw=()

# url of the package
URL_fftw=ftp://ftp.fftw.org/pub/fftw/fftw-$VERSION_fftw.tar.gz

# md5 of the package
MD5_fftw=2edab8c06b24feeb3b82bbb3ebf3e7b3

# default build path
BUILD_fftw=$BUILD_PATH/fftw/$(get_directory $URL_fftw)

# default recipe path
RECIPE_fftw=$RECIPES_PATH/fftw

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_fftw() {
	mkdir -p $BUILD_PATH/build-gnuradio
	export ANDROID_STANDALONE_TOOLCHAIN=$BUILD_PATH/build-gnuradio/android-toolchain
	if [ ! -d $BUILD_PATH/build-gnuradio/android-toolchain ]; then
		$ANDROIDNDK/build/tools//make-standalone-toolchain.sh --stl=gnustl --arch=arm \
		--platform=android-$ANDROIDAPI --abis=armeabi-v7a --install-dir=$ANDROID_STANDALONE_TOOLCHAIN
	fi
}

# function called to build the source code
function build_fftw() {
	if [ ! -f $BUILD_PATH/build-gnuradio/lib/libfftw3f.a ];then
	cd $BUILD_fftw
	export PATH=$ANDROID_STANDALONE_TOOLCHAIN/bin:$PATH
	export SYS_ROOT="$ANDROID_STANDALONE_TOOLCHAIN/sysroot" 
	export CC="arm-linux-androideabi-gcc --sysroot=$SYS_ROOT" 
	export LD="arm-linux-androideabi-ld" 
	export AR="arm-linux-androideabi-ar" 
	export RANLIB="arm-linux-androideabi-ranlib" 
	export STRIP="arm-linux-androideabi-strip" 
	mkdir -p build
	OLD_MAKE=$MAKE
	unset MAKE
	cd build
	../configure --enable-single --enable-static --enable-threads \
	    --enable-float  --enable-neon \
	    --host=armv7-eabi --build=x86_64-linux \
	    --prefix=$BUILD_PATH/build-gnuradio \
	      LIBS="-lc -lgcc -march=armv7-a -mfloat-abi=softfp -mfpu=neon" \
	      CC="arm-linux-androideabi-gcc -march=armv7-a -mfloat-abi=softfp -mfpu=neon"
	  MAKE=$OLD_MAKE
	  unset OLD_MAKE
	  make
	  make install
	fi	  
#	try cp $BUILD_PATH/build-gnuradio/lib/libfftw3*.a $LIBS_PATH
}

# function called after all the compile have been done
function postbuild_fftw() {
	true
}
