# Spine 3.8 to Godot 4.6 Converter

[![Godot](https://img.shields.io/badge/Godot-4.4+-478cbf?style=flat-square&logo=godot-engine)](https://godotengine.org)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](LICENSE)
[![Spine](https://img.shields.io/badge/Spine-3.8+-green.svg?style=flat-square)](https://esotericsoftware.com/spine)

A powerful and precise converter for transforming Spine 3.8 skeletal animations into Godot 4.6 scenes with full animation support.

## Features

- ✨ **Precise Bone Hierarchy** - Maintains exact parent-child relationships from Spine
- 🎨 **Complete Animation Support** - Position, rotation, and scale animations
- 🎬 **Slot/Attachment Switching** - Full support for sequence frame animations
- 🎯 **Event System** - Spine events converted to Godot method calls
- 🔧 **Automatic Image Detection** - Smart image path resolution
- ⚡ **Zero-Interpolation Visibility** - Accurate timing for visibility changes
- 📊 **Automatic Duration Calculation** - Includes slots and events in animation length

## Installation

1. Copy the `spine3.8_to_godot4.6_converter` folder to your project's `addons/` directory
2. Enable the addon in Godot: `Project -> Project Settings -> Plugins`
3. Restart Godot if needed

## Quick Start

### Method 1: Godot Editor (Recommended)

1. Open your Godot project
2. Go to `Project -> Tools -> Run Script`
3. Select `addons/spine3.8_to_godot4.6_converter/v3.8_convert_tool_godot.gd`
4. Edit the script to configure paths:

```gdscript
# Input Spine JSON file path
var spine_json_path: String = "res://assets/character/character.json"

# Output Godot scene file path
var output_scene_path: String = "res://assets/character/character_godot.tscn"

# Image directory (optional, defaults to JSON file's images folder)
var images_directory: String = ""
```

5. Run the script again

### Method 2: Command Line (Headless Mode)

For automated builds or CI/CD:

```bash
godot --headless --script "addons/spine3.8_to_godot4.6_converter/v3.8_convert_tool_headless.gd"
```

Edit `v3.8_convert_tool_headless.gd` to configure paths before running.

## Usage

### Basic Example

```gdscript
extends Node2D

@onready var animation_player = $AnimationPlayer

func _ready():
    # Play animation
    animation_player.play("idle")
```

### Handling Events

If your Spine animations include events, add an event handler:

```gdscript
extends Node2D

@onready var animation_player = $AnimationPlayer

func _ready():
    animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: String):
    print("Animation finished: " + anim_name)
```

## Project Structure

```
addons/spine3.8_to_godot4.6_converter/
├── v3.8_convert_tool_godot.gd          # Godot editor script (GUI mode)
├── v3.8_convert_tool_headless.gd       # Command-line script (headless mode)
├── spine38_converter_precise.gd         # Core converter engine
├── spine_event_handler.gd               # Event handler
├── README.md                           # This file
└── QUICKSTART.md                       # Quick start guide
```

## Script Types

### v3.8_convert_tool_godot.gd
**Purpose**: Run conversion in Godot Editor with GUI feedback

**When to use**:
- Interactive development workflow
- Need visual feedback during conversion
- Working within Godot Editor

**How to run**:
1. Open Godot Editor
2. Go to `Project -> Tools -> Run Script`
3. Select `v3.8_convert_tool_godot.gd`

### v3.8_convert_tool_headless.gd
**Purpose**: Run conversion in headless mode without GUI

**When to use**:
- Automated build pipelines
- CI/CD integration
- Batch processing multiple files
- Server environments

**How to run**:
```bash
godot --headless --script "path/to/v3.8_convert_tool_headless.gd"
```

## Configuration

### Image Path Resolution

The converter automatically detects the image directory:

1. **If `images_directory` is specified**: Uses the provided path
2. **If `images_directory` is empty**: Automatically uses `{json_directory}/images/`

Example:
```gdscript
# Automatic detection (recommended)
var images_directory: String = ""

# Custom path
var images_directory: String = "res://assets/character/custom_images/"
```

### Advanced Options

Modify `spine38_converter_precise.gd` for advanced configuration:

```gdscript
var config: Dictionary = {
    "image_path": "",           # Image directory
    "output_path": "",          # Output directory
    "scale_factor": 1.0,        # Scale multiplier
    "flip_y": false            # Flip Y-axis
}
```

## Output Structure

The generated Godot scene follows this structure:

```
character_godot.tscn (Node2D)
└── VisualContainer (Node2D)
    ├── Skeleton2D (Skeleton2D)
    │   ├── root (Bone2D)
    │   │   ├── body (Bone2D)
    │   │   │   ├── body (Slot2D)
    │   │   │   │   └── body (Sprite2D)
    │   │   │   └── ...
    │   │   └── ...
    │   └── ...
    └── EventHandler (Node2D)  # Only if events exist
```

## Technical Details

### Coordinate System Conversion

- **Y-Axis**: Spine (up) → Godot (down) - automatically inverted
- **Rotation**: Spine (degrees) → Godot (radians) - automatically converted
- **Position**: Y coordinates are negated

### Animation Tracks

- **Position**: `NodePath("bone_name:position")`
- **Rotation**: `NodePath("bone_name:rotation")`
- **Scale**: `NodePath("bone_name:scale")`
- **Visibility**: `NodePath("slot_name:visible")`
- **Events**: `NodePath(".")` method calls

### Interpolation Settings

- **Position/Rotation/Scale**: `interp = 1` (linear interpolation)
- **Visibility**: `interp = 0` (no interpolation, instant switch)

## Requirements

- **Godot Engine**: 4.4 or higher
- **Spine**: 3.8.x
- **Python**: 3.x (optional, for headless mode)

## Troubleshooting

### Conversion Fails
**Error**: `Cannot open JSON file`
**Solution**: Ensure `spine_json_path` is an absolute path

### Animation Not Playing
**Solution**:
1. Check if AnimationPlayer node exists
2. Verify animation name (case-sensitive)
3. Check animation loop settings

### Textures Not Displaying
**Solution**:
1. Ensure image resources are imported
2. Verify image path is correct
3. Check ExtResource references

### Incorrect Animation Timing
**Solution**: Visibility tracks use `interp = 0` for instant switching. If timing is still off, check the original Spine animation data.

## Examples

See the `examples/` directory for sample projects:
- `basic_character/` - Simple character with idle and walk animations
- `complex_character/` - Character with events and slot switching
- `batch_conversion/` - Script for converting multiple characters

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Spine](https://esotericsoftware.com/spine) - Skeletal animation software
- [Godot Engine](https://godotengine.org) - Open-source game engine

## Changelog

### Version 1.0.0 (2026-03-08)
- Initial release
- Precise bone hierarchy conversion
- Complete animation support
- Event system integration
- Slot/attachment switching
- Automatic image detection
- Zero-interpolation visibility
- Automatic duration calculation
- Godot editor and headless mode support

## Support

- 📖 [Documentation](QUICKSTART.md)
- 🐛 [Issue Tracker](https://github.com/yourusername/spine38-to-godot46-converter/issues)
- 💬 [Discussions](https://github.com/yourusername/spine38-to-godot46-converter/discussions)

## Links

- [Spine Documentation](https://esotericsoftware.com/spine-documentation)
- [Godot Documentation](https://docs.godotengine.org)
- [Godot Asset Library](https://godotengine.org/asset-library)

---

Made with ❤️ for the Godot community
