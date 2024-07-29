#!/bin/sh

echo "--> Building treble_app"
cd treble_app

# causes issues, exits entire script on success/failure
if bash build.sh release; then
	echo "--> SUCCESSFULLY BUILT TREBLE APP"
else 
	echo "--> BUILDING TREBLE APP FAILED"
fi

cp TrebleApp.apk ../vendor/hardware_overlay/TrebleApp/app.apk
cd ../
echo "--> Finished building treble_app $PWD"
echo