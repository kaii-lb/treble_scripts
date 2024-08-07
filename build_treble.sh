#!/bin/bash

. build/envsetup.sh
# screw this command sideways
echo -e "--> Running lunch..."
lunch everest_arm64_bvN-userdebug
echo -e "--> Done eating."

make systemimage -j$(nproc --all)

if [ $? != 0 ]; then
  echo "--> ERROR: building treble_everest failed."
  exit 1
fi

pushd /tmp/src/android/out/target/product/tdgsi_arm64_ab/
xz -9 -T0 -k system.img
#mv system.img.xz EverestOS_1_3_arm64_bgN-FULL_GAPPS.img.xz
mv system.img.xz EverestOS_1_3_arm64_bvN-NO_GAPPS.img.xz
popd
