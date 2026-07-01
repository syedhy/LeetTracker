#!/bin/bash

# Exit on error
set -e

echo "🚀 Building LeetTracker Release..."

# Clean and build the project
xcodebuild -project LeetTracker.xcodeproj \
           -scheme LeetTracker \
           -configuration Release \
           -destination 'platform=macOS' \
           clean build \
           CONFIGURATION_BUILD_DIR="$(pwd)/build"

echo "✅ Build complete."

# Check if create-dmg is installed
if ! command -v create-dmg &> /dev/null
then
    echo "❌ create-dmg could not be found. Please install it using: brew install create-dmg"
    exit 1
fi

echo "📦 Packaging LeetTracker into a DMG..."

# Remove old DMG if exists
rm -f build/LeetTracker.dmg

# Create DMG
create-dmg \
  --volname "LeetTracker" \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 100 \
  --icon "LeetTracker.app" 175 190 \
  --hide-extension "LeetTracker.app" \
  --app-drop-link 425 190 \
  "build/LeetTracker.dmg" \
  "build/LeetTracker.app"

echo "✅ Packaging complete. Your DMG is located at build/LeetTracker.dmg"
