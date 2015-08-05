#!/bin/bash

mkdir -vp ${PREFIX}/bin;

ARCH="$(uname 2>/dev/null)"

common() {

    chmod +x configure
    
    sed -i "s|glib/gstrfuncs\.h|glib.h|" charset/fribidi-char-sets.c
    sed -i "s|glib/gmem\.h|glib.h|"      lib/mem.h

    ./configure --prefix=${PREFIX} || return 1
                
    make || return 1
    make install || return 1
    
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
