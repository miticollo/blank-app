#!/usr/bin/env bash
#
# Pack app into an IPA for iOS 14 and 15.
#
# https://wiki.lazarus.freepascal.org/Code_Signing_for_macOS#Using_codesign_to_sign_your_application

set -e

readonly RED='\033[0;31m'
readonly NC='\033[0m' # No Color

function pack_ipa_for_ios15() {
  mkdir -v Payload
  printf "${RED}Dump entitlement${NC}\n"
  ldid -e ./BlankApp.app/BlankApp > ent.plist
  printf "${RED}Remove signature applied by Xcode${NC}\n"
  codesign --remove-signature -v ./BlankApp.app
  printf "${RED}Sign bundle with identity ${1}${NC}\n"
  codesign --timestamp -s "${1}" --deep -v --entitlements ./ent.plist ./BlankApp.app
  printf "${RED}Pack bundle into IPA (for iOS 15)${NC}\n"
  mv -v ./BlankApp.app Payload
  zip -r ./AnForA15.ipa ./Payload
}

function pack_ipa_for_ios14() {
  printf "${RED}Remove signature applied previously by this script${NC}\n"
  codesign --remove-signature -v ./BlankApp.app
  printf "${RED}Replace MinimumOSVersion: 15.0 --> 14.0${NC}\n"
  plutil -extract 'MinimumOSVersion' raw -o - ./BlankApp.app/Info.plist
  plutil -type 'MinimumOSVersion' ./BlankApp.app/Info.plist
  plutil -replace 'MinimumOSVersion' -string '14.0' ./BlankApp.app/Info.plist
  plutil -extract 'MinimumOSVersion' raw -o - ./BlankApp.app/Info.plist
  printf "${RED}Sign bundle with identity ${1}${NC}\n"
  codesign --timestamp -s "${1}" --deep -v --entitlements ../ent.plist ./BlankApp.app
  cd ..
  printf "${RED}Pack bundle into IPA (for iOS 14)${NC}\n"
  zip -r ./AnForA14.ipa ./Payload
}

function main() {
  if [ "$#" -ne 1 ]; then
    echo "Usage: ${0} BUILD_DIR" >&2
    exit 1
  fi

  security find-identity -v -p codesigning
  read -p "SHA-1 hash of certificate: " sha1

  cd "${1}"
  pack_ipa_for_ios15 "${sha1}"

  cd Payload
  pack_ipa_for_ios14 "${sha1}"

  exit 0
}

main "$@"
