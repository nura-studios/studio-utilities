# MPV for Artists 🎨

A custom MPV media player setup designed specifically for artists, animators, and creative professionals. This enhanced version provides smart interaction modes, powerful file management, and streamlined workflows for working with mixed media projects.

## Why MPV for Artists?

Traditional media players aren't built for creative workflows. This custom MPV setup provides:

- **Smart Media Modes**: Different behaviors for videos (frame-by-frame), images (gallery mode), and audio
- **Quick File Operations**: Copy, rename, delete, and organize files without leaving the player
- **Snapshot Management**: Intelligent screenshot naming with auto-incrementing
- **Attempt File Workflow**: Perfect for iterative creative work with versioned files
- **Frame-Perfect Navigation**: Essential for animation reference and video analysis

## ✨ Key Features

### 🧠 Smart Interaction Modes

The player automatically adapts based on your media type:

- **🎬 Video Mode**: Mouse wheel for frame-by-frame navigation, perfect for animation reference
- **🖼️ Image Mode**: Browse through image sequences, great for concept art galleries
- **🎵 Audio Mode**: Navigate audio references while filtering out other media types

### 🔧 Artist-Friendly Tools

- **Attempt File Management**: Work with versioned files (`scene_attempt_001.mp4`, `scene_attempt_002.mp4`)
- **Smart Snapshots**: Auto-numbered screenshots that don't overwrite existing files
- **Quick File Operations**: Copy, rename, delete, and organize without switching apps
- **Clipboard Integration**: Copy frames directly to clipboard for quick sharing

### ⚡ Streamlined Navigation

- **Looping Playlists**: Never get stuck at the beginning/end of your media library
- **Media Type Filtering**: Focus only on the content type you're working with
- **One-Click Fullscreen**: Multiple ways to toggle fullscreen mode

## 🚀 Installation

### Prerequisites

- Windows 10/11 (PowerShell required)
- MPV media player

### Setup Instructions

1. **Download MPV**

   ```bash
   # Download from: https://mpv.io/installation/
   # Or use chocolatey:
   choco install mpv
   ```

2. **Clone This Repository**

   ```bash
   git clone https://github.com/yourusername/mpv-for-artists.git
   cd mpv-for-artists
   ```

3. **Install the Custom Script**

   - Copy the `portable_config` folder to your MPV installation directory
   - Or place it in `%APPDATA%/mpv/` for user-specific installation

4. **Launch MPV**
   - Open any media file with MPV
   - The custom features will automatically load

## 🎯 Usage Guide

### Basic Navigation

| Key/Action              | Function                   |
| ----------------------- | -------------------------- |
| `h`                     | Show/hide custom help      |
| `Enter` or Middle Click | Toggle fullscreen          |
| `Left/Right`            | Frame-by-frame navigation  |
| `Up/Down`               | Navigate filtered playlist |

### File Management

| Key      | Function                                       |
| -------- | ---------------------------------------------- |
| `s`      | Select: Copy file without `_attempt_##` suffix |
| `ctrl+s` | Take numbered snapshot                         |
| `ctrl+c` | Copy current frame to clipboard                |
| `DEL`    | Move current file to recycle bin               |
| `F2`     | Rename current file                            |
| `\`      | Toggle attempt files visibility                |

### Smart Modes (Auto-Detected)

**🎬 Video Mode** (when opening .mp4, .avi, .mkv, etc.)

- Mouse wheel = Frame advance (perfect for animation)
- Up/Down arrows = Navigate only video files
- Alt+wheel = Navigate only video files

**🖼️ Image Mode** (when opening .jpg, .png, .gif, etc.)

- Mouse wheel = Navigate through images only
- Spacebar = Next image
- Up/Down arrows = Navigate only image files

**🎵 Audio Mode** (when opening .mp3, .wav, .flac, etc.)

- Mouse wheel = Navigate through audio files only
- Up/Down arrows = Navigate only audio files

## 🎨 Artist Workflows

### Animation Reference Workflow

1. Open a video file → Automatically enters **Video Mode**
2. Use mouse wheel for precise frame-by-frame analysis
3. Press `ctrl+c` to copy reference frames to clipboard
4. Press `ctrl+s` to save numbered screenshots for later use

### Concept Art Review Workflow

1. Open an image file → Automatically enters **Image Mode**
2. Use mouse wheel or spacebar to browse through concept variants
3. Press `s` to copy images without attempt suffixes for final versions
4. Press `DEL` to quickly remove rejected concepts

### Iterative Work with Attempt Files

1. Work with files named like: `character_design_attempt_001.jpg`
2. Press `\` to toggle visibility of attempt files (variant mode)
3. Press `s` to create clean copies without attempt suffixes
4. Automatically maintains version numbering for snapshots

### Mixed Media Project Navigation

1. Open any file type in a mixed media folder
2. Navigation automatically filters by media type
3. Use Up/Down to stay focused on current media type
4. Switch files to change interaction mode as needed

## 🔧 Customization

### Adding File Extensions

Edit the `media_extensions` table in the script to support additional formats:

```lua
local media_extensions = {
    image = {".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp", ".tiff", ".tga", ".psd"},
    video = {".mp4", ".avi", ".mkv", ".mov", ".wmv", ".flv", ".webm", ".m4v"},
    audio = {".mp3", ".wav", ".flac", ".ogg", ".aac", ".m4a", ".wma"}
}
```

### Modifying Hotkeys

The script uses standard MPV key binding syntax. Modify the bindings at the bottom of the script file.

## 🐛 Troubleshooting

**Mouse wheel not working correctly:**

- Ensure you're using the latest MPV version
- Check Windows mouse settings for custom scroll behaviors

**File operations failing:**

- Run MPV as administrator if working with protected directories
- Verify PowerShell execution policy allows script execution

**Smart modes not switching:**

- Check that file extensions are recognized in the script
- Look at console output for debug messages

## 🤝 Contributing

This project is designed for the creative community. Contributions welcome!

1. Fork the repository
2. Create a feature branch
3. Submit a pull request with detailed description

### Ideas for Future Features

- Custom thumbnail generation
- Batch file operations
- Integration with creative software
- Timeline markers for video reference
- Custom metadata tagging

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built on the excellent [MPV media player](https://mpv.io/)
- Designed for the creative community
- Inspired by artist workflow needs

---

**Made with ❤️ for artists, animators, and creative professionals**

_Transform your media viewing experience with tools built for creative workflows._
