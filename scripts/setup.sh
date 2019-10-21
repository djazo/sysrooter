#!/usr/bin/env bash

if [ -z "${SYSROOT}" ]; then
    echo "No SYSROOT set. Name it."
    exit 1
fi

if [ -z "${DISTRO}" ]; then
    echo "No DISTRO set. I know debian (= raspbian) and alpine"
    exit 1
fi

if [ -z "${MIRROR}" ]; then
    echo "No MIRROR set"
    exit 1
fi

if [ -z "${VERSION}" ]; then
    echo "No VERSION set"
    exit 1
fi

if [ -z "${ARCH}" ]; then
    echo "No ARCH set"
    exit 1
fi

# set the triple

if [ "${DISTRO}" == "debian" ]; then
    case "${ARCH}" in
	armhf)
	    _triple='arm-linux-gnueabihf'
	    ;;
	*)
	    _triple='x86_64-linux-gnu'
	    ;;
    esac
    
fi

if [ "${DISTRO}" == "alpine" ]; then
    case "${ARCH}" in
	armhf)
	    _triple='arm-alpine-linux-musl'
	    ;;
	aarch)
	    _triple='aarch64-alpine-linux-musl'
	    ;;
	*)
	    _triple='x86_64-alpine-linux-musl'
	    ;;
    esac
fi

if [ ! -d /chroots/${SYSROOT}/etc ]; then
    echo "Bootstrapping ${DISTRO} ..."
    mkdir -p /chroots/${SYSROOT}/usr/bin
    case "${ARCH}" in
	armhf)
	    cp /usr/bin/qemu-arm-static /chroots/${SYSROOT}/usr/bin/
	    ;;
	aarch64)
	    cp /usr/bin/qemu-aarch64-static /chroots/${SYSROOT}/usr/bin/
	    ;;
	*)
	    echo "No qemu copied"
	    ;;
    esac
    
    case "${DISTRO}" in
	debian)
	    debootstrap --arch=${ARCH} --no-merged-usr --no-check-gpg ${VERSION} /chroots/${SYSROOT} ${MIRROR}
	    chroot /chroots/${SYSROOT} bash -c 'apt-get update && apt-get -y upgrade && apt-get -y --no-install-recommends install gcc g++ symlinks pkg-config'
	    chroot /chroots/${SYSROOT} bash -c 'symlinks -c /usr'
	    chroot /chroots/${SYSROOT} bash -c 'symlinks -c /lib'
	    ;;
	alpine)
	    apk.static --arch ${ARCH} -X ${MIRROR} -U --allow-untrusted --root /chroots/${SYSROOT} --initdb add alpine-base linux-headers musl-dev libc-dev libgcc gcc g++
	    ;;
	*)
	    echo ".. ${DISTRO} is not known distro"
	    exit 1
	    ;;
    esac
fi

# time to add stuff that user requests.

if [ ! -z "$@" ]; then
    echo "Trying to add packages.."
    case "${DISTRO}" in
	debian)
	    chroot /chroots/${SYSROOT} bash -c 'apt-get update && apt-get -y upgrade'
	    chroot /chroots/${SYSROOT} bash -c "apt-get -y --no-install-recommends install $@"
	    ;;
	alpine)
	    apk.static --arch ${ARCH} -X ${MIRROR} -U --allow-untrusted --root /chroots/${SYSROOT} add $@
	    ;;
	*)
	    echo ".. ${DISTRO} is not known distro"
	    exit 1
	    ;;
    esac
fi

# copy the files to sysroot (leaner..)

case "${DISTRO}" in
    alpine)
	mkdir -p /sysroots/${SYSROOT}/lib /sysroots/${SYSROOT}/usr/lib
	cp /chroots/${SYSROOT}/lib/*.so.* /sysroots/${SYSROOT}/lib/
	cp -r /chroots/${SYSROOT}/usr/lib/gcc /sysroots/${SYSROOT}/usr/lib/
	cp /chroots/${SYSROOT}/usr/lib/*.so.* /sysroots/${SYSROOT}/usr/lib/
	cp -r /chroots/${SYSROOT}/usr/include /sysroots/${SYSROOT}/usr/
	;;
    debian)
	mkdir -p /sysroots/${SYSROOT}/lib /sysroots/${SYSROOT}/usr/lib
	cp -r /chroots/${SYSROOT}/lib/${_triple} /sysroots/${SYSROOT}/lib/
	cp /chroots/${SYSROOT}/lib/*.so.* /sysroots/${SYSROOT}/lib/
	cp -r /chroots/${SYSROOT}/usr/lib/${_triple} /sysroots/${SYSROOT}/usr/lib/
	cp /chroots/${SYSROOT}/usr/lib/*.so.* /sysroots/${SYSROOT}/usr/lib/
	cp /chroots/${SYSROOT}/usr/lib/*.a /sysroots/${SYSROOT}/usr/lib/
	cp -r /chroots/${SYSROOT}/usr/lib/gcc /sysroots/${SYSROOT}/usr/lib/
	cp -r /chroots/${SYSROOT}/usr/include /sysroots/${SYSROOT}/usr/
	;;
esac

	
