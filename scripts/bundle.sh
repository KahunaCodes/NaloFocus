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
BUNDLE_ID="com.kahunacodes.NaloFocus"
DEV_IDENTITY="NaloFocus Dev"

# Identity: explicit env var > the self-signed dev identity when it exists > ad-hoc
if [[ -n "${NALOFOCUS_SIGN_IDENTITY:-}" ]]; then
    IDENTITY="$NALOFOCUS_SIGN_IDENTITY"
elif security find-identity -v -p codesigning 2>/dev/null | grep -q "\"$DEV_IDENTITY\""; then
    IDENTITY="$DEV_IDENTITY"
else
    IDENTITY="-"
fi
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
