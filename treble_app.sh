#!/bin/bash

set -e

echo "--> Building treble_app"
pushd treble_app || exit
	# causes issues, exits entire script on success/failure
	if bash build.sh release; then
		echo "--> SUCCESSFULLY BUILT TREBLE APP"
	else 
		echo "--> BUILDING TREBLE APP FAILED"
	fi
	cp TrebleApp.apk ../vendor/hardware_overlay/TrebleApp/app.apk
popd || exit
