#!/bin/bash

# Download and build libcurl, openssl and zlib for Android using Crystax NDK r7
# Must be run on 32 bit Linux as the Crystax r7 NDK doesn't support 64 bit hosts
# Tested on Ubuntu 14.04

# Make the working directory
cd android-build
ROOT_DIR=`pwd -P`
echo Building curl for Android in $ROOT_DIR

mkdir alexa_sdk
cd alexa_sdk

# NDK environment variables
export NDK_ROOT=$ROOT_DIR/../android-ndk-r16b/
export PATH=$PATH:$NDK_ROOT

TOOLCHAIN=$ROOT_DIR/ndk-standalone-toolchain

export CMAKE_HOME=$ROOT_DIR/../cmake-3.10.2/bin

# Setup cross-compile environment
export SYSROOT=$TOOLCHAIN/sysroot
export ARCH=armv7
OUTPUT_DIR=${SYSROOT}/usr/local

#$CMAKE_HOME/cmake \
#	-DANDROID_ABI=armeabi-v7a \
#	-DANDROID_NDK=$NDK_ROOT \
#	-DANDROID_ARM_MODE=arm \
#	-DANDROID_ARM_NEON=TRUE \
#	-DCMAKE_ANDROID_STANDALONE_TOOLCHAIN=${TOOLCHAIN} \
#	-DCMAKE_SYSROOT=${TOOLCHAIN}/sysroot \
#	-DCMAKE_PREFIX_PATH=${OUTPUT_DIR} \
#	-DCMAKE_LIBRARY_OUTPUT_DIRECTORY=${OUTPUT_DIR} \
#	-DANDROID_NATIVE_API_LEVEL=21 \
#	-DANDROID_CPP_FEATURES=rtti,exceptions \
#	-DCMAKE_BUILD_TYPE=Debug \
#	-DANDROID_TOOLCHAIN=clang \
#	-DANDROID_PLATFORM=android-21 \
#	-DANDROID_STL=c++_shared \
#	-DGSTREAMER_MEDIA_PLAYER=OFF \
#	-DCURL_LIBRARY=${OUTPUT_DIR}/lib/libcurl.so -DCURL_INCLUDE_DIR=${OUTPUT_DIR}/include \
#	-DCMAKE_TOOLCHAIN_FILE=${NDK_ROOT}/build/cmake/android.toolchain.cmake \
#	$ROOT_DIR/../source/avs-device-sdk


$CMAKE_HOME/cmake \
	-DCMAKE_SYSTEM_NAME=Android \
	-DCMAKE_SYSTEM_VERSION=21 \
	-DCMAKE_ANDROID_ARCH_ABI=armeabi-v7a \
	-DCMAKE_ANDROID_ARM_MODE=ON \
	-DCMAKE_ANDROID_ARM_NEON=ON \
	-DCMAKE_ANDROID_STL_TYPE=c++_shared \
	-DCMAKE_ANDROID_STANDALONE_TOOLCHAIN=${TOOLCHAIN} \
	-DCMAKE_SYSROOT=${TOOLCHAIN}/sysroot \
	-DCMAKE_PREFIX_PATH=${OUTPUT_DIR} \
	-DCMAKE_INCLUDE_PATH=${OUTPUT_DIR}/include:${OUTPUT_DIR}/include/gstreamer-1.0 \
	-DCMAKE_ANDROID_CPP_FEATURES=rtti,exceptions \
	-DCMAKE_BUILD_TYPE=Debug \
	-DCMAKE_INSTALL_PREFIX=${OUTPUT_DIR} \
	-DGSTREAMER_MEDIA_PLAYER=OFF \
	-DPORTAUDIO=ON \
	-DCURL_LIBRARY=${OUTPUT_DIR}/lib/libcurl.so -DCURL_INCLUDE_DIR=${OUTPUT_DIR}/include \
	-DPORTAUDIO_LIB_PATH=${OUTPUT_DIR}/lib/libportaudio.so -DPORTAUDIO_INCLUDE_DIR=${OUTPUT_DIR}/include \
	$ROOT_DIR/../amazon/avs-device-sdk

make all integration
make install
cp -a ${ROOT_DIR}/alexa_sdk/SampleApp/src/SamapleApp ${OUTPUT_DIR}/bin/

