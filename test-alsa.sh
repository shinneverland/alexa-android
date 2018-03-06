!/bin/bash/

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

OUTPUT_DIR=${SYSROOT}/usr/local

####################################################################
# build sqlite-autoconf-3210000
####################################################################
cd alsa-lib-1.1.5
 
./configure \
	--host=arm-linux-androideabi \
	--build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE` \
	--disable-static \
	--enable-shared \
 	--disable-debug \
	--disable-resmgr \
	--enable-aload \
	--enable-mixer \
	--enable-pcm \
	--disable-rawmidi \
	--enable-hwdep \
	--disable-seq \
	--disable-alisp \
	--disable-old-symbols \
	--disable-python \
	--datarootdir=/system/usr/share \
	--with-confdir=/system/usr/share/alsa \
	--with-plugindir=/system/usr/lib/alsa-lib \
	--with-versioned=no \
	--with-debug=no \
	--with-tmpdir=/tmp \
	--with-softfloat=yes \
	--with-libdl=yes \
	--with-pthread=yes \
	--with-librt=no \
	--with-alsa-devdir=/dev/snd \
	--with-aload-devdir=/dev \
	--with-pcm-plugins="plug null empty hooks asym extplug ioplug" \
	--with-ctl-plugins="ext" \
	CFLAGS="-v -mandroid -march=$ARCH -mfloat-abi=softfp -mfpu=neon -mthumb" \
	CPPFLAGS="$CFLAGS -DANDROID -D_GNU_SOURCE -DTHREAD_SAFE_API -mthumb -mfloat-abi=softfp -mfpu=neon -march=$ARCH -I${OUTPUT_DIR}/include -I${SYSROOT}/include" \
	LDFLAGS="-march=$ARCH -Wl,--fix-cortex-a8 -L${OUTPUT_DIR}/lib -L${SYSROOT}/lib"

make clean
make


