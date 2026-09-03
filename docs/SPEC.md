# NaloFocus - Calendar Slot Picker - Spec

When a reminder is created from a Calendar.app time slot, NaloFocus pops a floating
picker so an EXISTING reminder can take that slot instead of the placeholder.

- Session: `nalo-feat-sched-popup` (main-mac), bound to `~/Projects/kahunacodes/active/NaloFocus`
- Branch: `feat/calendar-slot-picker` (off `main`)
- Linear: [KAH-153](https://linear.app/kahunacodes/issue/KAH-153) (Development). Supersedes the canceled KAH-118 (wrong scope, wrong GitHub link).
- Spec written 2026-09-01, signed off 2026-09-02. Status: **core verified 2026-09-03, v1 scope
  frozen; step 5 (deploy + burn-in) in progress.**

## Definition of Done (fill in BEFORE any implementation; get sign-off)

- [x] Core works end-to-end on main-mac: double-click a Calendar slot, switch to Reminder,
      press Return, the NaloFocus panel appears within ~1s, pick a reminder, the picked
      reminder lands on the slot, the placeholder is gone, Calendar redraws on its own.
      Escape keeps the placeholder as a normal new reminder. *(2026-09-03 03:23, "Tom (Soup)
      Website" onto the 04:45 slot, panel ~1.0s after Return, verified with reminders-cli)*
- [x] README section a stranger could run from: build, bundle, sign, install, grant
      Reminders access, toggle the feature, troubleshoot (no panel, TCC re-prompt, log command).
- [x] Error handling and logging on failure paths: every EventKit failure logs through
      `os.Logger` (subsystem `com.kahunacodes.NaloFocus`); no silent `catch`; a failed fetch
      never stops the watcher; the placeholder is removed only after the picked reminder saved.
- [x] Deployed to its actual runtime: `/Applications/NaloFocus.app` on main-mac, built from
      the repo `Info.plist`, signed with a stable identity, launched as a Login Item.
      Not `swift run`. *(2026-09-03, `make install`, signed "NaloFocus Dev", login item added)*
- [x] Secrets externalized: none exist (EventKit only). Stated here so the box is honest.
- [x] Burn-in period defined and stated: 7 days of daily use on main-mac, 2026-09-03 to
      2026-09-10 (plan below).
- [ ] Tracking issue closed with a one-line outcome note after burn-in (KAH-153).
      `docs/KNOWN_ISSUES.md` #1 closed 2026-09-03 (bare-binary cause confirmed).

## Repo / session work (done 2026-09-01, kept here so the next session doesn't redo it)

| Item | State |
|---|---|
| Only clone was on gucci with an uncommitted 2-file diff from 2025-11-17 | Committed as `72d1491` on `wip/search-focus`, pushed |
| No clone on main-mac | Cloned to `~/Projects/kahunacodes/active/NaloFocus`, session bound (`tm bind`) |
| Toolchain on main-mac | Swift 6.3.3, Xcode at `/Applications/Xcode.app`, macOS 26.5 |
| Code-signing identity on main-mac | None (`security find-identity -p codesigning` = 0) |
| Prior install / TCC grant for NaloFocus | None |
| `wip/search-focus` fate | Builds clean on main-mac (worktree `NaloFocus-worktrees/wip-search-focus`, 0 warnings). Merge vs cherry-pick decided by the #1 test in step 0 |
| Baseline `swift build` on `main` | Clean, 11s, 0 warnings (2026-09-01) |

## Problem

Calendar.app on macOS 26.5 can create a NEW reminder in a time slot and can drag reminders
between slots, but it cannot pull an EXISTING reminder into a slot. Scheduling a backlog
reminder today means: create a placeholder in Calendar, open Reminders, find the real one,
retype the date and time, delete the placeholder. NaloFocus already owns both halves of the
fix (`ReminderManager.updateReminderAlarm` moves a reminder to a time,
`ReminderSelectionModal` is a grouped, searchable picker). This feature wires them to
Calendar's create action.

## v1 Scope (LOCKS the moment the core works)

1. **Store watcher.** Observe `.EKEventStoreChanged` on the app's own `EKEventStore`. Keep a
   snapshot of incomplete-reminder identifiers with a due date in [now-1d, now+400d]
   (`predicateForIncompleteReminders(withDueDateStarting:ending:calendars:)`, keeps the
   1,274-item store cheap). On each change: debounce 300ms, re-fetch, diff.
   Candidate = new identifier AND `creationDate` within the last 15s AND a timed due date
   (`dueDateComponents.hour != nil`).
2. **Trigger gate.** Candidate AND `NSWorkspace.shared.frontmostApplication?.bundleIdentifier
   == "com.apple.iCal"` (verified id on this machine). Then wait for quiescence (no further
   store change for 600ms), re-fetch the candidate by identifier, and show the panel.
   One panel at a time; ignore changes while a panel is open; ignore changes for 2s after
   NaloFocus's own saves.
3. **Panel.** A floating, non-activating `NSPanel` (Calendar keeps focus) positioned at the
   mouse, clamped to the screen's visible frame, hosting `ReminderSelectionModal` with new
   optional parameters (defaults preserve the sprint-dialog behaviour): header shows the
   slot time, default tab "No Time Set", search prefilled with the placeholder title when it
   is not the default "New Reminder" or empty, Return in the search field picks the first
   filtered match. Escape or Cancel closes the panel and keeps the placeholder.
4. **Swap.** `ReminderManager.reschedule(_:to:replacing:)`: picked reminder gets
   `dueDateComponents` + one absolute `EKAlarm` at the slot time (same shape as
   `updateReminderAlarm`), placeholder removed, one `commit()`. Save the picked reminder
   first; if that throws, the placeholder stays and the error is logged. Calendar redraws
   because it watches the same store, so drag-to-reschedule afterwards is free.
5. **Kill switch.** Menu bar toggle backed by `@AppStorage("calendarSlotPickerEnabled")`,
   default on. Off means the watcher is not even subscribed.
6. **Bundle and deploy fixes** (needed to test anything with EventKit): `make install`
   currently writes a minimal Info.plist WITHOUT the Reminders usage strings, so the access
   request fails in a release install. Fix it to copy the repo `Info.plist` like `launch.sh`
   does, and codesign both paths.
7. **KNOWN_ISSUES #1** (search field beeps): the picker IS this feature's UX, so the bug is
   in scope. Test the hypothesis in Design before touching code.

## Out of Scope (v2 candidates: file, don't build)

- Arrow-key row navigation in the picker (v1 has Return-first-match only)
- Undo after a swap (restore the placeholder)
- In-app Login Item registration via `SMAppService` (v1 uses a manual Login Item)
- iOS / iPadOS anything. Reminders sync carries the result to every device.
- Hijacking Calendar's own popover through the Accessibility API. Rejected: breaks every OS update.
- Triggering on reminders created from other apps (Things, Raycast). Calendar-frontmost gate only.
- Repo housekeeping: stray `Info 2.plist` / `Info 3.plist`, the 17-file docs sprawl,
  `Sources/NaloFocusTests/main.swift` oddity, SwiftLint install.

## Design

### Detection: why a diff and not a payload
`.EKEventStoreChanged` is coalesced and carries no payload, so the only reliable "what's new"
is snapshot-and-diff. `creationDate` is the guard against false positives from reminders that
merely moved INTO the date window (a reschedule of an old reminder is not a new reminder).

### Panel: why AppKit, not a SwiftUI `Window`
SwiftUI scenes cannot be non-activating. The Spotlight pattern is an `NSPanel` subclass with
`styleMask` containing `.nonactivatingPanel`, `level = .floating`, `canBecomeKey` overridden
to `true` (without that override no text field receives keystrokes), `canBecomeMain = false`,
`hidesOnDeactivate = false`, content = `NSHostingView(rootView: ReminderSelectionModal(...))`.
The controller owns an `ObservableObject` that backs the modal's `isPresented` /
`selectedReminder` bindings; when `isPresented` flips false it performs the swap (selection
set) or cancels (nil) and closes the panel. Panel size 440x520 (the sheet keeps 500x600).

### Concurrency
Everything stays `@MainActor`, matching the codebase. Observation uses the async sequence
`NotificationCenter.default.notifications(named: .EKEventStoreChanged, object: store)`
inside a `Task` owned by the watcher, so cancellation is one `task?.cancel()`.
`EKReminder` objects must come from the same `EKEventStore` they are saved to, so the
watcher takes the store from `ReminderManager` rather than creating its own.

### KNOWN_ISSUES #1 hypothesis (test before coding)
A bare SPM executable (`swift run`, `run.sh`) has no bundle and no bundle identifier, so the
text input server (TSM) refuses the process and `NSTextField` beeps on every key: cursor
blinks, no text, error beep. That matches the report better than a SwiftUI focus bug, and
the 2025-11-17 repro ran in DEBUG (window) mode, which `swift run` gives you.
Test: same build through `launch.sh` (bundle). If it types, #1 was an environment bug:
drop the `asyncAfter` focus hack from `wip/search-focus`, keep the clear button, and
document "always run the bundle." Second hypothesis if the bundle still beeps: an
accessory-policy app whose window never became key; fix is `NSApp.activate(ignoringOtherApps:
true)` when the sprint window opens.

### Assumptions, resolved 2026-09-03 on main-mac (macOS 26.5, Swift 6.3.3)
- **A1 (Calendar save timing): one save, on Return.** The placeholder produced a single
  0.64s burst and the panel appeared after Return, not while the popover was open.
  Quiescence stays at 600ms.
- **A2 (notification latency): 30ms** from the placeholder's `creationDate` to
  `.EKEventStoreChanged`. Panel on screen ~1.0s after Calendar's save; the fetch and
  categorize of the 1,274-item store is most of that.
- **A3 (non-activating panel): holds.** Typing lands in the search field with the front app
  unchanged (Claude Desktop stayed frontmost); Return picks the first match.
- **A4 (TCC across rebuilds): an unchanged ad-hoc binary relaunches without a prompt.** A
  self-signed "NaloFocus Dev" identity was created with `scripts/make-signing-cert.sh` (no
  GUI prompts were needed) and `scripts/bundle.sh` picks it up automatically; the release
  install is the first build signed with it. Fallback if a prompt loops:
  `tccutil reset Reminders com.kahunacodes.NaloFocus`.
- **KNOWN_ISSUES #1 hypothesis: confirmed.** The sheet's search field types normally from
  the bundle. Closed in `docs/KNOWN_ISSUES.md`.

Soak before install: the debug bundle ran 17h48m at 23MB, 68 change bursts, 20 new
reminders seen (phone syncs including a 5-item burst, Reminders.app edits, one Calendar
placeholder), 1 correct popup, 0 false popups, 0 errors. First live swap: "Tom (Soup)
Website" onto the 2026-09-03 04:45 slot, placeholder removed, verified with reminders-cli.

### Files

| File | Change |
|---|---|
| `Makefile`, `launch.sh` | bundle with repo `Info.plist`, codesign, `install` target fixed |
| `Services/ReminderStoreWatcher.swift` | NEW: snapshot, diff, gate, quiescence, logging |
| `Services/ReminderManager.swift` + `ReminderManagerProtocol.swift` | `fetchIncompleteReminders(dueBetween:)`, `reschedule(_:to:replacing:)`, store change stream, `lastOwnSaveAt` |
| `Views/SlotPickerPanel.swift` | NEW: `NSPanel` subclass + controller hosting the modal |
| `Views/ReminderSelectionModal.swift` | optional `title`, `initialTab`, `initialSearch`, `size`, `onSubmit` first-match |
| `Models/AppStateCoordinator.swift` | start/stop watcher after permission, honour the toggle |
| `Views/MenuBarContentView.swift` | the kill-switch toggle |
| `README.md`, `docs/KNOWN_ISSUES.md`, `docs/DECISIONS.md` | usage, #1 outcome, one ADR |

Roughly 350 new lines. No new dependencies.

### Build order (one commit per step, pushed)
0. Baseline `swift build` on `main` and on `wip/search-focus` (both clean, done 2026-09-01);
   run the #1 hypothesis test through `launch.sh` (needs the user at the keyboard: it is a
   GUI typing test and the first launch triggers the Reminders TCC prompt); merge or
   cherry-pick the wip branch; record the outcome in KNOWN_ISSUES.
1. Bundle + sign + `make install`; grant Reminders access to the installed app. Resolves A4.
2. `ReminderStoreWatcher` with a logging-only trigger. Do the Calendar flow, read the log.
   Resolves A1 and A2, and fixes the quiescence numbers.
3. `SlotPickerPanel` + modal parameters, shown from a debug menu item first. Resolves A3.
4. Coordinator wiring, swap, kill switch. Core works here: **scope freezes**.
5. Docs, KNOWN_ISSUES, ADR, README. Install to `/Applications`, Login Item. Start burn-in.

## Deployment Target

main-mac, `/Applications/NaloFocus.app`, launched as a Login Item (System Settings, General,
Login Items). No ports, no Caddy, no LaunchAgent. Logs:

```bash
log stream --predicate 'subsystem == "com.kahunacodes.NaloFocus"' --level debug
log show --predicate 'subsystem == "com.kahunacodes.NaloFocus"' --last 1d
```

away-mac gets the same install once it is reachable again (offline on 2026-09-01).

## Burn-in Plan

7 days of daily use on main-mac, starting the day step 5 lands.
Healthy: every Calendar-created timed reminder shows the panel within 1s; zero panels when
Calendar is not frontmost; zero duplicated or lost reminders; no TCC re-prompt after the
signed install. Failures surface as a missing panel (check `log show`), a re-prompt
(signing regressed), or a leftover placeholder with a rescheduled twin (swap commit failed
midway, logged). The user checks daily; anything found reopens session
`nalo-feat-sched-popup`. After 7 clean days: close the Linear issue with the outcome line.
