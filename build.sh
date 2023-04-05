#!/usr/bin/env bash
#
# Build and pack app into an IPA for iOS 14 and 15.

set -e

# Define default values for options
IDENTITY=""
BUNDLE_ID=""
CLEAN_UP=false

TEAM_ID=""

# Define an error function to print error messages to stderr
function error {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

# Define a function to display usage information
function usage {
  echo "Usage: build.sh [options]"
  echo ""
  echo "Builds the project with the specified options."
  echo ""
  echo "Options:"
  echo "  -h, --help                 Display this help message."
  echo "  -C, --certificate NAME     Specify the full name of your certificate."
  echo "  -b, --bundle-id BUNDLE_ID  Override PRODUCT_BUNDLE_IDENTIFIER in the current build settings."
  echo "  -c, --clean-up             Remove all build artifacts."
  echo ""
}

function parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      -h | --help)
        usage
        exit 0
        ;;
      -C | --certificate)
        IDENTITY="${2}"
        readonly IDENTITY
        shift
        ;;
      -b | --bundle-id)
        BUNDLE_ID="${2}"
        readonly BUNDLE_ID
        shift
        ;;
      -c | --clean-up)
        CLEAN_UP=true
        ;;
      *)
        error  "Unknown option or positional argument: $1"
        exit 1
        ;;
    esac
    shift
  done
}

function build_ipa_for_ios15() {
  echo "➡️ ➡️  Building IPA for iOS 15+"
  
  COMMON_ARGS=(
    -verbose
    -sdk iphoneos
    -configuration Debug
    -scheme BlankApp
    -derivedDataPath build
    -destination 'generic/platform=iOS'
    -allowProvisioningUpdates -allowProvisioningDeviceRegistration
  )
  
  if [[ -n "${TEAM_ID}" ]]; then
    COMMON_ARGS+=(DEVELOPMENT_TEAM="${TEAM_ID}")
  fi
  
  if [[ -n "${BUNDLE_ID}" ]]; then
    COMMON_ARGS+=(PRODUCT_BUNDLE_IDENTIFIER="${BUNDLE_ID}")
  fi
  
  xcodebuild "${COMMON_ARGS[@]}"
  
  echo "➡️ ➡️ ➡️  Packaging bundle into IPA for iOS 15+"
  mkdir -vp ./build/Build/Products/Debug-iphoneos/Payload
  mv -v ./build/Build/Products/Debug-iphoneos/BlankApp.app ./build/Build/Products/Debug-iphoneos/Payload
  cd ./build/Build/Products/Debug-iphoneos/
  zip -r ../../../AnForA15.ipa ./Payload
  cd -
  
  echo "✅ Done! Successfully built IPA for iOS 15+."
}

function build_ipa_for_ios14() {
  echo "➡️ ➡️  Building IPA for iOS 14"
  
  echo "➡️ ➡️ ➡️  Replacing MinimumOSVersion from 15.0 to 14.0"
  plutil -extract 'MinimumOSVersion' raw -o - ./build/Build/Products/Debug-iphoneos/Payload/BlankApp.app/Info.plist
  plutil -type 'MinimumOSVersion' ./build/Build/Products/Debug-iphoneos/Payload/BlankApp.app/Info.plist
  plutil -replace 'MinimumOSVersion' -string '14.0' ./build/Build/Products/Debug-iphoneos/Payload/BlankApp.app/Info.plist
  plutil -extract 'MinimumOSVersion' raw -o - ./build/Build/Products/Debug-iphoneos/Payload/BlankApp.app/Info.plist
  
  codesign --force --sign "${IDENTITY}" --verbose --preserve-metadata=entitlements --timestamp=none --generate-entitlement-der ./build/Build/Products/Debug-iphoneos/Payload/BlankApp.app
  
  echo "➡️ ➡️ ➡️  Packaging bundle into IPA for iOS 14+"
  cd ./build/Build/Products/Debug-iphoneos/
  zip -r ../../../AnForA14.ipa ./Payload
  cd -
  
  echo "✅ Done! Successfully built IPA for iOS 14+."
}

