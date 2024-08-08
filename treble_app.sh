#!/bin/bash

echo "--> Building treble_app"
cd /tmp/src/android/treble_app
	# causes issues, exits entire script on success/failure
	# can't exit script if not in script ;D
	# bash build.sh release
	wget https://github.com/kaii-lb/randomshit/releases/download/v0.1/TrebleApp.apk

	if [ $? != 0 ]; then
	  	bash build.sh release
	else
		echo "using own TrebleApp.apk"
	fi
	
	cp TrebleApp.apk ../vendor/hardware_overlay/TrebleApp/app.apk
cd /tmp/src/android
