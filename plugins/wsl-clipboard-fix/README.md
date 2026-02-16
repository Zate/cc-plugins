# WSL Clipboard Fix

Fixes image pasting in Claude Code on WSL2.

## The Problem

Claude Code's Linux clipboard detection checks for `image/png`, `image/jpeg`, etc., but Windows copies images as `image/bmp` by default. WSLg forwards this format unchanged via Wayland, so Claude Code never detects clipboard images on WSL2.

Additionally, Windows Terminal intercepts `Ctrl+V` for text paste, preventing Claude Code's image paste shortcut from working.

**Related issues:**
- [anthropics/claude-code#13738](https://github.com/anthropics/claude-code/issues/13738) - Clipboard image paste not working in WSL
- [anthropics/claude-code#25935](https://github.com/anthropics/claude-code/issues/25935) - Add image/bmp to Linux clipboard check

## How It Works

This plugin runs a background daemon (`clip2png`) that:

1. Polls the Wayland clipboard every 2 seconds
2. Detects when BMP image content is present
3. Converts BMP to PNG using ImageMagick
4. Writes the PNG back to the clipboard via `wl-copy`

The daemon starts automatically when a Claude Code session begins and stops when it ends. On non-WSL systems, the hooks silently do nothing.

## Requirements

- **WSL2** with WSLg (Windows 11)
- **wl-clipboard** - Wayland clipboard tools (`wl-paste`, `wl-copy`)
- **ImageMagick** - Image conversion (`convert` command)

Install dependencies:

```bash
sudo apt install wl-clipboard imagemagick
```

## Installation

```
/plugin marketplace add Zate/cc-plugins
/plugin install wsl-clipboard-fix
```

## Keybinding (Recommended)

Since Windows Terminal intercepts `Ctrl+V`, add an `Alt+V` binding for image paste.

Create `~/.claude/keybindings.json`:

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

## Usage

Once installed, the plugin works automatically:

1. Copy an image on Windows (screenshot, right-click Copy, etc.)
2. Wait ~2 seconds for the background conversion
3. Press `Alt+V` in Claude Code
4. The image pastes successfully

## Manual Commands

The `clip2png` script can also be used directly:

```bash
# One-shot conversion
~/.claude/plugins/cache/.../scripts/clip2png --once

# Check daemon status
~/.claude/plugins/cache/.../scripts/clip2png --status

# Stop daemon manually
~/.claude/plugins/cache/.../scripts/clip2png --stop
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Image not pasting | Run `wl-paste -l` to check clipboard formats |
| `wl-paste` not found | `sudo apt install wl-clipboard` |
| `convert` not found | `sudo apt install imagemagick` |
| Wayland not available | Run `wsl --update` from Windows, check `$WAYLAND_DISPLAY` |
| Daemon not starting | Check `/tmp/clip2png.log` for errors |
| Alt+V not working | Verify `~/.claude/keybindings.json` format (object with bindings array) |

## How It Relates to the Upstream Fix

This plugin is a **workaround** for missing BMP support in Claude Code's clipboard detection. If/when [#25935](https://github.com/anthropics/claude-code/issues/25935) is merged upstream (adding `image/bmp` to the grep pattern), this plugin will no longer be necessary for BMP detection. However, the keybinding fix for Windows Terminal will still apply.
