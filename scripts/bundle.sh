#!/bin/bash
#
# Build NaloFocus and assemble a signed .app bundle around the executable.
#
# A bare SwiftPM binary has no bundle, so macOS refuses it two things NaloFocus needs:
# Reminders access (TCC keys on the bundle id + Info.plist usage strings) and text input
# (the text input server wants a bundle identifier; without one text fields beep).
#
# Usage:  scripts/bundle.sh [debug|release]      prints the .app path on stdout
# Env:    NALOFOCUS_SIGN_IDENTITY   codesign identity, default "-" (ad-hoc).
#         Ad-hoc signatures change every build, so TCC re-prompts after each rebuild.
#         scripts/make-signing-cert.sh creates a stable self-signed identity.

set -euo pipefail

CONFIG="${1:-debug}"
IDENTITY="${NALOFOCUS_SIGN_IDENTITY:--}"
BUNDLE_ID="com.kahunacodes.NaloFocus"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

case "$CONFIG" in
    debug|release) ;;
    *) echo "usage: $0 [debug|release]" >&2; exit 2 ;;
esac

cd "$ROOT"
swift build -c "$CONFIG" 1>&2

BIN=".build/$CONFIG/NaloFocus"
APP=".build/$CONFIG/NaloFocus.app"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/NaloFocus"
cp Info.plist "$APP/Contents/Info.plist"
chmod +x "$APP/Contents/MacOS/NaloFocus"

codesign --force --sign "$IDENTITY" --identifier "$BUNDLE_ID" "$APP" 1>&2
codesign --verify --deep --strict "$APP" 1>&2
echo "bundled $APP (signed as '$IDENTITY')" >&2

echo "$ROOT/$APP"
