#!/bin/sh

TARGETDIR=$1
BOARDDIR=board/nerves-project/beaglebone

# Set root password to 'root'. Password generated with
# mkpasswd, from the 'whois' package in Debian/Ubuntu.
sed -i 's%root::%root:8kfIfYHmcyQEE:%' $TARGETDIR/etc/shadow

# Copy the rootfs additions
cp -a $BOARDDIR/rootfs-additions/* $TARGETDIR/

