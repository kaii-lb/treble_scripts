#!/bin/bash

# absolute mish mash of stuff

generateMakefiles() {
	cd device/phh/treble
	git clean -fdx
	cp ../../../treblestuff/lineage.mk .
	cp ../../../treblestuff/lineage_product_filenames.mk .
	
	echo "--> Generating makefiles"
	bash generate.sh lineage
	
	echo "--> Copying and renaming makefiles"
	for f in treble_*.mk; do cp -v "$f" "${f/treble/lineage}"; done;

	sed -i '${/^[[:space:]]*$/d;}' AndroidProducts.mk
	cat lineage_product_filenames.mk >> AndroidProducts.mk

	cp ../../../treblestuff/lineage_arm64_bgN.mk .
	cp ../../../treblestuff/lineage_arm64_bvN.mk .
	
	cd ../../../ 
	echo "--> Done generating makefiles"
}

resetAllPatches() {
# 	treblestuff/patches/apply.sh . debug --reset
	treblestuff/patches/apply.sh . personal --reset
	treblestuff/patches/apply.sh . pickedout --reset
	treblestuff/patches/apply.sh . trebledroid --reset
}

copySEPolicyFiles() {
	echo
	echo "--> Cleaning old SEPolicy files"	

	pushd /tmp/src/android/device/lineage/sepolicy/common/public &>/dev/null
	git clean -fdx	
	popd &>/dev/null	

	pushd /tmp/src/android/device/lineage/sepolicy/common/vendor &>/dev/null
	git clean -fdx	
	popd &>/dev/null	

	echo
	echo "--> Copying new SEPolicy files"
	echo

	for folder in $(cd treblestuff/sepolicy && echo *); do
		if [[ $folder == "phh" ]];then
			neededDir="/tmp/src/android/device/phh/treble/sepolicy/"
			echoThis="device/phh/treble/sepolicy"
		else 
			neededDir="/tmp/src/android/device/lineage/sepolicy/common/$folder"
			echoThis="device/lineage/sepolicy/common/$folder"
		fi

		for policy in $(cd treblestuff/sepolicy/$folder; echo *); do
			cp treblestuff/sepolicy/$folder/$policy $neededDir 1>/dev/null

			echo "Copied $policy to $echoThis"
		done
	done

	echo
	echo "--> Done copying SEPolicy files"
	echo
}

rm -rf .repo/local_manifests && echo "Removed Local Manifests"
rm -rf treblestuff/
rm -rf vendor/lineage/signing/keys
mkdir -p .repo/local_manifests

repo init -u https://github.com/ProjectEverest/manifest -b 14 --git-lfs

git clone https://github.com/kaii-lb/treble_manifest.git .repo/local_manifests && echo && echo "Added personal local manifest"
git clone https://github.com/kaii-lb/treble_everest.git treblestuff/ && echo && echo "Added necessary treble patches and sepolicies"
git clone https://github.com/kaii-lb/everestos_keys.git vendor/lineage/signing/keys && echo && echo "Added personal signing keys"

ls treblestuff/ 1>/dev/null
if [ $? != 0 ]; then
  echo "--> ERROR: syncing treble_everest failed."
  exit 1
fi

resetAllPatches

echo -e "--> Starting resync at $(date)."
/opt/crave/resync.sh
echo -e "--> Resync done at $(date)."

treblestuff/patches/apply.sh . personal
# treblestuff/patches/apply.sh . debug
treblestuff/patches/apply.sh . pickedout
treblestuff/patches/apply.sh . trebledroid

# remove conflicted charger between phh_device and everest os
# recommended way is with a commit revert, but oh well
rm -rf device/phh/treble/charger/

# thank you to evolution-xyz for this temporary pif apk || removed for now since PIF was updated.
# pushd /tmp/src/android/vendor/certification/PifPrebuilt
# rm PifPrebuilt.apk*
# wget https://github.com/Evolution-X/vendor_certification/raw/udc/PifPrebuilt/PifPrebuilt.apk
# popd

# export TARGET_RELEASE=ap2a

echo PWD is $PWD

generateMakefiles
copySEPolicyFiles
