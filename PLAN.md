# Implementation Plan: Replace Power Button with Microphone Toggle

## Overview
Replace the PowerButton in the control center's 2x2 grid with a MicrophoneToggle button that displays microphone state and allows mute/unmute control.

## What We'll Change

### 1. Create New Component: MicrophoneToggle.qml
**Location:** `features/system_panels/controlcenter/cc_modules/MicrophoneToggle.qml`

Following the exact pattern used by WiFiToggle and BluetoothToggle:
- Use `IconButton` component (stateful toggle)
- Icon: `systemState.volume.micIcon` (󰍬 unmuted / 󰍭 muted)
- Title: "Microphone"
- Subtitle: "Active" when unmuted / "Muted" when muted
- Active state: when microphone is NOT muted
- Click handler: `systemState.volume.toggleMicMute()`

### 2. Update ControlCenterDisplay.qml
**Location:** `features/system_panels/controlcenter/ControlCenterDisplay.qml`

Replace PowerButton (lines 178-182) with MicrophoneToggle:
- Remove `Modules.PowerButton` reference
- Add `Modules.MicrophoneToggle` in the same position
- Pass `systemState` property (already available)
- Keep same layout properties (fillWidth, preferredHeight: 64)

## Why This Works

### Backend Already Complete
The Volume module (`core/system_state/system_state/Volume.qml`) already provides:
- `micMuted` property (boolean state)
- `micIcon` property (auto-switching icon)
- `toggleMicMute()` function
- OSD integration for state changes

### Design Pattern Match
This follows the exact same pattern as existing toggles:
- WiFiToggle uses `systemState.wifi`
- BluetoothToggle uses `systemState.bluetooth`
- MicrophoneToggle will use `systemState.volume`

### Visual Behavior
- **Active (unmuted)**: Primary color background, 󰍬 icon, "Active" subtitle
- **Muted**: Surface color background, 󰍭 icon, "Muted" subtitle
- Smooth animations: 200ms color transitions, 100ms press scale

## Files to Modify

**New Files:**
1. `features/system_panels/controlcenter/cc_modules/MicrophoneToggle.qml` (~15 lines)

**Modified Files:**
1. `features/system_panels/controlcenter/ControlCenterDisplay.qml` (5 lines changed)

**Optional Cleanup:**
- `features/system_panels/controlcenter/cc_modules/PowerButton.qml` (can be removed if not used elsewhere)

## Implementation Steps

1. Create `MicrophoneToggle.qml` component
2. Update `ControlCenterDisplay.qml` to use MicrophoneToggle instead of PowerButton
3. Test microphone toggle functionality
4. Verify state changes and animations work correctly

## Expected Result

Control center 2x2 grid will show:
```
┌──────────────┬──────────────┐
│ WiFi Toggle  │ BT Toggle    │
├──────────────┼──────────────┤
│ Recording    │ Microphone   │  ← Replaces Power Button
└──────────────┴──────────────┘
```

Clicking the microphone button will:
- Toggle microphone mute state
- Update icon and subtitle
- Animate background color change
- Show OSD notification (already integrated)
