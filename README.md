# Studio Utilities Collection 🎨

A collection of custom utilities designed specifically for artists, animators, and creative professionals. This toolkit provides smart workflows and streamlined tools for common creative tasks.

## Why Studio Utilities?

Traditional software tools aren't always optimized for creative workflows. This collection provides purpose-built utilities that understand artist needs:

- **MPV for Artists**: Enhanced media player with artist-specific features
- **Photoshop Model Sheet Generator**: Automated creation of reference model sheets

---

## 🎬 MPV for Artists

A custom MPV media player setup designed specifically for artists, animators, and creative professionals. This enhanced version provides smart interaction modes, powerful file management, and streamlined workflows for working with mixed media projects.

### Why MPV for Artists?

Traditional media players aren't built for creative workflows. This custom MPV setup provides:

- **Smart Media Modes**: Different behaviors for videos (frame-by-frame), images (gallery mode), and audio
- **Quick File Operations**: Copy, rename, delete, and organize files without leaving the player
- **Snapshot Management**: Intelligent screenshot naming with auto-incrementing
- **Attempt File Workflow**: Perfect for iterative creative work with versioned files
- **Frame-Perfect Navigation**: Essential for animation reference and video analysis

### ✨ Key Features

#### 🧠 Smart Interaction Modes

The player automatically adapts based on your media type:

- **🎬 Video Mode**: Mouse wheel for frame-by-frame navigation, perfect for animation reference
- **🖼️ Image Mode**: Browse through image sequences, great for concept art galleries
- **🎵 Audio Mode**: Navigate audio references while filtering out other media types

#### 🔧 Artist-Friendly Tools

- **Attempt File Management**: Work with versioned files (`scene_attempt_001.mp4`, `scene_attempt_002.mp4`)
- **Smart Snapshots**: Auto-numbered screenshots that don't overwrite existing files
- **Quick File Operations**: Copy, rename, delete, and organize without switching apps
- **Clipboard Integration**: Copy frames directly to clipboard for quick sharing

#### ⚡ Streamlined Navigation

- **Looping Playlists**: Never get stuck at the beginning/end of your media library
- **Media Type Filtering**: Focus only on the content type you're working with
- **One-Click Fullscreen**: Multiple ways to toggle fullscreen mode

### 🚀 MPV Installation

#### Prerequisites

- Windows 10/11 (PowerShell required)
- MPV media player

#### Setup Instructions

1. **Download MPV**

   ```bash
   # Download from: https://mpv.io/installation/
   # Or use chocolatey:
   choco install mpv
   ```

2. **Clone This Repository**

   ```bash
   git clone https://github.com/yourusername/studio-utilities.git
   cd studio-utilities
   ```

3. **Install the Custom Script**

   - Copy the `mpv/portable_config` folder to your MPV installation directory
   - Or place it in `%APPDATA%/mpv/` for user-specific installation

4. **Launch MPV**
   - Open any media file with MPV
   - The custom features will automatically load

### 🎯 MPV Usage Guide

#### Basic Navigation

| Key/Action              | Function                   |
| ----------------------- | -------------------------- |
| `h`                     | Show/hide custom help      |
| `Enter` or Middle Click | Toggle fullscreen          |
| `Left/Right`            | Frame-by-frame navigation  |
| `Up/Down`               | Navigate filtered playlist |

#### File Management

