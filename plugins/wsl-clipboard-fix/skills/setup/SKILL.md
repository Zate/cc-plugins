---
name: wsl-clipboard-setup
description: Guide the user through setting up WSL2 clipboard image paste fix - dependency installation, verification, and keybinding configuration
---

# WSL2 Clipboard Fix Setup

Use this skill when the user asks to set up, configure, or troubleshoot WSL2 image pasting in Claude Code.

## When to Use
- User mentions image paste not working in WSL2
- User asks to set up wsl-clipboard-fix
- User asks about pasting images in WSL

## When NOT to Use
- User is on native Linux (not WSL)
- User is on macOS or Windows (not WSL)

## Setup Steps

### Step 1: Verify WSL2 Environment

Check that the user is running WSL2:

```bash
# Should show Microsoft in version string
grep -qi microsoft /proc/version && echo "WSL detected" || echo "Not WSL"

# Should show WSLInterop
ls /proc/sys/fs/binfmt_misc/WSLInterop* 2>/dev/null && echo "WSL2 confirmed" || echo "WSL1 or not WSL"
```

### Step 2: Install Dependencies

Two packages are required:

```bash
sudo apt update && sudo apt install -y wl-clipboard imagemagick
```

Verify:
```bash
wl-paste --version
convert --version | head -1
```

If `wl-paste` cannot connect to Wayland, ensure WSLg is working:
```bash
echo $WAYLAND_DISPLAY  # Should show "wayland-0" or similar
ls /mnt/wslg/runtime-dir/wayland-0 2>/dev/null && echo "WSLg OK" || echo "WSLg not available"
```

### Step 3: Verify Plugin Hook

The plugin automatically starts the clip2png watcher on session start. Verify it works:

```bash
# Test manual conversion
"${CLAUDE_PLUGIN_ROOT}/scripts/clip2png" --once

# Check daemon status
"${CLAUDE_PLUGIN_ROOT}/scripts/clip2png" --status
```

### Step 4: Configure Keybinding (Optional but Recommended)

Windows Terminal intercepts Ctrl+V for text paste. To paste images in Claude Code, bind Alt+V:

Create or edit `~/.claude/keybindings.json`:

```json
{
  "bindings": [
    {
      "context": "Chat",
      "bindings": {
        "alt+v": "chat:imagePaste"
      }
    }
  ]
}
```

**Important:** The file must have an object with a `bindings` array at the top level, NOT a bare array.

### Step 5: Test

1. Copy an image on Windows (e.g., screenshot with Win+Shift+S, or right-click an image and Copy)
2. Wait ~2 seconds for the watcher to convert BMP to PNG
3. Press Alt+V (or your configured key) in Claude Code
4. The image should paste successfully

### Troubleshooting

| Issue | Solution |
|-------|----------|
| `wl-paste` not found | `sudo apt install wl-clipboard` |
| `convert` not found | `sudo apt install imagemagick` |
| Wayland not available | Update to Windows 11 with WSLg support, or run `wsl --update` |
| Daemon not starting | Check `cat /tmp/clip2png.log` for errors |
| Image still not pasting | Run `wl-paste -l` to check clipboard formats; run `clip2png --once` manually |
| Alt+V not working | Check `~/.claude/keybindings.json` format (must be object with bindings array) |