function build_ipa_for_trollstore() {
  echo "➡️ ➡️  Building IPA for TrollStore"
  
  rm -v ./build/Build/Products/Debug-iphoneos/Payload/BlankApp.app/embedded.mobileprovision
  codesign --force --sign "${IDENTITY}" --verbose --entitlements ./unsafe.entitlements --timestamp=none --generate-entitlement-der ./build/Build/Products/Debug-iphoneos/Payload/BlankApp.app
  
  echo "➡️ ➡️ ➡️  Packaging bundle into IPA for TrollStore"
  cd ./build/Build/Products/Debug-iphoneos/
  zip -r ../../../AnForA.tipa ./Payload
  cd -
  
  echo "✅  Done! Successfully built IPA for TrollStore."
}

function find_team_id() {
  if [[ -n "${IDENTITY}" ]]; then
    echo "➡️  Extracting DEVELOPMENT_TEAM from the certificate..."
    TEAM_ID=$(security find-certificate -c "${IDENTITY}" -p login.keychain 2> /dev/null | openssl x509 -noout -subject -nameopt multiline | grep 'organizationalUnitName' | awk '{ print $3 }')
    [[ -z "${TEAM_ID}" ]] && exit 1
    echo "✅ Done! The DEVELOPMENT_TEAM for the certificate called \"${IDENTITY}\" is ${TEAM_ID}."
  else
    local current_dev_team
    current_dev_team=$(xcodebuild -showBuildSettings 2> /dev/null | awk -F= '/DEVELOPMENT_TEAM/{gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2}')
    set +e
    # https://stackoverflow.com/a/40066559
    # https://stackoverflow.com/a/26480210
    security find-identity -p codesigning -v | tail -r | tail -n +2 | tail -r | while IFS=$'\n' read -r name; do
      # https://stackoverflow.com/a/44758766
      # https://stackoverflow.com/a/35636517
      [[ "$( (security find-certificate -c "$(echo "${name}" | cut -d'"' -f 2)" -p login.keychain | openssl x509 -noout -subject -nameopt multiline | grep 'organizationalUnitName' | awk '{ print $3 }') 2> /dev/null)" == "${current_dev_team}" ]] && echo "${name}"
    done
    set -e
    
    # it's not necessary but I filtered identities by OU
    echo ""
    echo "ℹ️  Please enter the SHA1 or full name of your certificate with the organizational unit ${current_dev_team}."
    echo "   I'll use it to sign IPA for iOS 14+ and TrollStore."
    # TODO: automatizzare se e' possibile stabilire con esattezza quale identità usare dato il TEAM ID. Non sono certo se esistono altri stati per i certificati oltre la revoca.
    echo ""
    read -r -p "> " IDENTITY
  fi
  readonly TEAM_ID
}	

function remove_revoked() {
  local revoked
  revoked=$(security find-identity -p codesigning -v | grep "${IDENTITY}" | grep REVOKED | awk '{ print $2 }')
  if [[ -n "${revoked}" ]]; then
    echo "➡️  Removing identity with SHA1 ${revoked}..."
    echo ""
    echo "ℹ️  If a revoked certificate remains in the keychain while a new one is added,"
    echo "   it can cause ambiguity as they have different SHA1 values but the same name."
    echo ""
    security delete-identity -Z "${revoked}"
  else
    echo "ℹ️  The task to remove revoked identities has been skipped."
  fi
}

function main() {
  parse_args "$@"

  if ${CLEAN_UP}; then
    echo "➡️  Cleaning up..."
    rm -rf ./build/
  else
    [[ $OSTYPE == 'darwin'* ]] || (error 'OS not supported. Exiting...' && exit 1)
  
    [[ $( (xcodebuild -version) 2> /dev/null) ]] || (error "xcodebuild could not be found" && exit 1)
  
    find_team_id
    remove_revoked
    echo "➡️  Building IPAs..."
    build_ipa_for_ios15
    remove_revoked
    build_ipa_for_ios14
    build_ipa_for_trollstore
  fi
}

main "$@"
exit 0
