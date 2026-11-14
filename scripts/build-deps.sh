#!/bin/bash
# Builds MASShortcut for Apple Silicon (arm64) into Carthage/Build/Mac.
#
# Carthage is not required: the pinned version from Cartfile.resolved is
# checked out and built directly with xcodebuild.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(awk '/MASShortcut/ { gsub(/"/, "", $3); print $3 }' "$ROOT/Cartfile.resolved")"
CHECKOUT="$ROOT/Carthage/Checkouts/MASShortcut"
OUTPUT="$ROOT/Carthage/Build/Mac"
DERIVED="$(mktemp -d)"
trap 'rm -rf "$DERIVED"' EXIT

if [ ! -d "$CHECKOUT/.git" ]; then
  git clone --quiet https://github.com/shpakovski/MASShortcut.git "$CHECKOUT"
fi
git -C "$CHECKOUT" fetch --quiet --tags
git -C "$CHECKOUT" checkout --quiet "$VERSION"

xcodebuild \
  -project "$CHECKOUT/MASShortcut.xcodeproj" \
  -scheme MASShortcut \
  -configuration Release \
  -derivedDataPath "$DERIVED" \
  ARCHS=arm64 \
  ONLY_ACTIVE_ARCH=NO \
  MACOSX_DEPLOYMENT_TARGET=12.0 \
  GCC_TREAT_WARNINGS_AS_ERRORS=NO \
  CODE_SIGN_IDENTITY=- \
  build -quiet

mkdir -p "$OUTPUT"
rm -rf "$OUTPUT/MASShortcut.framework"
cp -R "$DERIVED/Build/Products/Release/MASShortcut.framework" "$OUTPUT/"
echo "Built MASShortcut $VERSION (arm64) into $OUTPUT"
