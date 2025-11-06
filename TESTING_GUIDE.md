# NaloFocus Testing Guide

## 🚀 Quick Start

### Option 1: Open in Xcode (Recommended for UI Testing)
```bash
open Package.swift
```
- Xcode will open the project
- Press **⌘R** (Cmd+R) to build and run
- The app icon will appear in your menu bar

### Option 2: Command Line Build & Run
```bash
# Build and create app bundle
./launch.sh

# Or manually:
swift build
./.build/debug/NaloFocus
```

### Option 3: Test Core Functionality (No UI)
```bash
# Test core logic without UI
swift Tests/test-core.swift

# Interactive CLI testing
swift Tests/cli-interface.swift
```

## 📱 What You Can Test

### 1. Menu Bar Icon
- Look for the **timer icon** (⏱️) in your menu bar
- Click to open the dropdown menu

### 2. Permissions Flow
- On first launch, the app should request Reminders access
- If not automatically prompted:
  1. Click the menu bar icon
  2. Click "Grant Reminders Access"
  3. Follow the system prompt

### 3. Sprint Dialog
- Click "Start New Sprint" from the menu
- A window will open with:
  - Task configuration on the left
  - Timeline preview on the right

### 4. Creating a Sprint
1. Set number of tasks (1-9)
2. Set start time
3. For each task:
   - Select a reminder from the dropdown
   - Adjust duration (5-90 minutes)
   - Toggle break on/off
   - Adjust break duration if enabled
4. Preview the timeline on the right
5. Click "Start Sprint" to schedule

## 🛠️ Troubleshooting

### "Cannot index window tabs due to missing main bundle identifier"
This is a warning that can be ignored. The app will still run.

### Reminders Permission Not Working
1. Go to **System Settings > Privacy & Security > Reminders**
2. Look for NaloFocus or Terminal
3. Grant access manually if needed
4. Restart the app

### App Doesn't Appear in Menu Bar
1. Check Activity Monitor for NaloFocus process
2. Kill any existing instances
3. Run again with `./launch.sh`

### Build Errors
```bash
# Clean build
rm -rf .build
swift build
```

## 🧪 Test Scenarios

### Basic Flow Test
1. Launch app
2. Grant permissions
3. Load reminders
4. Create a 3-task sprint
5. Verify timeline preview
6. Start sprint
7. Check Reminders app for updates

### Permission Denied Test
1. Launch app
2. Deny permissions
3. Verify "Grant Access" button appears
4. Click to re-request permissions

### Sprint Configuration Test
1. Create sprint with varying durations
2. Test with/without breaks
3. Verify timeline calculations
4. Test task removal

## 📊 Expected Behavior

### On First Launch
- Timer icon appears in menu bar
- Permission request appears (if not granted)
- Menu shows permission status indicator

### With Permissions
- "Start New Sprint" is enabled
- Sprint dialog loads reminders
- Can create and schedule sprints

### Without Permissions
- "Start New Sprint" is disabled
- "Grant Reminders Access" button visible
- Orange warning indicator in menu

## 🎯 Current Features Working

✅ Menu bar app with icon
✅ Permission request flow
✅ Load reminders from EventKit
✅ Sprint configuration UI
✅ Timeline preview
✅ Task duration & break configuration
✅ Sprint scheduling to Reminders

## 🚧 Known Limitations

- Swift Package Manager apps don't have full bundle support
- Info.plist configuration requires Xcode project
- Some UI features work better in Xcode build

## 💡 Tips

1. **For best testing experience**: Use Xcode
2. **For quick logic testing**: Use CLI interface
3. **For debugging**: Check Console.app for logs
4. **For permissions**: May need to grant to Terminal/IDE

## 📝 Notes

The app is in Phase 1 of development. Core functionality is working:
- EventKit integration ✅
- Sprint scheduling logic ✅
- Basic UI structure ✅
- Permission handling ✅

Next steps would include:
- Polishing UI design
- Adding more sprint templates
- Implementing quick actions
- Adding notification support