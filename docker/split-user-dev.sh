#!/bin/bash

set -e

move-to() {
    WHERE=$ORIG/xxx-temp-$1
    DIR=${PWD#$TOP}
    DIR=${DIR#/}
    shift

    #echo "WHERE=$WHERE DIR=$DIR"
    #echo "TOP=$TOP     PWD=$PWD"
    for f in "$@"; do
        echo "move $PWD/$f to $WHERE/$DIR"
        ff="$WHERE/$DIR/$f"
        d=$(dirname $ff)
        mkdir -p $d
        mv $f $d
    done
}

ORIG=$PWD
rm -rf xxx-temp-base|| true
mkdir xxx-temp-base
rm -rf xxx-temp-extra || true
mkdir xxx-temp-extra
rm -rf xxx-temp-trash || true
mkdir xxx-temp-trash

cd xxx-temp-base
TOP=$PWD

echo "copy in the user-dev template"
cp -a $ORIG/user-dev/* .
cp -a $ORIG/user-dev/.[a-zA-Z]* .

echo "copy in the demos directory"
cp -a $ORIG/../demos/* .

echo "copy in the pre-installed image of the zephyr-sdk"
mkdir -p opt
cd opt
tar xvf $ORIG/zephyr-sdk-0.15.1-installed.tar.gz

echo "copy in the qemu-zcu102 files"
cp -a $ORIG/../qemu-zcu102 .

echo "fixup the symlinks"
ln -sf ../../../../zephyr-sdk-0.15.1/sysroots/x86_64-pokysdk-linux/usr/xilinx/bin/qemu-system-aarch64 \
    ./qemu-zcu102/sysroot/usr/bin/qemu-system-aarch64
ln -sf ../../../../zephyr-sdk-0.15.1/sysroots/x86_64-pokysdk-linux/usr/xilinx/bin/qemu-system-microblazeel \
    ./qemu-zcu102/sysroot/usr/bin/qemu-system-microblazeel

echo "Start the splitting operation"
cd $TOP/opt/zephyr-sdk-0.15.1
move-to extra arm-zephyr-eabi
move-to extra aarch64-zephyr-elf
cd sysroots/x86_64-pokysdk-linux/usr
move-to extra bin/qemu-*
move-to extra bin/openocd
move-to extra synopsys

cd $TOP

move-to extra test-sw/openamp-ci-*/modules-*.tgz

tar czvf $ORIG/demo-lite/user-dev-base.tar.gz .
cd $ORIG/xxx-temp-extra
tar czvf $ORIG/demo/user-dev-extra.tar.gz .
cd $ORIG/xxx-temp-trash
tar czvf $ORIG/user-dev-trash.tar.gz .

cd $ORIG
rm -rf $ORIG/xxx-temp-base
rm -rf $ORIG/xxx-temp-extra
rm -rf $ORIG/xxx-temp-trash
