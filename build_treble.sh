#!/bin/sh
# absolute mish mash of stuff

# git rebase --abort
# git am --abort
# git am --skip

rm -rf .repo/local_manifests
rm -rf treblestuff/

repo init -u https://github.com/ProjectEverest/manifest -b qpr2 --git-lfs

git clone https://github.com/kaii-lb/treble_manifest.git .repo/local_manifests
git clone https://github.com/kaii-lb/treble_everest.git treblestuff/


# /opt/crave/resync.sh
date
curl -sf https://raw.githubusercontent.com/xc112lg/scripts/cd10/b.sh | bash;
date

echo "LOG: resync done."

# treblestuff/patches/apply.sh . trebledroid
treblestuff/patches/apply.sh . debug
treblestuff/patches/apply.sh . pre

ls treblestuff/ 1>/dev/null
if [ $? != 0 ]; then
  echo "ERROR: syncing treble_everest failed."
  exit 1
fi


cd device/phh/treble
git clean -fdx
cp ../../../treblestuff/everest.mk .
bash generate.sh everest
cd ../../../ 
echo "LOG: done generating."

export EVEREST_MAINTAINER="kaii"
export TARGET_SUPPORTS_BLUR=true
export TARGET_HAS_UDFPS=true
export EXTRA_UDFPS_ANIMATIONS=true
export TARGET_INCLUDE_PIXEL_LAUNCHER=false
export TARGET_RELEASE=ap1a

source build/envsetup.sh

# screw this command sideways
lunch treble_arm64_bgN-userdebug
make systemimage -j $(nproc --all)
