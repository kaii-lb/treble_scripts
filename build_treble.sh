#!/bin/bash

build="$1"
type="bgN"
name="FULL_GAPPS"
suffix="userdebug"

if [[ $build == "gapps" ]]; then
	type="bgN"
	name="FULL_GAPPS"
elif [[ $build == "vanilla" ]]; then
	type="bvN"
	name="NO_GAPPS"
elif [[ $build == "pixel" ]]; then
	type="bgPN"
	name="FULL_GAPPS_REB"
fi

if [[ $2 == "user" ]]; then
	suffix="user"
else 
	suffix="userdebug"
fi

. build/envsetup.sh
# screw this command sideways
echo -e "--> Running lunch..."
lunch everest_arm64_$type-$suffix
echo -e "--> Done eating."

# make PifPrebuilt # read up on how to do this correctly
make systemimage -j$(nproc --all)

if [ $? != 0 ]; then
  echo "--> ERROR: building treble_everest failed."
  exit 1
fi

pushd /tmp/src/android/out/target/product/tdgsi_arm64_ab/
xz -9 -T0 -k system.img
mv system.img.xz EverestOS_1_3_arm64_$type-$name.img.xz
popd
