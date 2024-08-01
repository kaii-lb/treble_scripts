#!/bin/bash

# absolute mish mash of stuff

# git rebase --abort
# git am --abort
# git am --skip

generateMakefiles() {
	cd device/phh/treble
	git clean -fdx
	cp ../../../treblestuff/everest.mk .
	cp ../../../treblestuff/everest_product_filenames.mk .
	cp ../../../treblestuff/everest_arm64_bgN.mk .
	cp ../../../treblestuff/everest_arm64_bvN.mk .

	
	echo "--> Generating makefiles"
	bash generate.sh everest
	
	echo "--> Copying and renaming makefiles"
	for f in treble_*.mk; do cp -v "$f" "${f/treble/everest}"; done;

	sed -i '${/^[[:space:]]*$/d;}' AndroidProducts.mk
	cat everest_product_filenames.mk >> AndroidProducts.mk
	
	cd ../../../ 
	echo "--> Done generating makefiles"
}

resetAllPatches() {
	treblestuff/patches/apply.sh . personal --reset
	treblestuff/patches/apply.sh . debug --reset
	treblestuff/patches/apply.sh . pickedout --reset
	treblestuff/patches/apply.sh . trebledroid --reset
}

copySEPolicyFiles() {
	echo
	echo "Copying SEPolicy files"	

	for folder in $(cd treblestuff/sepolicy; echo *); do
		neededDir="/tmp/src/android/device/everest/sepolicy/common/$folder"

		pushd $neededDir &>/dev/null
		git clean -fdx	
		popd &>/dev/null	
	
		for policy in $(cd treblestuff/sepolicy/$folder; echo *); do
			cp treblestuff/sepolicy/$folder/$policy $neededDir
		done
	done

	echo "Done copying SEPolicy files"
	echo
}

rm -rf .repo/local_manifests
rm -rf treblestuff/
mkdir -p .repo/local_manifests

repo init -u https://github.com/ProjectEverest/manifest -b qpr3 --git-lfs

git clone https://github.com/kaii-lb/treble_manifest.git .repo/local_manifests
git clone https://github.com/kaii-lb/treble_everest.git treblestuff/

ls treblestuff/ 1>/dev/null
if [ $? != 0 ]; then
  echo "--> ERROR: syncing treble_everest failed."
  exit 1
fi

resetAllPatches

echo -e "--> starting resync at $(date)."
# curl -sf https://raw.githubusercontent.com/xc112lg/scripts/cd10/b.sh | bash;
/opt/crave/resync.sh
echo -e "--> resync done at $(date)."

treblestuff/patches/apply.sh . personal
treblestuff/patches/apply.sh . debug
treblestuff/patches/apply.sh . pickedout
treblestuff/patches/apply.sh . trebledroid

# remove conflicted charger between phh_device and everest os, should find a better way
rm -rf device/phh/treble/charger/

# export TARGET_RELEASE=ap2a

. build/envsetup.sh
echo PWD is $PWD
# curl -sf https://raw.githubusercontent.com/kaii-lb/treble_scripts/main/treble_app.sh > treble_app.sh 
# if sh treble_app.sh;then
# 	echo "SUCCESS WOOOOO"
# else
# 	echo "NOT SUCCESS DAMNIT"
# fi

generateMakefiles
copySEPolicyFiles
