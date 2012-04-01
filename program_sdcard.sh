#!/bin/sh

set -e
export LC_ALL=C

if [ $# -ne 2 ]; then
	echo "Usage: $0 <.img file> <sdcard dev>"
	echo "e.g. $0 bbone-erlang-x.y.img sdb"
	exit 1
fi

IMGFILE=$1
IMGFILESZ=`stat --format=%s $IMGFILE`
DEST=$2
DESTPATH=/dev/$DEST

# Unmount everything on the destination first
echo "Unmounting everything on the destination..."
find /dev -name "${DEST}?" -exec umount "{}" ";"

echo "Writing to the MicroSD card..."
dd if=$IMGFILE 2>/dev/null | pv -s $IMGFILESZ | sudo dd of=$DESTPATH bs=1M 2>/dev/null

echo "Done."
