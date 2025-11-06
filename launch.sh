#!/bin/bash

# NaloFocus Launch Script
# This script builds and launches the NaloFocus app with proper bundle configuration

echo "🚀 Building and launching NaloFocus..."

# Build the project
echo "📦 Building..."
swift build -c debug

if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

# Create app bundle structure
APP_NAME="NaloFocus"
BUILD_DIR=".build/debug"
BUNDLE_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$BUNDLE_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "🔨 Creating app bundle..."

# Clean up old bundle
rm -rf "$BUNDLE_DIR"

# Create bundle directories
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy executable
cp "$BUILD_DIR/$APP_NAME" "$MACOS_DIR/$APP_NAME"

# Copy Info.plist if it exists
if [ -f "Info.plist" ]; then
    cp "Info.plist" "$CONTENTS_DIR/Info.plist"
    echo "✅ Info.plist copied"
fi

# Make executable
chmod +x "$MACOS_DIR/$APP_NAME"

echo "✅ App bundle created at $BUNDLE_DIR"
echo ""
echo "======================================"
echo "         LAUNCH INSTRUCTIONS          "
echo "======================================"
echo ""
echo "Option 1: Open in Xcode (Recommended)"
echo "  Run: open Package.swift"
echo "  Then press Cmd+R to run"
echo ""
echo "Option 2: Run directly"
echo "  Run: .build/debug/NaloFocus.app/Contents/MacOS/NaloFocus"
echo ""
echo "Option 3: Open app bundle"
echo "  Run: open .build/debug/NaloFocus.app"
echo ""
echo "======================================"
echo ""
echo "🎯 Launching NaloFocus..."

# Launch the app
open "$BUNDLE_DIR"