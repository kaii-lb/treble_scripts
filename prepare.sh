#!/bin/bash

# absolute mish mash of stuff

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
mkdir -p .repo/local_manifests

repo init -u https://github.com/ProjectEverest/manifest -b 14 --git-lfs

git clone https://github.com/kaii-lb/treble_manifest.git .repo/local_manifests && echo && echo "Added personal local manifest"
git clone https://github.com/kaii-lb/treble_everest.git treblestuff/ && echo && echo "Added necessary treble patches and sepolicies"

if [ $? != 0 ]; then
  echo "--> ERROR: syncing treble_everest failed."
  exit 1
fi

resetAllPatches

echo -e "--> Starting resync at $(date)."
/opt/crave/resync.sh
echo -e "--> Resync done at $(date)."

rm -r prebuilts/clang/host/linux-x86
git clone https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86 prebuilts/clang/host/linux-x86

rm -rf vendor/lineage/signing/keys
git clone https://github.com/kaii-lb/everestos_keys.git vendor/lineage/signing/keys && echo && echo "Added personal signing keys"

treblestuff/patches/apply.sh . personal
# treblestuff/patches/apply.sh . debug
treblestuff/patches/apply.sh . pickedout
treblestuff/patches/apply.sh . trebledroid

echo PWD is $PWD

copySEPolicyFiles
