# Erlang-focused Buildroot for the BeagleBone

This README contains basic instructions for creating a system image
for the BeagleBone using Buildroot. The image is meant for creating
embedded Erlang nodes.  Packages can easily be added using Buildroot's
`make menuconfig` configuration editor.

## Preparing your system

Buildroot requires several packages to be installed on the system
before it can work. On Ubuntu, the following apt-get line is sufficient:

    sudo apt-get install git-core bison flex g++ gettext texinfo libncurses5-dev pv

If you'd like to compile in HiPE support, qemu is currently needed. On
recent distros it is sufficient to run "sudo apt-get install qemu-user" or
similar. On Ubuntu 10.04, the default version of qemu is too old.

Download qemu from
http://wiki.qemu.org/Download and compile from source by running the
following:

    ./configure --target-list=arm-linux-user
    make
    sudo make install

## Building

To build a disk image, run:

    ./build_disk_image.sh

This will result in a .img file being built. This takes a while.

If you are hacking the main image, you probably want more granularity in
building everything. First tell Buildroot which configuration to use:

    make beaglebone_erlang_defconfig

To build everything, run:

    make

The build output is stored in the output/images directory. Subsequent
builds are faster. It is possible to perform partial rebuilds. See the
[Buildroot](http://buildroot.uclibc.org/) website for details.

## Creating a BeagleBone MicroSD card

After the build completes successfully, you should have a .img file.
This is a binary image that should be written to the beginning of the
MicroSD card. To do this, insert a MicroSD card. You will need to
unmount any partitions that were auto-mounted before writing the .img
file. The commands should be something similar to the following:

    find /dev -name "sdX?" -exec umount "{}" ";"
    sudo dd if=xxxxxxx.img of=/dev/sdX bs=1M

Replace sdX with the device for the MicroSD card. This can be found by
looking at the end of `dmesg` after plugging in the MicroSD card. Be
careful with this since a typo in the device file can make the system
unbootable.

You may also run the following script which does the above for you:

    ./program_sdcard.sh xxxxxxx.img sdX

## Updating the Root FS on the BeagleBone

The Root FS is configured to mount read-only on the BeagleBone. This is done
to prevent data corruption from unsafe shutdowns and as a reminder that all
configuration and new packages have to end up in the buildroot configuration.

Since this can be annoying during debug, the rootfs can be mounted by running:

    mount -o remount,rw /

## Setting the timezone

This image uses a simpler mechanism for dealing with the timezone than
what is used on desktop Linux. All timezone information is kept in /etc/TZ.
To change the timezone, just edit it and place the POSIX timezone string
for your location. See http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap08.html
for information on the TZ format. To keep things simple, here are some
examples:

    EST5EDT
    GMT0
    JST-9
    MET-1MEST
    MST7MDT
    PST8PDT

