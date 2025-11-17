# Known Issues

This document tracks known issues and bugs that need to be addressed in future releases.

## Active Issues

### Issue #1: Search TextField Not Accepting Keyboard Input in ReminderSelectionModal

**Status:** Open
**Priority:** High
**Discovered:** 2025-11-17
**Component:** `ReminderSelectionModal` search functionality

**Description:**
When using the search feature in the Reminder Selection Modal, the search text field displays a blinking cursor but does not accept keyboard input. Instead, it produces a system error sound (keyboard error beep) when attempting to type.

**Steps to Reproduce:**
1. Open Sprint Planning dialog
2. Click on "Select Reminder" for any task
3. Try to type in the search text field at the top of the modal
4. Observe that cursor blinks but no text is entered
5. Hear system error sound with each key press

**Expected Behavior:**
The search text field should accept keyboard input and filter the reminder list as the user types.

**Actual Behavior:**
- Text field shows blinking cursor (suggesting focus)
- No text appears when typing
- System produces error beep sound on key press
- Field appears non-functional despite visual focus indication

**Technical Context:**
- File: `Sources/NaloFocus/Views/ReminderSelectionModal.swift`
- SwiftUI TextField implementation
- Modal presentation context
- macOS 15.0+ target

**Potential Causes:**
1. TextField may not have proper first responder status
2. Modal presentation may be interfering with keyboard event handling
3. Focus state management issue in SwiftUI
4. Possible conflict with parent view's keyboard handling

**Investigation Notes:**
- The blinking cursor suggests the field receives some form of focus
- Error sound indicates keyboard events are being rejected/blocked
- May be related to SwiftUI modal presentation on macOS
- Could be a focus/responder chain issue specific to `.sheet()` presentation

**Related Code:**
- ReminderSelectionModal view implementation
- Search TextField binding and state management
- Modal presentation in SprintDialogView

**Workaround:**
None currently available. Search functionality is temporarily non-functional.

**Next Steps:**
1. Review TextField implementation in ReminderSelectionModal
2. Test focus/responder chain behavior
3. Investigate SwiftUI modal keyboard handling on macOS
4. Consider alternative search implementation if needed
5. Add logging to track focus events and keyboard input

**Priority Justification:**
High priority because search is a key usability feature for users with many reminders. Without search, finding specific reminders becomes cumbersome and impacts the user experience significantly.

---

## Resolved Issues

_(No resolved issues yet)_

---

## Issue Template

When adding new issues, use this template:

```markdown
### Issue #N: [Brief Title]

**Status:** Open | In Progress | Resolved
**Priority:** Low | Medium | High | Critical
**Discovered:** YYYY-MM-DD
**Component:** [File or feature name]

**Description:**
[Clear description of the issue]

**Steps to Reproduce:**
1. Step one
2. Step two
3. ...

**Expected Behavior:**
[What should happen]

**Actual Behavior:**
[What actually happens]

**Technical Context:**
- Relevant files
- System requirements
- Technical details

**Potential Causes:**
- Hypothesis 1
- Hypothesis 2

**Investigation Notes:**
- Finding 1
- Finding 2

**Related Code:**
- References to relevant code sections

**Workaround:**
[If any workaround exists]

**Next Steps:**
1. Action item 1
2. Action item 2

**Priority Justification:**
[Why this priority level]
```

---

## Issue Status Definitions

- **Open**: Issue identified but not yet being worked on
- **In Progress**: Actively being investigated or fixed
- **Resolved**: Issue has been fixed and verified
- **Closed**: Issue resolved and shipped in a release

## Priority Definitions

- **Critical**: Blocks core functionality or causes data loss
- **High**: Significantly impacts user experience or key features
- **Medium**: Noticeable issue but doesn't block main workflows
- **Low**: Minor issue with minimal impact on usage
