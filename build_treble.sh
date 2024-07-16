#!/bin/sh
# absolute mish mash of stuff

# git rebase --abort
# git am --abort
# git am --skip

# thanks ponces
buildTrebleApp() {
    echo "--> Building treble_app"
    cd treble_app

	# causes issues
    bash build.sh release
    
    cp TrebleApp.apk ../vendor/hardware_overlay/TrebleApp/app.apk
    cd ../
    echo "--> Finished building treble_app $PWD"
}

generateMakefiles() {
	cd device/phh/treble
	git clean -fdx
	cp ../../../treblestuff/everest.mk .
	cp ../../../treblestuff/everest_product_filenames.mk .
	
	echo "--> Generating makefiles"
	bash generate.sh everest
	
	echo "--> Copying and renaming makefiles"
	for f in treble_*.mk; do cp -v "$f" "${f/treble/everest}"; done;

	sed -i '${/^[[:space:]]*$/d;}' AndroidProducts.mk
	cat everest_product_filenames.mk >> AndroidProducts.mk
	
	cd ../../../ 
	echo "--> Done generating makefiles"
}

rm -rf .repo/local_manifests
rm -rf treblestuff/
mkdir -p .repo/local_manifests

repo init -u https://github.com/ProjectEverest/manifest -b qpr3 --git-lfs

git clone https://github.com/kaii-lb/treble_manifest.git .repo/local_manifests
git clone https://github.com/kaii-lb/treble_everest.git treblestuff/

ls treblestuff/ 1>/dev/null
if [ $? != 0 ]; then
  echo "ERROR: syncing treble_everest failed."
  exit 1
fi

echo -e "LOG: starting resync at $(date)."
# curl -sf https://raw.githubusercontent.com/xc112lg/scripts/cd10/b.sh | bash;
/opt/crave/resync.sh
echo -e "LOG: resync done at $(date)."

treblestuff/patches/apply.sh . personal
#treblestuff/patches/apply.sh . debug
treblestuff/patches/apply.sh . pickedout

# remove conflicted charger between phh_device and everest os, should find a better way
rm -rf device/phh/treble/charger/

# export TARGET_RELEASE=ap2a

. build/envsetup.sh
echo PWD is $PWD
#buildTrebleApp
generateMakefiles

# screw this command sideways
echo -e "LOG: running lunch..."
lunch everest_arm64_bgN-ap2a-userdebug
echo -e "LOG: done eating..."
#make systemimage -j $(nproc --all)
make bacon -j$(nproc --all)
