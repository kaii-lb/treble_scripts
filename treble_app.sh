#!/bin/bash

echo "--> Building treble_app"
cd /tmp/src/android/treble_app
	# causes issues, exits entire script on success/failure
	# can't exit script if not in script ;D
	if bash build.sh release; then
		echo "--> SUCCESSFULLY BUILT TREBLE APP"
	else 
		echo "--> BUILDING TREBLE APP FAILED"
	fi
	cp TrebleApp.apk ../vendor/hardware_overlay/TrebleApp/app.apk
cd /tmp/src/android
