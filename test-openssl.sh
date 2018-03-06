#!/bin/bash

# Download and build libcurl, openssl and zlib for Android using Crystax NDK r7
# Must be run on 32 bit Linux as the Crystax r7 NDK doesn't support 64 bit hosts
# Tested on Ubuntu 14.04

# Make the working directory
cd android-build
ROOT_DIR=`pwd -P`
echo Building curl for Android in $ROOT_DIR

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

# Download and build openssl
cd openssl-1.0.2n/

./Configure \
	android-armv7 \
	--shared \
	--with-zlib-include=${SYSROOT}/usr/include \
	--with-zlib-lib=${SYSROOT}/usr/lib \
	--with-ca-path="/data/ssl/certs" \
	--prefix=${OUTPUT_DIR} \
	CFLAGS="-v --sysroot=$SYSROOT -mandroid -march=$ARCH -mfloat-abi=softfp -mfpu=neon -mthumb" \
	CPPFLAGS="$CFLAGS -DANDROID -mthumb -mfloat-abi=softfp -mfpu=neon -march=$ARCH -I${OUTPUT_DIR}/include -I${SYSROOT}/include" \
	LDFLAGS="-march=$ARCH -Wl,--fix-cortex-a8 -L${OUTPUT_DIR}/lib -L${SYSROOT}/lib"

make clean
make build_crypto build_ssl
#make install

# Copy zlib lib and includes to output directory
cp libssl.so* $OUTPUT_DIR/lib/
cp libcrypto.so* $OUTPUT_DIR/lib/ 
cp -LR include/openssl $OUTPUT_DIR/include/
cd ..



