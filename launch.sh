#!/bin/bash
#
# Build, bundle (debug) and launch NaloFocus as a real .app.
# Always launch the bundle: a bare `swift run` binary can neither get Reminders access nor
# accept keyboard input in text fields (no bundle identifier for the text input server).
#
# Usage:  ./launch.sh [open options]
#         ./launch.sh --env NALOFOCUS_TEST_PANEL=1     preview the Calendar slot picker with a fake slot

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

APP="$(scripts/bundle.sh debug)"

# Relaunch semantics: a running copy would just be activated by `open`
pkill -x NaloFocus 2>/dev/null || true
sleep 0.3

echo "Launching $APP"
open "$@" "$APP"
echo "Logs: log stream --predicate 'subsystem == \"com.kahunacodes.NaloFocus\"' --level debug"
