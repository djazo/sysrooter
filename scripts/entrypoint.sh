#!/usr/bin/env ash

if [ ! -d /sysroots ]; then
   echo "No sysroots found!"
   exit 1
fi

for _a in x86_64 armv7 aarch64; do
    if [ ! -d /sysroots/${_a} ]; then
        echo "initializing sysroots..."
        apk --arch ${_a} -X http://dl-cdn.alpinelinux.org/alpine/v3.11/main -U --allow-untrusted --root /sysroots/${_a} --initdb add musl-dev libc-dev linux-headers g++
        echo "http://dl-cdn.alpinelinux.org/alpine/v3.11/main" >/sysroots/${_a}/etc/apk/repositories
        echo "http://dl-cdn.alpinelinux.org/alpine/v3.11/community" >>/sysroots/${_a}/etc/apk/repositories
    fi

    case $1 in
        add | del )
            apk --arch ${_a} --no-scripts -U --allow-untrusted --root /sysroots/${_a} $@
            ;;
        *)
            apk --arch ${_a} -U --allow-untrusted --root /sysroots/${_a} $@
            ;;
    esac
done

