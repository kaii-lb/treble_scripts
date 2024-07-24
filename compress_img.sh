#!/bin/sh

cd /tmp/src/android/out/target/product/tdgsi_arm64_ab/
tar c system.img | gzip --best > EverestOS_1_3_arm64_bgN.tar.gz
cd /tmp/src/android/
# gh release upload v1.0 --repo https://github.com/kaii-lb/treble_manifest.git out/target/product/tdgsi_arm64_ab/EverestOS_1_3_arm64_bgN.tar.gz
