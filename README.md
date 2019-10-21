# sysrooter
Create sysroots for cross compiling targeting debian-like system (raspbian) or alpine.


## Usage:

Start container with mounted volumes on /chroots and /sysroots
Have environment variables set:

* SYSROOT = sysroot name, will be the directory name
* DISTRO = debian/alpine debian works for all that can do debootstrap
* MIRROR = the mirror of the distro server. for example http://archive.raspbian.org/raspbian
* ARCH = armhf or aarch64 works for now.
* VERSION = actually works now only on debian packages, for example buster

Hit ```setup.sh``` with parameters for the required packages to install

After that, you'll have SYSROOT directory on your volume that you mounted to /sysroots, and you can use that as your -sysroot on gcc, or CMake sysroot variable.

## Notes

Debian style programs is using qemu on arm/aarch64. It uses chroot to run apt-get to install packages.
Alpine works with apk.static.


