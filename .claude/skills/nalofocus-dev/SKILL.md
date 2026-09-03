---
name: nalofocus-dev
description: Use this skill IMMEDIATELY when working in the NaloFocus repo and the task involves running, launching, installing, signing, testing, or debugging the app, the Calendar slot picker, Reminders (TCC) access, the store watcher log, or "the panel didn't appear". Covers launch.sh, bundle.sh, make install, the signing identity, the test-panel env var, the log predicate, the gate names, and the hand-test checklist.
---

# NaloFocus dev loop

Swift 6 / SwiftUI / EventKit menu bar app, SwiftPM only (no Xcode project). Repo: `~/Projects/kahunacodes/active/NaloFocus` on main-mac (clone also on gucci). Spec and results: `docs/SPEC.md`. Design: ADR-011 in `docs/DECISIONS.md`. Tracking: Linear KAH-153 (v1), KAH-155 (v2 picker ideas).

## Rule zero: always the bundle

A bare `swift run` binary has no bundle id, so text fields beep and TCC refuses Reminders access. Every run goes through `scripts/bundle.sh`, which builds, assembles `.build/<cfg>/NaloFocus.app` around the repo `Info.plist`, and codesigns.

```bash
./launch.sh                                   # debug bundle, kills a running copy, opens it
./launch.sh --env NALOFOCUS_TEST_PANEL=1      # same, plus the slot picker with a fake slot (dry run)
make install                                  # lint + test + release bundle -> /Applications, then: open /Applications/NaloFocus.app
scripts/bundle.sh release                     # just the bundle; prints its path
```

Signing: `bundle.sh` uses the self-signed "NaloFocus Dev" identity automatically when it exists (`security find-identity -v -p codesigning`), else ad-hoc. Ad-hoc means TCC re-prompts after every rebuild. Create the identity once with `scripts/make-signing-cert.sh`. If a prompt loops or access reads denied: `tccutil reset Reminders com.kahunacodes.NaloFocus`, relaunch.

## Reading the app

```bash
log stream --predicate 'subsystem == "com.kahunacodes.NaloFocus"' --level debug   # live
log show --last 1d --predicate 'subsystem == "com.kahunacodes.NaloFocus"' --style compact
```

Categories: `coordinator` (access granted, presenting picker, scheduled / cancelled / dry run), `watcher` (store changed, new reminder + gate verdict). Every new reminder logs one of: `Calendar not frontmost`, `not freshly created`, `no timed due date`, `echo of our own save`, `picker already open`. A candidate that passes logs nothing and is followed by `presenting picker`.

Launch health = two lines within a second of start: `Reminders access granted=true` then `watcher started; tracking N`. No `granted` line means the app is blocked on the TCC dialog (or, before commit `6039629`, was never asked).

## Hand-test checklist (the parts Accessibility scripting cannot do)

1. Test panel typing: `./launch.sh --env NALOFOCUS_TEST_PANEL=1`, type without clicking, Return picks the first match; the front app must stay frontmost.
2. Real flow: Calendar, double-click a slot, Reminder, Return. Panel within ~1s. Pick: reminder moves, placeholder gone (`reminders-cli --action read --dueWithin today` to confirm).
3. Dismissals: Escape, Cancel, red close button, Cmd-W. Each must log `picker cancelled`, and the NEXT placeholder must present again (a missed cancel leaves the watcher paused).
4. Negative: create a reminder in Reminders.app or on the phone; must log an ignore, never a panel.

Accessibility scripting: System Events sees zero windows of this accessory app until `set frontmost to true`; after that `click (first button of window 1 whose subrole is "AXCloseButton")` and `click button "Cancel" of window 1` work, but `key code` may go to whichever window became key, so Escape is a hand test.

## Verify before "done"

- `swift build` with zero warnings, `./scripts/swift-lint.sh` green (no `print(`, no `!.`, lines <= 120), `swift test`.
- Reinstall (`make install`) and relaunch after any change; the installed app is the runtime, not `.build/debug`.
- `git status` clean, commits carry the `Session:` / `Machine:` trailers.

## Gotchas that cost time

- `OSLogMessage` cannot be concatenated with `+`; build a `String`, then interpolate.
- `MenuBarExtra` content `.task` runs on first click, not at launch.
- `NSWindow.willCloseNotification` is the only close signal that covers the red button; detach the panel reference before your own `close()`.
- The picked reminder re-enters the watcher's window on your own commit; `lastOwnSaveAt` suppresses it.
- Recurring reminders completed elsewhere spawn a new occurrence with the original (old) `creationDate`; phone syncs arrive 3 to 10s after creation.
- `cc-sched-send` (for burn-in watches) takes the time as separate tokens: `2026-09-10 9am`, never one quoted string.
