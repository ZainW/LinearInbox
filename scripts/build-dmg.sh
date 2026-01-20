#!/bin/bash
set -e

# Build and package LinearInbox as a DMG for distribution
# Usage: ./scripts/build-dmg.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build"
DIST_DIR="$PROJECT_DIR/dist"
APP_NAME="LinearInbox"
SCHEME="LinearInbox"

cd "$PROJECT_DIR"

echo "==> Cleaning previous builds..."
rm -rf "$BUILD_DIR"
rm -rf "$DIST_DIR"
mkdir -p "$BUILD_DIR"
mkdir -p "$DIST_DIR"

echo "==> Building $APP_NAME (Release)..."
xcodebuild \
    -project "$APP_NAME.xcodeproj" \
    -scheme "$SCHEME" \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR" \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    build

# Find the built app
APP_PATH=$(find "$BUILD_DIR" -name "$APP_NAME.app" -type d | head -n 1)

if [ -z "$APP_PATH" ]; then
    echo "Error: Could not find $APP_NAME.app in build output"
    exit 1
fi

echo "==> Found app at: $APP_PATH"

# Get version from Info.plist
VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$APP_PATH/Contents/Info.plist" 2>/dev/null || echo "1.0")
BUILD=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$APP_PATH/Contents/Info.plist" 2>/dev/null || echo "1")

DMG_NAME="$APP_NAME-$VERSION.dmg"
DMG_PATH="$DIST_DIR/$DMG_NAME"

echo "==> Creating DMG: $DMG_NAME"

# Create a temporary directory for DMG contents
DMG_TEMP="$BUILD_DIR/dmg-temp"
mkdir -p "$DMG_TEMP"

# Copy the app
cp -R "$APP_PATH" "$DMG_TEMP/"

# Create a symbolic link to Applications
ln -s /Applications "$DMG_TEMP/Applications"

# Create the DMG
hdiutil create \
    -volname "$APP_NAME" \
    -srcfolder "$DMG_TEMP" \
    -ov \
    -format UDZO \
    "$DMG_PATH"

echo ""
echo "==> Build complete!"
echo "    App version: $VERSION ($BUILD)"
echo "    DMG location: $DMG_PATH"
echo ""
echo "To install:"
echo "  1. Open the DMG"
echo "  2. Drag $APP_NAME to Applications"
echo "  3. Right-click the app and select 'Open' (required for unsigned apps)"
echo ""

# Calculate SHA256 for Homebrew cask
SHA256=$(shasum -a 256 "$DMG_PATH" | awk '{print $1}')
echo "SHA256 (for Homebrew cask): $SHA256"
