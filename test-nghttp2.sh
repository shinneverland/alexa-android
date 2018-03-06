#!/bin/bash

# Download and build libcurl, openssl and zlib for Android using Crystax NDK r7
# Must be run on 32 bit Linux as the Crystax r7 NDK doesn't support 64 bit hosts
# Tested on Ubuntu 14.04

# Make the working directory
mkdir android-build
cd android-build
ROOT_DIR=`pwd -P`
echo Building curl for Android in $ROOT_DIR

# Download Crystax NDK
#wget https://www.crystax.net/download/android-ndk-r7-crystax-5.beta3-linux-x86.tar.bz2
#tar -xvf android-ndk-r7-crystax-5.beta3-linux-x86.tar.bz2

# NDK environment variables
export NDK_ROOT=$ROOT_DIR/../android-ndk-r14b/
export PATH=$PATH:$NDK_ROOT

# Create standalone toolchain for cross-compiling
$NDK_ROOT/build/tools/make-standalone-toolchain.sh --arch=arm --platform=android-24 --install-dir=ndk-standalone-toolchain
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

OUTPUT_DIR=$SYSROOT/usr/local

####################################################################
# build nghttp2
####################################################################
cd nghttp2

./configure \
     --enable-shared \
     --host=arm-linux-androideabi \
     --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE` \
     --with-xml-prefix="${OUTPUT_DIR}" \
     --without-libxml2 \
     --disable-python-bindings \
     --disable-examples \
	 --prefix=${OUTPUT_DIR} \
     CC="$TOOLCHAIN"/bin/arm-linux-androideabi-clang \
     CXX="$TOOLCHAIN"/bin/arm-linux-androideabi-clang++ \
     CPPFLAGS="-fPIE -I${OUTPUT_DIR}/include" \
     PKG_CONFIG_LIBDIR="${OUTPUT_DIR}/lib/pkgconfig" \
     LDFLAGS="-fPIE -pie -L${OUTPUT_DIR}/lib"

make clean
make
make install



