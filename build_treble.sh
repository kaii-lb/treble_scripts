#!/bin/sh
# absolute mish mash of stuff

git rebase --abort
git am --abort
git am --skip

rm -rf .repo/local_manifests
rm -rf treblestuff/
rm -rf device/phh/treble/
rm -rf .git/rebase-apply/
rm -rf vendor/hardware_overlay/

repo init -u https://github.com/ProjectEverest/manifest -b qpr2 --git-lfs

git clone https://github.com/kaii-lb/treble_manifest.git .repo/local_manifests
git clone https://github.com/TrebleDroid/vendor_hardware_overlay.git vendor/hardware_overlay/
git clone https://github.com/kaii-lb/treble_everest.git treblestuff/

ls treblestuff/ 1>/dev/null
if [ $? != 0 ]; then
  echo "ERROR: syncing treble_everest failed."
  exit 1
fi

treblestuff/patches/apply.sh . trebledroid
treblestuff/patches/apply.sh . debug
treblestuff/patches/apply.sh . pre

git clone https://github.com/TrebleDroid/device_phh_treble.git device/phh/treble/

ls device/phh/treble 1>/dev/null
if [ $? != 0 ]; then
  echo "ERROR: syncing device_phh_treble failed."
  exit 1
fi

cp treblestuff/everest.mk device/phh/treble/everest.mk

cd device/phh/treble
bash generate.sh everest
cp treble_arm64_bgN.mk everest_arm64_bgN-user.mk
cp treble_arm64_bgN.mk everest_arm64_bgN.mk
cp treble_arm64_bgN.mk lineage_arm64_bgN.mk
cd ../../../ 

/opt/crave/resync.sh

export EVEREST_MAINTAINER="kaii"
export TARGET_SUPPORTS_BLUR=true
export TARGET_HAS_UDFPS=true
export EXTRA_UDFPS_ANIMATIONS=true
export TARGET_INCLUDE_PIXEL_LAUNCHER=false
export TARGET_RELEASE=ap1a

source build/envsetup.sh

# screw this command sideways
lunch everest_arm64_bgN-ap1a-user
make systemimage -j $(nproc --all)
