#!/bin/bash

# Download and build libcurl, openssl and zlib for Android using Crystax NDK r7
# Must be run on 32 bit Linux as the Crystax r7 NDK doesn't support 64 bit hosts
# Tested on Ubuntu 14.04

# Make the working directory
cd android-build
ROOT_DIR=`pwd -P`
echo Building curl for Android in $ROOT_DIR

# Download Crystax NDK
#wget https://www.crystax.net/download/android-ndk-r7-crystax-5.beta3-linux-x86.tar.bz2
#tar -xvf android-ndk-r7-crystax-5.beta3-linux-x86.tar.bz2

# NDK environment variables
export NDK_ROOT=$ROOT_DIR/../android-ndk-r16b/
export PATH=$PATH:$NDK_ROOT

# Create standalone toolchain for cross-compiling
TOOLCHAIN=$ROOT_DIR/ndk-standalone-toolchain

# Setup cross-compile environment
export PATH=$PATH:$TOOLCHAIN/bin
export SYSROOT=$TOOLCHAIN/sysroot
export ARCH=armv7
export CC=arm-linux-androideabi-gcc
export CXX=arm-linux-androideabi-g++
export AR=arm-linux-androideabi-ar
export AS=arm-linux-androideabi-as
export LD=arm-linux-androideabi-ld
export RANLIB=arm-linux-androideabi-ranlib
export NM=arm-linux-androideabi-nm
export STRIP=arm-linux-androideabi-strip
export CHOST=arm-linux-androideabi

OUTPUT_DIR=${SYSROOT}/usr/local

####################################################################
# build sqlite-autoconf-3210000
####################################################################
cd portaudio

./configure \
	--host=arm-linux-androideabi \
    --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE` \
	--disable-static \
	--enable-shared \
	--enable-debug-output \
	--with-alsa \
	--prefix=${OUTPUT_DIR} \
	CFLAGS="-v --sysroot=$SYSROOT -mandroid -march=$ARCH -mfloat-abi=softfp -mfpu=neon -mthumb -I${OUTPUT_DIR}/include -I${SYSROOT}/usr/include -DPA_LOG_API_CALLS" \
	CPPFLAGS="$CFLAGS -DANDROID" \
	LDFLAGS="-march=$ARCH -Wl,--fix-cortex-a8 -L${OUTPUT_DIR}/lib -L${SYSROOT}/lib"
make clean
make
make install


