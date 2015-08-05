#!/bin/bash

mkdir -vp ${PREFIX}/bin;

ARCH="$(uname 2>/dev/null)"

common() {

    chmod +x configure

    make distclean 2> /dev/null
    
    # First, fix a compiler error introduced by gcc-4.9.0 on 32-bit machines
    case $(uname -m) in
        i?86) sed -i -e '/xmmintrin\.h/d' configure || return 1
        ;;
    esac
    
    ./configure --prefix=${PREFIX} --enable-mp3rtp --disable-static --enable-nasm || return 1
                
    make || return 1
    make install || return 1
    make distclean
    
    return 0
}

LinuxInstallation() {
    common || return 1
}


OSXInstallation() {
    common || return 1
}


case ${ARCH} in
    'Linux')
        LinuxInstallation || exit 1
        ;;
    'Darwin')
        OSXInstallation || exit 1
        ;;
    *)
        echo -e "Unsupported architecture: ${ARCH}"
        exit 1
        ;;
esac
