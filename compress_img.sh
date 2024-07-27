#!/bin/sh

cd /tmp/src/android/out/target/product/tdgsi_arm64_ab/
#tar c system.img | gzip --best > EverestOS_1_3_arm64_bgN.tar.gz
tar -c -I 'xz -9 -T0' -f EverestOS_1_3_arm64_bgN.tar.xz system.img
cd /tmp/src/android/
