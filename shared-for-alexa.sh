!/bin/bash/

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
export NDK_ROOT=$ROOT_DIR/../android-ndk-r16b/
export PATH=$PATH:$NDK_ROOT

# Create standalone toolchain for cross-compiling
$NDK_ROOT/build/tools/make-standalone-toolchain.sh --arch=arm --stl=libc++ --platform=android-21 --install-dir=ndk-standalone-toolchain
#$NDK_ROOT/build/tools/make-standalone-toolchain.sh --arch=arm --stl=stlport --platform=android-21 --install-dir=ndk-standalone-toolchain
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

#OUTPUT_DIR=$ROOT_DIR/shared-lib
OUTPUT_DIR=${SYSROOT}/usr/local

#####################################################################
# Download and build zlib
#wget http://zlib.net/zlib-1.2.11.tar.gz
#tar -xvzf zlib-1.2.11.tar.gz
####################################################################

#cd $ZLIB_DIR
#./configure --shared --prefix=${OUTPUT_DIR}
#make
#make install
#cd ..

####################################################################
# Download and build openssl
#wget https://www.openssl.org/source/openssl-1.0.2n.tar.gz
#tar -xvf openssl-1.0.2n.tar.gz 
####################################################################
cd openssl-1.0.2n/
export CPPFLAGS="-mthumb -mfloat-abi=softfp -mfpu=vfp -march=${ARCH}  -DANDROID"
./Configure android-armv7 no-asm no-shared --shared --with-zlib-include=${OUTPUT_DIR}/include --with-zlib-lib=${OUTPUT_DIR}/lib --prefix=${OUTPUT_DIR}
make build_crypto build_ssl
make install
cd ..

####################################################################
# Download and build libcurl
#wget http://curl.haxx.se/download/curl-7.58.0.tar.gz
#tar -xvf curl-7.58.0.tar.gz 
####################################################################
cd curl-7.58.0
#export CFLAGS="-v --sysroot=$SYSROOT -mandroid -march=$ARCH -mfloat-abi=softfp -mfpu=neon -mthumb"
#export CPPFLAGS="$CFLAGS -DANDROID -DCURL_STATICLIB -mthumb -mfloat-abi=softfp -mfpu=neon -march=$ARCH -I${OUTPUT_DIR}/include/ -I${TOOLCHAIN}/include"
#export LDFLAGS="-march=$ARCH -Wl,--fix-cortex-a8 -L${OUTPUT_DIR}/lib"

./configure --host=arm-linux-androideabi --enable-shared --disable-static \
	--disable-dependency-tracking --with-zlib=${OUTPUT_DIR}/lib \
	--with-ssl=${OUTPUT_DIR}/lib --without-ca-bundle --without-ca-path \
	--enable-ipv6 --enable-http --enable-ftp --disable-file --disable-ldap \
	--disable-ldaps --disable-rtsp --disable-proxy --disable-dict --disable-telnet \
	--disable-tftp --disable-pop3 --disable-imap --disable-smtp --disable-gopher --disable-sspi \
	--disable-manual --target=arm-linux-androideabi --prefix=${OUTPUT_DIR} \
	CFLAGS="-v --sysroot=$SYSROOT -mandroid -march=$ARCH -mfloat-abi=softfp -mfpu=neon -mthumb" \
	CPPFLAGS="$CFLAGS -DANDROID -DCURL_STATICLIB -mthumb -mfloat-abi=softfp -mfpu=neon -march=$ARCH -I${OUTPUT_DIR}/include/ -I${TOOLCHAIN}/include" \
	LDFLAGS="-march=$ARCH -Wl,--fix-cortex-a8 -L${OUTPUT_DIR}/lib"

make
make install


cd ..

####################################################################
# build nghttp2
####################################################################
cd nghttp2

./configure \
     --disable-shared \
     --host=arm-linux-androideabi \
     --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE` \
     --with-xml-prefix="${OUTPUT_DIR}" \
     --without-libxml2 \
     --disable-python-bindings \
     --disable-examples \
     --disable-threads \
	 --prefix=${OUTPUT_DIR} \
     CC="$TOOLCHAIN"/bin/arm-linux-androideabi-clang \
     CXX="$TOOLCHAIN"/bin/arm-linux-androideabi-clang++ \
     CPPFLAGS="-fPIE -I${OUTPUT_DIR}/include" \
     PKG_CONFIG_LIBDIR="${OUTPUT_DIR}/lib/pkgconfig" \
     LDFLAGS="-fPIE -pie -L${OUTPUT_DIR}/lib"

make
make install
cd ..

####################################################################
# build sqlite-autoconf-3210000
####################################################################
cd sqlite-autoconf-3210000

./configure \
     --host=arm-linux-androideabi \
     --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE` \
     --with-xml-prefix="${OUTPUT_DIR}" \
	 --prefix=${OUTPUT_DIR} \
     CC="$TOOLCHAIN"/bin/arm-linux-androideabi-clang \
     CXX="$TOOLCHAIN"/bin/arm-linux-androideabi-clang++ \
     CPPFLAGS="-fPIE -I${OUTPUT_DIR}/include" \
     PKG_CONFIG_LIBDIR="${OUTPUT_DIR}/lib/pkgconfig" \
     LDFLAGS="-fPIE -pie -L${OUTPUT_DIR}/lib"

make
make install
cd ..
####################################################################
# build sqlite-autoconf-3210000
####################################################################
cd portaudio

./configure \
     --host=arm-linux-androideabi \
     --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE` \
	 --disable-static \
	 --enable-shared \
     --with-alsa --without-oss \
	 --prefix=${OUTPUT_DIR} \
     CC="$TOOLCHAIN"/bin/arm-linux-androideabi-clang \
     CXX="$TOOLCHAIN"/bin/arm-linux-androideabi-clang++ \
     CPPFLAGS="-fPIE -I${SYSROOT}/usr/include -I${OUTPUT_DIR}/include" \
     PKG_CONFIG_LIBDIR="${OUTPUT_DIR}/lib/pkgconfig" \
     LDFLAGS="-fPIE -pie -L${SYSROOT}/usr/lib -L${OUTPUT_DIR}/lib"

make
make install
cd ..
