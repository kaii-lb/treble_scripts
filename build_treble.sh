#!/bin/sh

rm -rf .repo/local_manifests

repo init -u https://github.com/ProjectEverest/manifest -b qpr2 --git-lfs

git clone https://github.com/ahnet-69/treble_evo .repo/local_manifests

mv .repo/local_manifests/evo.mk device/phh/treble/evo.mk

patches/apply-patches.sh . trebledroid
# patches/apply-patches.sh . personal
patches/apply-patches.sh . ponces

cd device/phh/treble
bash generate.sh evo

cd ../../../ 

/opt/crave/resync.sh

export EVEREST_MAINTAINER := "kaii"
export TARGET_SUPPORTS_BLUR := true
export TARGET_HAS_UDFPS := true
export EXTRA_UDFPS_ANIMATIONS := true
export TARGET_INCLUDE_PIXEL_LAUNCHER := false

source build/envsetup.sh

lunch treble_arm64_bgN-userdebug 
make systemimage -j $(nproc --all)
