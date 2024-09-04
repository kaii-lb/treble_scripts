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
fi

if [[ $2 == "user" ]]; then
	suffix="user"
else 
	suffix="userdebug"
fi

echo "--> BUILD TYPE $type $suffix $name"

export TARGET_RELEASE=ap2a
source build/envsetup.sh
export TARGET_RELEASE=ap2a

# screw this command sideways
echo -e "--> Running lunch..."
lunch lineage_arm64_$type-$suffix
echo -e "--> Done eating."

# make PifPrebuilt # read up on how to do this correctly
mka systemimage -j$(nproc --all)

if [ $? != 0 ]; then
  echo "--> ERROR: building treble_everest failed."
  exit 1
fi

pushd /tmp/src/android/out/target/product/arm64_$type/
xz -9 -T0 -k system.img
mv system.img.xz EverestOS_1_5_arm64_$type-$name.img.xz
popd
