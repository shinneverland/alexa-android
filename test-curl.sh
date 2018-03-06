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
# Download and build libcurl
wget http://curl.haxx.se/download/curl-7.58.0.tar.gz
tar -xvf curl-7.58.0.tar.gz 
####################################################################
cd curl-7.58.0
#export CFLAGS="-v --sysroot=$SYSROOT -mandroid -march=$ARCH -mfloat-abi=softfp -mfpu=neon -mthumb"
#export CPPFLAGS="$CFLAGS -DANDROID -DCURL_STATICLIB -mthumb -mfloat-abi=softfp -mfpu=neon -march=$ARCH -I${OUTPUT_DIR}/include/ -I${TOOLCHAIN}/include"
#export LDFLAGS="-march=$ARCH -Wl,--fix-cortex-a8 -L${OUTPUT_DIR}/lib"

./configure --host=arm-linux-androideabi --enable-shared --disable-static \
	--disable-dependency-tracking \
	--with-nghttp2=${OUTPUT_DIR} \
	--with-ssl=${OUTPUT_DIR} \
	--with-ca-path="/data/ssl/certs" \
	--enable-ipv6 --enable-http --enable-ftp --disable-file --disable-ldap \
	--disable-ldaps --disable-rtsp --disable-proxy --disable-dict --disable-telnet \
	--disable-tftp --disable-pop3 --disable-imap --disable-smtp --disable-gopher --disable-sspi \
	--disable-manual \
	--target=arm-linux-androideabi \
	--prefix=${OUTPUT_DIR} \
	CFLAGS="-v --sysroot=$SYSROOT -mandroid -march=$ARCH -mfloat-abi=softfp -mfpu=neon -mthumb" \
	CPPFLAGS="$CFLAGS -DANDROID -mthumb -mfloat-abi=softfp -mfpu=neon -march=$ARCH -I${OUTPUT_DIR}/include -I${SYSROOT}/include" \
	LDFLAGS="-march=$ARCH -Wl,--fix-cortex-a8 -L${OUTPUT_DIR}/lib -L${SYSROOT}/lib"
make clean
make
#make install
cp lib/.libs/libcurl.so $OUTPUT_DIR/lib 
cp -LR include/curl $OUTPUT_DIR/include/

cd ..
