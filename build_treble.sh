#!/bin/sh
# absolute mish mash of stuff

rm -rf .repo/local_manifests

repo init -u https://github.com/ProjectEverest/manifest -b qpr2 --git-lfs

git clone https://github.com/kaii-lb/treble_evo_fucked .repo/local_manifests

# mkdir device/phh/treble/
# mv .repo/local_manifests/evo.mk device/phh/treble/evo.mk

.repo/local_manifests/patches/apply-patches.sh trebledroid
# .repo/local_manifests/patches/apply-patches.sh personal
.repo/local_manifests/patches/apply-patches.sh ponces

# cd device/phh/treble
# bash generate.sh evo
#cd ../../../ 

/opt/crave/resync.sh

export EVEREST_MAINTAINER="kaii"
export TARGET_SUPPORTS_BLUR=true
export TARGET_HAS_UDFPS=true
export EXTRA_UDFPS_ANIMATIONS=true
export TARGET_INCLUDE_PIXEL_LAUNCHER=false

source build/envsetup.sh

lunch treble_arm64_bgN-userdebug 
make systemimage -j $(nproc --all)
