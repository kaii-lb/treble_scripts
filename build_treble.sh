#!/bin/sh
# absolute mish mash of stuff

rm -rf .repo/local_manifests

repo init -u https://github.com/ProjectEverest/manifest -b qpr2 --git-lfs

git clone https://github.com/kaii-lb/treble_manifest.git .repo/local_manifests

mkdir device/phh/treble/

git clone https://github.com/kaii-lb/treble_everest.git treblestuff/

treblestuff/patches/apply.sh . trebledroid
treblestuff/patches/apply.sh . debug
treblestuff/patches/apply.sh pre

cp treblestuff/everest.mk /device/phh/treble/everest.mk
cd device/phh/treble
bash generate.sh everest
cd ../../../ 

/opt/crave/resync.sh

export EVEREST_MAINTAINER="kaii"
export TARGET_SUPPORTS_BLUR=true
export TARGET_HAS_UDFPS=true
export EXTRA_UDFPS_ANIMATIONS=true
export TARGET_INCLUDE_PIXEL_LAUNCHER=false

source build/envsetup.sh

lunch treble_arm64_bgN-userdebug 
make systemimage -j $(nproc --all)
