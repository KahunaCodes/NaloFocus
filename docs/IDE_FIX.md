# Fixing VS Code SourceKit Errors

## Problem
VS Code shows "Cannot find 'ReminderSelectionModal' in scope" even though `swift build` succeeds perfectly.

## Root Cause
This is a **SourceKit indexing issue**, not an actual code problem. The Swift compiler knows where the file is, but the IDE's language server cache is stale.

## Solutions (Try in order)

### Solution 1: Restart Swift Language Server (Quickest)
1. Open Command Palette: `Cmd+Shift+P`
2. Type: "Swift: Restart Language Server"
3. Press Enter
4. Wait 10-15 seconds for reindexing

### Solution 2: Reload VS Code Window
1. Open Command Palette: `Cmd+Shift+P`
2. Type: "Developer: Reload Window"
3. Press Enter

### Solution 3: Clean Build (Already Done)
```bash
rm -rf .build .swiftpm
swift build
```
✅ We already did this - build successful!

### Solution 4: Restart VS Code Completely
1. Quit VS Code: `Cmd+Q`
2. Reopen the project
3. Wait for Swift extension to index

### Solution 5: Clear VS Code Cache
```bash
# Close VS Code first
rm -rf ~/Library/Application\ Support/Code/Cache/*
rm -rf ~/Library/Application\ Support/Code/CachedData/*
# Then reopen VS Code
```

## Running the App

### From Terminal (Recommended for Testing)
```bash
# Run directly
swift run NaloFocus

# Or build release and run
swift build -c release
.build/release/NaloFocus
```

### From VS Code Debugger
The "Release NaloFocus" option should work, but if it freezes:
1. Make sure no other instance is running
2. Check if menu bar app is already in system menu
3. Kill any existing process:
   ```bash
   pkill NaloFocus
   ```

## Why This Happens
- SourceKit maintains its own index of Swift files
- Sometimes gets out of sync with actual file structure
- `swift build` uses the real Swift compiler (always correct)
- IDE shows errors but code compiles fine
- Common with Swift Package Manager projects

## Verification
If you see this in build output, everything is fine:
```
[7/22] Compiling NaloFocus ReminderSelectionModal.swift
...
Build complete!
```

## Current Status
✅ **Code is correct**
✅ **Build succeeds**
✅ **All files properly included**
⚠️ **IDE needs reindexing** (cosmetic issue only)

The app works perfectly - the IDE just needs to catch up with the changes.