| Key      | Function                                       |
| -------- | ---------------------------------------------- |
| `s`      | Select: Copy file without `_attempt_##` suffix |
| `ctrl+s` | Take numbered snapshot                         |
| `ctrl+c` | Copy current frame to clipboard                |
| `DEL`    | Move current file to recycle bin               |
| `F2`     | Rename current file                            |
| `\`      | Toggle attempt files visibility                |

#### Smart Modes (Auto-Detected)

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

### 🎨 Artist Workflows with MPV

#### Animation Reference Workflow

1. Open a video file → Automatically enters **Video Mode**
2. Use mouse wheel for precise frame-by-frame analysis
3. Press `ctrl+c` to copy reference frames to clipboard
4. Press `ctrl+s` to save numbered screenshots for later use

#### Concept Art Review Workflow

1. Open an image file → Automatically enters **Image Mode**
2. Use mouse wheel or spacebar to browse through concept variants
3. Press `s` to copy images without attempt suffixes for final versions
4. Press `DEL` to quickly remove rejected concepts

#### Iterative Work with Attempt Files

1. Work with files named like: `character_design_attempt_001.jpg`
2. Press `\` to toggle visibility of attempt files (variant mode)
3. Press `s` to create clean copies without attempt suffixes
4. Automatically maintains version numbering for snapshots

#### Mixed Media Project Navigation

1. Open any file type in a mixed media folder
2. Navigation automatically filters by media type
3. Use Up/Down to stay focused on current media type
4. Switch files to change interaction mode as needed

#### Fast Approval Workflow with MPV

MPV is an open source media player that can look at images, audio and video. We've customized it so that there are specialized hotkeys for cycling through media files quickly using the up and down arrow keyboard shortcuts. When you have found an image, video, or audio that you like press the "s" key to make a select. If the currently viewed file has "_attempt_##" in the name, MPV will copy the currently displayed media file with the attempt suffix removed from the filename. The presence of this file will mark it as an approved asset and it will no longer be regenerated during the regeneration process. This means that if you wish to un-approve something, just delete the file with the delete key and the next regeneration will see that no select has been made and will regenerate new attempts for review.

---

## 🎨 Photoshop Model Sheet Generator

An automated Photoshop script that creates professional model sheets for character design and reference. This script intelligently arranges your character reference images into a standardized square-format model sheet perfect for easy editing and presentation.

### What It Does

The Photoshop Model Sheet Generator creates a **linked PSD file model sheet with a square aspect ratio** that's optimized for easy editing of reference model sheets. The script:

- **Automatically finds and arranges** PNG files with keywords: `front`, `back`, `left`, `right`, and `hero`
- **Creates smart object layers** that maintain links to source files for easy updates
- **Generates a 2048x2048 square format** perfect for online portfolios and print
- **Uses intelligent layout**: 2x2 grid on the left for orthographic views, hero image on the right
- **Maintains high quality** with linked smart objects that update when source files change

### ✨ Key Features

#### 🔗 Smart Object Linking

- All images are placed as **linked smart objects**
- Edit source PNG files and the model sheet updates automatically
- Maintains full resolution and quality of original files
- Non-destructive workflow preserves original assets

#### 📐 Square Aspect Ratio Design

- **2048x2048 pixel** format ideal for social media and portfolios
- **1:1 aspect ratio** ensures consistent presentation across platforms
- Optimized for both digital display and print applications
- Professional layout that works for character design portfolios

#### 🧠 Intelligent File Detection

- Automatically finds PNG files containing keywords in filename
- Supports flexible naming: `character_front.png`, `eric_hero_pose.png`, etc.
- Falls back to folder name for hero image if no "hero" keyword found
- Smart positioning based on orthographic view conventions

#### 📋 Dual Output Format

- Saves both **PSD file** for future editing
- Exports **high-quality JPG** for immediate sharing
- Maintains version numbering system for iterative work
- Organized file naming based on source folder

### 🚀 Photoshop Script Installation

#### Prerequisites

- Adobe Photoshop CC or later
- PNG reference images with appropriate keywords in filenames

#### Setup Instructions

1. **Copy the Script**

   - Copy `photoshop/scripts/br_create_model_sheet.jsx` to your Photoshop Scripts folder
   - Default location: `C:\Program Files\Adobe\Adobe Photoshop [Version]\Presets\Scripts\`

2. **Run the Script**
   - In Photoshop: `File > Scripts > br_create_model_sheet`
   - Or use `File > Scripts > Browse...` to run directly

### 🎯 Usage Guide

#### File Naming Convention

Ensure your PNG files contain these keywords for automatic detection:

- **`front`** - Front orthographic view
- **`back`** - Back orthographic view
- **`left`** - Left side view
- **`right`** - Right side view
- **`hero`** - Main character pose/image

Examples:

- `character_front_view.png`
- `eric_hero_pose.png`
- `design_left_side.png`
- `concept_back.png`

#### Step-by-Step Usage

1. **Organize Your Files**

   - Place all character PNG files in a single folder
   - Use keyword naming convention for automatic detection
   - Optional: Name one file with folder name for hero image fallback

2. **Run the Script**

   - Execute the script in Photoshop
   - Select your folder containing the PNG files
   - The script will automatically create the model sheet

3. **Review the Output**

   - **Left side**: 2x2 grid with orthographic views (front, right, left, back)
   - **Right side**: Hero image at full height
   - **Smart objects**: All images linked to source files

4. **Edit and Iterate**
   - Edit source PNG files to update the model sheet
   - Use layer groups for organization
   - Export variations as needed

#### Layout Specifications

- **Document Size**: 2048x2048 pixels (square format)
- **Grid Layout**: 2x2 orthographic views (1024x1024 each quadrant)
- **Hero Section**: Full height (2048px) on right side
- **Image Sizing**: Maintains aspect ratios with smart fitting
- **Layer Organization**: Grouped and timestamped for easy management

### 🎨 Artist Workflow Benefits

#### Character Design Portfolio

- **Consistent presentation** across all character sheets
- **Square format** perfect for Instagram, ArtStation, and portfolio sites
- **Professional layout** that clearly shows all reference angles
- **Easy updating** when design iterations are needed

#### Animation Reference

- **Frame-ready format** for animation teams
- **Clear orthographic views** for 3D modeling reference
- **High resolution** maintains detail for close inspection
- **Linked workflow** allows quick design iteration

#### Game Development Assets

- **Standard format** for character documentation
- **Version control friendly** with linked smart objects
- **Multiple export formats** for different team needs
- **Scalable workflow** for large character rosters

---

## 🔧 Customization

### MPV Customization

#### Adding File Extensions

Edit the `media_extensions` table in the script to support additional formats:

```lua
local media_extensions = {
    image = {".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp", ".tiff", ".tga", ".psd"},
    video = {".mp4", ".avi", ".mkv", ".mov", ".wmv", ".flv", ".webm", ".m4v"},
    audio = {".mp3", ".wav", ".flac", ".ogg", ".aac", ".m4a", ".wma"}
}
```

#### Modifying Hotkeys

The script uses standard MPV key binding syntax. Modify the bindings at the bottom of the script file.

### Photoshop Script Customization

#### Document Size

Modify the document dimensions in the script:

```javascript
var doc = app.documents.add(2048, 2048, 72, docName);
```

#### Keywords and Layout

Edit the keywords array and positioning logic to customize layout:

```javascript
var keywords = ["front", "back", "left", "right", "hero"];
```

## 🐛 Troubleshooting

### MPV Issues

**Mouse wheel not working correctly:**

- Ensure you're using the latest MPV version
- Check Windows mouse settings for custom scroll behaviors

**File operations failing:**

- Run MPV as administrator if working with protected directories
- Verify PowerShell execution policy allows script execution

### Photoshop Script Issues

**Script won't run:**

- Check Photoshop script execution permissions
- Ensure PNG files exist in selected folder
- Verify file naming includes required keywords

**Smart objects not linking:**

- Ensure source PNG files remain in original location
- Check file permissions on source folder
- Verify Photoshop has access to source directory

## 🤝 Contributing

This project is designed for the creative community. Contributions welcome!

1. Fork the repository
2. Create a feature branch
3. Submit a pull request with detailed description

### Ideas for Future Features

#### MPV Enhancements

- Custom thumbnail generation
- Batch file operations
- Integration with creative software
- Timeline markers for video reference
- Custom metadata tagging

#### Photoshop Script Enhancements

- Multiple layout templates
- Custom aspect ratio options
- Batch processing multiple character folders
- Integration with asset management systems
- Custom watermarking and branding

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **MPV**: Built on the excellent [MPV media player](https://mpv.io/)
- **Adobe**: Photoshop scripting capabilities enable powerful automation
- **Creative Community**: Designed for and inspired by artist workflow needs

---

**Made with ❤️ for artists, animators, and creative professionals**

_Transform your creative workflows with tools built for professional artists._
