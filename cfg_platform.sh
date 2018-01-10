#!/bin/bash

#config uboot
CURR_PATH=$PWD
find ./board-support/u-boot-*/configs -name am*|grep -E "rom|rsb" |sed 's/^.*configs\///g' | grep -n '' | awk {'print "	" , $1'}
echo ""
read -p "Enter Number of rootfs Tarball: " CFGNUMBER
echo " "

CFG_PLATNAME=`find ./board-support/u-boot-*/configs -name am*|grep -E "rom|rsb" |sed 's/^.*configs\///g' | grep -n '' | grep "${CFGNUMBER}:" | cut -c3- | awk {'print$1'}`
CFG_UBOOT_MACHINE=${CFG_PLATNAME/defconfig/config}
echo $CFG_PLATNAME
echo $CFG_UBOOT_MACHINE
ubootcfgline=`sed -n '/'"UBOOT_MACHINE"'/=' ./Rules.make`
echo $ubootcfgline
sed -i ''${ubootcfgline}'c 'UBOOT_MACHINE=$CFG_UBOOT_MACHINE'' ./Rules.make

#config platform
CFG_PLAT=`echo $CFG_PLATNAME | cut -d \_ -f 1`
CFG_BOARD=`echo $CFG_PLATNAME | cut -d \_ -f 2`
CFG_PLATFORM=${CFG_PLAT}${CFG_BOARD}
platcfgline=`sed -n '/'"PLATFORM"'/=' ./Rules.make`
echo platcfgline=$platcfgline
echo CFG_PLATFORM=$CFG_PLATFORM
sed -i ''${platcfgline}'c 'PLATFORM=$CFG_PLATFORM'' ./Rules.make

#config kernel
cd ./board-support/linux-*/arch/arm/configs/
CFG_KERNEL_DEF=tisdk_${CFG_PLATFORM}_defconfig
cp -f am57xx-adv_defconfig $CFG_KERNEL_DEF
cd $CURR_PATH
kdefline=`sed -n '/'"DEFCONFIG"'/=' ./Rules.make`
echo kdefline=$kdefline
echo CFG_KERNEL_DEF=$CFG_KERNEL_DEF
sed -i ''${kdefline}'c 'DEFCONFIG=$CFG_KERNEL_DEF'' ./Rules.make

#config dtb
CFG_DTB_TARGET=${CFG_PLAT}-${CFG_BOARD}.dtb
echo CFG_DTB_TARGET=$CFG_DTB_TARGET
tempdtbline=`sed -n '/'"linux-dtbs:"'/=' ./Makefile`
dtbline=`expr ${tempdtbline} + 5`
echo tempdtbline=$tempdtbline
echo dtbline=$dtbline
dtbstring=`sed -n ''${dtbline}' p' ./Makefile`
OLD_DTB_TARGET=`echo $dtbstring | cut -d \  -f 8`
echo dtbstring=$dtbstring
echo OLD_DTB_TARGET=$OLD_DTB_TARGET
sed -i "s/${OLD_DTB_TARGET}/${CFG_DTB_TARGET}/g" ./Makefile

