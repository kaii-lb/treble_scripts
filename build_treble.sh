#!/bin/bash

. build/envsetup.sh

# screw this command sideways
echo -e "--> running lunch..."
lunch everest_arm64_bgN-userdebug
echo -e "--> done eating."

make systemimage -j$(nproc --all)

if [ $? != 0 ]; then
  echo "--> ERROR: building treble_everest failed."
  exit 1
fi

cd /tmp/src/android/out/target/product/tdgsi_arm64_ab/
xz -9 -T0 -k system.img
mv system.img.xz EverestOS_1_3_arm64_bgN-FULL_GAPPS.img.xz
cd /tmp/src/android/
