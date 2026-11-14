#!/bin/bash
# Builds Kawa.app (Release, arm64) and packages it as build/Kawa-<version>.dmg.
#
# Builds the MASShortcut dependency first if it is missing.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="$ROOT/build"
DERIVED="$BUILD/DerivedData"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$ROOT/kawa/Info.plist")"
DMG="$BUILD/Kawa-$VERSION.dmg"

if [ ! -d "$ROOT/Carthage/Build/Mac/MASShortcut.framework" ]; then
  "$ROOT/scripts/build-deps.sh"
fi

rm -rf "$DERIVED"
xcodebuild \
  -project "$ROOT/kawa.xcodeproj" \
  -scheme kawa \
  -configuration Release \
  -derivedDataPath "$DERIVED" \
  build -quiet

APP="$DERIVED/Build/Products/Release/Kawa.app"
codesign --verify --deep "$APP"

# Disk image with Kawa.app and a shortcut to /Applications for drag-to-install.
STAGING="$(mktemp -d)"
trap 'rm -rf "$STAGING"' EXIT
ditto "$APP" "$STAGING/Kawa.app"
ln -s /Applications "$STAGING/Applications"

rm -f "$DMG"
hdiutil create -quiet -volname "Kawa" -srcfolder "$STAGING" -fs HFS+ -format UDZO "$DMG"
echo "$DMG"
