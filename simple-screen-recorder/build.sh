#!/bin/bash

set -e

echo "Detecting x86/x64 ..."
case "$( uname -m )" in
        "i386"|"i486"|"i586"|"i686"|"x86_64") ENABLE_X86_ASM="--enable-x86-asm" ;;
        *) ENABLE_X86_ASM="--disable-x86-asm --disable-glinjectlib" ;;
esac
echo "x86/x64 = $ENABLE_X86_ASM"

echo "Detecting ffmpeg/libav ..."
if ! pkg-config --exists libavcodec; then
        echo "Error: libavcodec development package not found, make sure ffmpeg or libav development packages are installed."
        exit 1
fi
LIBAVCODEC_INCLUDE_DIR=`pkg-config --variable=includedir libavcodec`
HAS_FFMPEG=$( grep -c "This file is part of FFmpeg." $LIBAVCODEC_INCLUDE_DIR/libavcodec/avcodec.h || true )
HAS_LIBAV=$( grep -c "This file is part of Libav." $LIBAVCODEC_INCLUDE_DIR/libavcodec/avcodec.h || true )
if [ $HAS_FFMPEG -gt 0 ]; then
        if [ $HAS_LIBAV -gt 0 ]; then
                echo "Fatal: Detected ffmpeg AND libav, this should not happen!"
                exit 1
        else
                echo "Detected ffmpeg."
                ENABLE_FFMPEG_VERSIONS="--enable-ffmpeg-versions"
        fi
else
        if [ $HAS_LIBAV -gt 0 ]; then
                echo "Detected libav."
                ENABLE_FFMPEG_VERSIONS="--disable-ffmpeg-versions"
        else
                echo "Fatal: Detection failed."
                exit 1
        fi
fi

CONFIGURE_OPTIONS="--disable-assert $ENABLE_X86_ASM $ENABLE_FFMPEG_VERSIONS"

export CPPFLAGS=""
export CFLAGS="-Wall -O2 -pipe -D_GNU_SOURCE"
export CXXFLAGS="-Wall -O2 -pipe -D_GNU_SOURCE"
export LDFLAGS=""

export CPPFLAGS="$CPPFLAGS `pkg-config --cflags-only-I libavformat libavcodec libavutil libswscale`"
export LDFLAGS="$LDFLAGS `pkg-config --libs-only-L libavformat libavcodec libavutil libswscale`"

mkdir -p build
cd build
echo "Configuring 64 bit program and library ..."
../configure --prefix=${PREFIX} --without-jack $CONFIGURE_OPTIONS

echo "Compiling 64 bit program and library ..."
make
#cd ..
#
#mkdir -p build32
#cd build32      
#echo "Configuring 32-bit GLInject library ..."
#if [ -d "/usr/lib/i386-linux-gnu" ]; then
#    LIB32DIR="/usr/lib/i386-linux-gnu"
#elif [ -d "/usr/lib/i686-linux-gnu" ]; then
#    LIB32DIR="/usr/lib/i686-linux-gnu"
#elif [ -d "/usr/lib32" ]; then
#    LIB32DIR="/usr/lib32"
#else
#    LIB32DIR="/usr/lib"
#fi
#CC="gcc -m32" CXX="g++ -m32" PKG_CONFIG_PATH="$LIB32DIR/pkgconfig" \
#../configure --prefix=${PREFIX} --without-jack --disable-ssrprogram $CONFIGURE_OPTIONS
#
#echo "Compiling 32-bit GLInject library ..."
#make
#cd ..
#
#cd build
echo "Installing 64 bit program and library ..."
make install
#cd ..
#
#cd build32
#echo "Installing 32-bit GLInject library ..."
#make install
cd ..

echo "Done."
