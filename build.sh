#!/bin/sh
#
# Build and pack app into an IPA for iOS 14 and 15.

set -e

readonly RED='\033[0;31m'
readonly NC='\033[0m' # No Color

function clean() {
    rm -rf ./build/ ./build_trollstore/
}

function build_for_ios_15() {
  xcodebuild -verbose -sdk iphoneos -configuration Debug -scheme BlankApp -derivedDataPath build -destination 'generic/platform=iOS' -allowProvisioningUpdates
    
  printf "${RED}Pack bundle into IPA for iOS 15${NC}\n"
  mkdir -vp ./build/Build/Products/Debug-iphoneos/Payload
  mv -v ./build/Build/Products/Debug-iphoneos/BlankApp.app ./build/Build/Products/Debug-iphoneos/Payload
  cd ./build/Build/Products/Debug-iphoneos/
  zip -r ../../../AnForA15.ipa ./Payload
  cd -
}

function build_for_ios_14() {
  printf "${RED}Replace MinimumOSVersion: 15.0 --> 14.0${NC}\n"
  plutil -extract 'MinimumOSVersion' raw -o - ./build/Build/Products/Debug-iphoneos/Payload/BlankApp.app/Info.plist
  plutil -type 'MinimumOSVersion' ./build/Build/Products/Debug-iphoneos/Payload/BlankApp.app/Info.plist
  plutil -replace 'MinimumOSVersion' -string '14.0' ./build/Build/Products/Debug-iphoneos/Payload/BlankApp.app/Info.plist
  plutil -extract 'MinimumOSVersion' raw -o - ./build/Build/Products/Debug-iphoneos/Payload/BlankApp.app/Info.plist
  
  security find-identity -v -p codesigning
  read -p "SHA-1 hash (or name) of certificate: " sha1
  
  printf "${RED}Sign bundle with identity ${sha1}${NC}\n"
  codesign --force --sign "${sha1}" --verbose --deep --entitlements ./safe.entitlements --timestamp=none --generate-entitlement-der ./build/Build/Products/Debug-iphoneos/Payload/BlankApp.app
  
  printf "${RED}Pack bundle into IPA for iOS 14${NC}\n"
  cd ./build/Build/Products/Debug-iphoneos/
  zip -r ../../../AnForA14.ipa ./Payload
  cd -
}

function build_for_trollstore() {
  xcodebuild -verbose -sdk iphoneos -configuration Debug -scheme BlankApp -derivedDataPath build_trollstore -destination 'generic/platform=iOS' -allowProvisioningUpdates CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
    
  security find-identity -v -p codesigning
  read -p "SHA-1 hash (or name) of certificate: " sha1
  
  printf "${RED}Sign bundle with identity ${sha1}${NC}\n"
  codesign --force --sign "${sha1}" --verbose --deep --entitlements ./unsafe.entitlements --timestamp=none --generate-entitlement-der ./build_trollstore/Build/Products/Debug-iphoneos/BlankApp.app
  
  printf "${RED}Pack bundle into (T)IPA for iOS 15${NC}\n"
  mkdir -vp ./build_trollstore/Build/Products/Debug-iphoneos/Payload
  mv -v ./build_trollstore/Build/Products/Debug-iphoneos/BlankApp.app ./build_trollstore/Build/Products/Debug-iphoneos/Payload
  cd ./build_trollstore/Build/Products/Debug-iphoneos/
  zip -r ../../../AnForA.ipa ./Payload
  cd -
}

function main() {
  if [ "${1}" = "clean" ]; then
    clean
    exit 0
  fi

  build_for_ios_15
  build_for_ios_14
  build_for_trollstore
  
  exit 0
}

main "$@"
