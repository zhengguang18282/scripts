#!/bin/bash

#config uboot
CURR_PATH=$PWD
if [ ! -f Makefile_bak ];then
cp ${CURR_PATH}/Makefile ${CURR_PATH}/Makefile_bak
fi
cp ${CURR_PATH}/Makefile_bak ${CURR_PATH}/Makefile

find ./board-support/u-boot-*/configs -name am*|grep -E "rom|rsb" |sed 's/^.*configs\///g' | grep -n '' | awk {'print "	" , $1'}
echo ""
read -p "Enter Number of rootfs Tarball: " CFGNUMBER
echo " "

CFG_PLATNAME=`find ./board-support/u-boot-*/configs -name am*|grep -E "rom|rsb" |sed 's/^.*configs\///g' | grep -n '' | grep "${CFGNUMBER}:" | cut -c3- | awk {'print$1'}`
CFG_UBOOT_MACHINE=${CFG_PLATNAME/defconfig/config}
ubootcfgline=`sed -n '/'"UBOOT_MACHINE"'/=' ./Rules.make`
sed -i ''${ubootcfgline}'c 'UBOOT_MACHINE=$CFG_UBOOT_MACHINE'' ./Rules.make

#delete sgx
CFG_PLATFORM=${CFG_PLATNAME:7:7}
if [ "${CFG_PLATFORM}" == "rsb4220" ] || [ "${CFG_PLATFORM}" == "rom3310" ];then
sgxline=`sed -n '/'"# ti-sgx-ddk-km module"'/=' ./Makefile`
sgxend=`expr ${sgxline} + 24`
sed -i ''${sgxline}','${sgxend}'d' ./Makefile
sed -i "s/ ti-sgx-ddk-km / /g" ./Makefile
sed -i "s/ ti-sgx-ddk-km_clean / /g" ./Makefile
sed -i "s/ ti-sgx-ddk-km_install / /g" ./Makefile
fi

