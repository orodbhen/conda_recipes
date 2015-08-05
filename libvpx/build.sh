#!/bin/bash

ARCH="$(uname 2>/dev/null)"


LinuxInstallation() {
    chmod +x configure
    
    ./configure --prefix=${PREFIX} --disable-examples --enable-shared --disable-static || return 1
                
    make || return 1
    make install || return 1
    
    return 0
}


OSXInstallation() {
    chmod +x configure
    
    ./configure --prefix=${PREFIX} --disable-examples || return 1
                
    make || return 1
    make install || return 1
    
    return 0
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
