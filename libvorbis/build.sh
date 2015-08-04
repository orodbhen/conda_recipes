#!/bin/bash

ARCH="$(uname 2>/dev/null)"

LinuxInstallation() {

    chmod +x configure

    make distclean 2> /dev/null
    
    ./configure --prefix=${PREFIX} --with-ogg=${PREFIX} --disable-static || return 1
                
    make || return 1
    make install || return 1
    make distclean
    
    return 0
}


case ${ARCH} in
    'Linux')
        LinuxInstallation || exit 1
        ;;
    *)
        echo -e "Unsupported architecture: ${ARCH}"
        exit 1
        ;;
esac