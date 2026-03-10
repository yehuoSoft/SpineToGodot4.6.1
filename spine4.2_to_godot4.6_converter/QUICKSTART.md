# Quick Start Guide

Get started with Spine 4.2 to Godot 4.6 Converter in 3 simple steps.

## Prerequisites

- [x] Godot Engine 4.4 or higher installed
- [x] Spine 4.2.x JSON export file
- [x] Spine image assets (PNG files)

## Step 1: Prepare Your Spine Files

Ensure you have:
- Spine JSON file: `character.json`
- Image folder: `images/` containing all PNG files

Example structure:
```
your_project/
└── assets/
    └── character/
        ├── character.json
        └── images/
            ├── body.png
            ├── arm.png
            └── ...
```

## Step 2: Configure Converter

### For Godot Editor Mode

Edit `v4.2_convert_tool_godot.gd`:

```gdscript
# Input Spine JSON file path
var spine_json_path: String = "res://assets/character/character.json"

# Output Godot scene file path
var output_scene_path: String = "res://assets/character/character_godot.tscn"

# Image directory (optional, defaults to config setting)
var images_directory: String = ""
```

**Tip**: Configure image path in `spine_converter.gd` config if needed.

### For Headless Mode

Edit `v4.2_batch_convert_headless.gd`:

```gdscript
var input_file = "res://assets/character/character.json"
var output_file = "res://assets/character/character_godot.tscn"
```

## Step 3: Run Converter

### Option A: Godot Editor (Recommended)

1. Open your Godot project
2. Go to `Project -> Tools -> Run Script`
3. Select `v4.2_convert_tool_godot.gd`
4. Wait for conversion to complete

### Option B: Command Line (Headless)

```bash
godot --headless --script "addons/spine4.2_to_godot4.6_converter/v4.2_batch_convert_headless.gd"
```

## Expected Output

```
========================================
开始完整Spine到Godot转换
========================================
输入文件: res://assets/character/character.json
输出文件: res://assets/character/character_godot.tscn
========================================

步骤1: 转换骨骼结构...
✅ 成功加载Spine JSON文件
骨骼数量: 28
插槽数量: 25
Attachment数量: 45
✅ 骨骼转换完成！

步骤2: 转换动画 (13 个)...
动画列表: ["idle", "walk", "attack", ...]

转换动画: idle
✅ idle 转换成功

转换动画: walk
✅ walk 转换成功

...

========================================
✅ 完整转换完成！
输出文件: res://assets/character/character_godot.tscn
========================================
```

## Using Converted Scene

### 1. Import Scene

In Godot Editor:
1. Open File System panel
2. Locate generated `.tscn` file
3. Double-click to open or drag into your scene

### 2. Play Animations

```gdscript
extends Node2D

@onready var animation_player = $AnimationPlayer

func _ready():
    # Play idle animation
    animation_player.play("idle")
    
    # Play other animations
    # animation_player.play("walk")
    # animation_player.play("attack")
```

### 3. Animation Events

Handle animation completion:

```gdscript
extends Node2D

@onready var animation_player = $AnimationPlayer

func _ready():
    animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: String):
    print("Animation finished: " + anim_name)
```

## Understanding Output Structure

The generated scene follows this hierarchy:

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

## Common Use Cases

### Playing Different Animations

```gdscript
# Switch between animations based on input
func _process(delta):
    if Input.is_action_pressed("ui_right"):
        animation_player.play("walk")
    elif Input.is_action_pressed("ui_accept"):
        animation_player.play("attack")
    else:
        animation_player.play("idle")
```

### Animation Blending

```gdscript
# Smooth transition between animations
func change_animation(new_anim: String):
    if animation_player.current_animation != new_anim:
        animation_player.play(new_anim)
```

### Loop Control

```gdscript
# Set animation to loop
animation_player.play("idle", -1, 1.0)

# Play once
animation_player.play("attack", 1, 1.0)
```

## Conversion Modes

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

Convert individual animations to existing scenes:

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

## Troubleshooting

### Issue: Conversion Fails

**Error**: `无法打开Spine JSON文件`

**Solution**: 
- Ensure path is absolute or uses `res://` prefix
- Check file exists in specified location
- Verify file permissions

### Issue: Animations Don't Play

**Solution**:
1. Check if AnimationPlayer node exists in scene
2. Verify animation name matches exactly (case-sensitive)
3. Ensure animation is not disabled in AnimationPlayer
4. Check animation loop settings

### Issue: Textures Not Displaying

**Solution**:
1. Verify image files exist in images folder
2. Check image resources are imported in Godot
3. Verify image path in generated scene file
4. Ensure ExtResource references are valid

### Issue: Transform Issues

**Solution**:
- Check `flip_y` configuration in `spine_converter.gd`
- Verify Transform2D matrix calculations
- Ensure coordinate system conversion is correct

## Advanced Configuration

### Custom Image Path

If your images are in a different location, edit `spine_converter.gd`:

```gdscript
var config: Dictionary = {
    "image_path": "res://assets/character/custom_images/",
    "output_path": "res://assets/character/",
    "scale_factor": 1.0,
    "flip_y": true
}
```

### Scale Factor

Adjust the scale of converted animations:

```gdscript
var config: Dictionary = {
    "image_path": "res://assets/character/images/",
    "output_path": "res://assets/character/",
    "scale_factor": 2.0,  # Double the scale
    "flip_y": true
}
```

## Next Steps

- 📖 Read [full documentation](README.md)
- 🎮 Check out [example projects](../examples/)
- 🐛 Report issues on [GitHub](https://github.com/yourusername/spine42-to-godot46-converter/issues)
- 💬 Join [community discussions](https://github.com/yourusername/spine42-to-godot46-converter/discussions)

## Additional Resources

- [Spine Documentation](https://esotericsoftware.com/spine-documentation)
- [Godot Animation Documentation](https://docs.godotengine.org/en/stable/tutorials/animation/introduction.html)
- [Godot 2D Skeletal Animation](https://docs.godotengine.org/en/stable/tutorials/animation/2d_skeleton/2d_skeletons.html)

## Script Types Reference

### v4.2_convert_tool_godot.gd
**Best for**: Interactive development in Godot Editor

**Advantages**:
- Visual feedback during conversion
- Easy to configure through Godot interface
- No command line needed

**When to use**:
- Converting single files
- Testing and debugging
- Learning the converter

### v4.2_batch_convert_headless.gd
**Best for**: Automated workflows and batch processing

**Advantages**:
- No GUI overhead
- Faster execution
- Suitable for CI/CD pipelines

**When to use**:
- Converting multiple files
- Automated build systems
- Server environments
- Batch processing

## Getting Help

If you encounter any issues:

1. Check [troubleshooting section](#troubleshooting)
2. Search [existing issues](https://github.com/yourusername/spine42-to-godot46-converter/issues)
3. Create a [new issue](https://github.com/yourusername/spine42-to-godot46-converter/issues/new) with:
   - Godot version
   - Spine version
   - Error message
   - Steps to reproduce

---

Happy converting! 🚀
