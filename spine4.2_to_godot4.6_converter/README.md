# Spine 4.2 to Godot 4.6 Converter

[![Godot](https://img.shields.io/badge/Godot-4.4+-478cbf?style=flat-square&logo=godot-engine)](https://godotengine.org)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](LICENSE)
[![Spine](https://img.shields.io/badge/Spine-4.2+-green.svg?style=flat-square)](https://esotericsoftware.com/spine)

A powerful and precise converter for transforming Spine 4.2 skeletal animations into Godot 4.6 scenes with full animation support.

## Features

- ✨ **Precise Bone Hierarchy** - Maintains exact parent-child relationships from Spine
- 🎨 **Complete Animation Support** - Position, rotation, and scale animations
- 🎬 **Slot/Attachment System** - Full support for attachment management
- 🎯 **Transform2D Matrix** - Accurate transformation matrix calculations
- 🔧 **Automatic Image Detection** - Smart image path resolution
- ⚡ **Y-Axis Flipping** - Correct handling of coordinate system differences
- 📊 **Animation Duration Calculation** - Automatic animation length computation
- 🔄 **Complete Conversion** - Convert bones and all animations at once
- 🎯 **Single Animation Conversion** - Convert individual animations as needed

## Installation

1. Copy `spine4.2_to_godot4.6_converter` folder to your project's `addons/` directory
2. Enable addon in Godot: `Project -> Project Settings -> Plugins`
3. Restart Godot if needed

## Quick Start

### Method 1: Godot Editor (Recommended)

1. Open your Godot project
2. Go to `Project -> Tools -> Run Script`
3. Select `addons/spine4.2_to_godot4.6_converter/v4.2_convert_tool_godot.gd`
4. Edit script to configure paths:

```gdscript
# Input Spine JSON file path
var spine_json_path: String = "res://assets/character/character.json"

# Output Godot scene file path
var output_scene_path: String = "res://assets/character/character_godot.tscn"

# Image directory (optional, defaults to config setting)
var images_directory: String = ""
```

5. Run the script again

### Method 2: Command Line (Headless Mode)

For automated builds or CI/CD:

```bash
godot --headless --script "addons/spine4.2_to_godot4.6_converter/v4.2_batch_convert_headless.gd"
```

Edit `v4.2_batch_convert_headless.gd` to configure paths before running.

## Usage

### Basic Example

```gdscript
extends Node2D

@onready var animation_player = $AnimationPlayer

func _ready():
    # Play animation
    animation_player.play("idle")
```

### Complete Conversion

Convert bones and all animations at once:

```gdscript
@tool
extends EditorScript

func _run():
    var converter = load("res://addons/spine4.2_to_godot4.6_converter/spine_converter.gd").new()
    
    var input_file = "res://assets/character/character.json"
    var output_file = "res://assets/character/character_godot.tscn"
    
    if converter.convert_spine_complete(input_file, output_file):
        print("✅ Complete conversion successful!")
    else:
        print("❌ Conversion failed!")
```

### Single Animation Conversion

Convert individual animations:

```gdscript
@tool
extends EditorScript

func _run():
    var converter = load("res://addons/spine4.2_to_godot4.6_converter/spine_converter.gd").new()
    
    var input_file = "res://assets/character/character.json"
    var output_file = "res://assets/character/character_godot.tscn"
    var animation_name = "walk"
    
    if converter.convert_spine_animation_to_godot(input_file, output_file, animation_name):
        print("✅ Animation conversion successful!")
    else:
        print("❌ Animation conversion failed!")
```

## Project Structure

```
addons/spine4.2_to_godot4.6_converter/
├── v4.2_convert_tool_godot.gd          # Godot editor script (GUI mode)
├── v4.2_batch_convert_headless.gd       # Command-line script (headless mode)
├── spine_converter.gd                   # Core converter engine
├── plugin.cfg                           # Plugin configuration
├── README.md                           # This file
└── QUICKSTART.md                       # Quick start guide
```

## Script Types

### v4.2_convert_tool_godot.gd
**Purpose**: Run conversion in Godot Editor with GUI feedback

**When to use**:
- Interactive development workflow
- Need visual feedback during conversion
- Working within Godot Editor

**How to run**:
1. Open Godot Editor
2. Go to `Project -> Tools -> Run Script`
3. Select `v4.2_convert_tool_godot.gd`

### v4.2_batch_convert_headless.gd
**Purpose**: Run conversion in headless mode without GUI

**When to use**:
- Automated build pipelines
- CI/CD integration
- Batch processing multiple files
- Server environments

**How to run**:
```bash
godot --headless --script "path/to/v4.2_batch_convert_headless.gd"
```

## Configuration

### Image Path Resolution

The converter uses configuration settings for image paths:

```gdscript
var config: Dictionary = {
    "image_path": "res://assets/character/images/",
    "output_path": "res://assets/character/",
    "scale_factor": 1.0,
    "flip_y": true
}
```

### Advanced Options

Modify `spine_converter.gd` for advanced configuration:

```gdscript
var config: Dictionary = {
    "image_path": "",           # Image directory
    "output_path": "",          # Output directory
    "scale_factor": 1.0,        # Scale multiplier
    "flip_y": true            # Flip Y-axis (Spine up, Godot down)
}
```

## Output Structure

The generated Godot scene follows this structure:

```
character_godot.tscn (CharacterBody2D)
└── 视觉容器 (Node2D)
    ├── Skeleton2D (Skeleton2D)
    │   ├── root (Bone2D)
    │   │   ├── body (Bone2D)
    │   │   │   ├── body (Slot2D)
    │   │   │   │   └── body (Sprite2D)
    │   │   │   └── ...
    │   │   └── ...
    │   └── ...
    └── AnimationPlayer (AnimationPlayer)
```

## Technical Details

### Coordinate System Conversion

- **Y-Axis**: Spine (up) → Godot (down) - automatically inverted
- **Rotation**: Spine (degrees) → Godot (radians) - automatically converted
- **Position**: Y coordinates are negated
- **Transform2D Matrix**: Correct matrix calculations for accurate transformations

### Animation Tracks

- **Position**: `NodePath("bone_name:position")`
- **Rotation**: `NodePath("bone_name:rotation")`
- **Scale**: `NodePath("bone_name:scale")`
- **Transform2D**: `Transform2D` matrix for rest pose

### Conversion Modes

1. **Complete Conversion**: Convert bones and all animations at once
2. **Single Animation Conversion**: Convert individual animations to existing scenes
3. **Bones Only**: Convert only the skeletal structure

## Requirements

- **Godot Engine**: 4.4 or higher
- **Spine**: 4.2.x
- **Python**: 3.x (optional, for headless mode)

## Troubleshooting

### Conversion Fails
**Error**: `Cannot open JSON file`
**Solution**: Ensure `spine_json_path` is an absolute path

### Animation Not Playing
**Solution**:
1. Check if AnimationPlayer node exists in scene
2. Verify animation name (case-sensitive)
3. Check animation loop settings

### Textures Not Displaying
**Solution**:
1. Ensure image resources are imported
2. Verify image path is correct
3. Check ExtResource references

### Transform Issues
**Solution**: 
- Check `flip_y` configuration
- Verify Transform2D matrix calculations
- Ensure coordinate system conversion is correct

## Examples

See `examples/` directory for sample projects:
- `basic_character/` - Simple character with idle and walk animations
- `complex_character/` - Character with multiple animations
- `batch_conversion/` - Script for converting multiple characters

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under MIT License - see [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Spine](https://esotericsoftware.com/spine) - Skeletal animation software
- [Godot Engine](https://godotengine.org) - Open-source game engine

## Changelog

### Version 1.0.0 (2026-03-08)
- Initial release
- Precise bone hierarchy conversion
- Complete animation support
- Transform2D matrix calculations
- Y-axis flipping support
- Automatic image detection
- Animation duration calculation
- Complete and single animation conversion
- Godot editor and headless mode support

## Support

- 📖 [Documentation](QUICKSTART.md)
- 🐛 [Issue Tracker](https://github.com/yourusername/spine42-to-godot46-converter/issues)
- 💬 [Discussions](https://github.com/yourusername/spine42-to-godot46-converter/discussions)

## Links

- [Spine Documentation](https://esotericsoftware.com/spine-documentation)
- [Godot Documentation](https://docs.godotengine.org)
- [Godot Asset Library](https://godotengine.org/asset-library)

---

Made with ❤️ for Godot community
