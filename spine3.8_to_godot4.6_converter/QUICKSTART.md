# Quick Start Guide

Get started with Spine 3.8 to Godot 4.6 Converter in 3 simple steps.

## Prerequisites

- [x] Godot Engine 4.4 or higher installed
- [x] Spine 3.8.x JSON export file
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

## Step 2: Configure the Converter

### For Godot Editor Mode

Edit `v3.8_convert_tool_godot.gd`:

```gdscript
# Input Spine JSON file path
var spine_json_path: String = "res://assets/character/character.json"

# Output Godot scene file path
var output_scene_path: String = "res://assets/character/character_godot.tscn"

# Image directory (optional, defaults to JSON file's images folder)
var images_directory: String = ""
```

**Tip**: Leave `images_directory` empty for automatic detection.

### For Headless Mode

Edit `v3.8_convert_tool_headless.gd`:

```gdscript
var input_file = "res://assets/character/character.json"
var output_file = "res://assets/character/character_godot.tscn"
```

## Step 3: Run the Converter

### Option A: Godot Editor (Recommended)

1. Open your Godot project
2. Go to `Project -> Tools -> Run Script`
3. Select `v3.8_convert_tool_godot.gd`
4. Wait for conversion to complete

### Option B: Command Line (Headless)

```bash
godot --headless --script "addons/spine3.8_to_godot4.6_converter/v3.8_convert_tool_headless.gd"
```

## Expected Output

```
========================================
开始Spine 3.8到Godot 4.6转换
========================================
输入文件: res://assets/character/character.json
输出文件: res://assets/character/character_godot.tscn
========================================

=== Spine 3.8精确层级转换器 ===
====================================
✅ 成功加载Spine JSON文件
骨骼数量: 28
插槽数量: 25
动画数量: 13
🔍 构建的骨骼层级数量: 28
🔍 自动检测图片目录: res://assets/character/images/

✅ 成功创建Godot骨骼场景: res://assets/character/character_godot.tscn

📊 转换统计:
   - 骨骼数量: 28
   - 插槽数量: 25
   - 动画数量: 13

🎯 功能特性:
   ✅ 精确构建骨骼层级关系
   ✅ 每个插槽包含所有附件贴图
   ✅ 动画转换功能（位置、旋转、缩放）
   ✅ 事件系统支持
   ✅ 插槽/附件动画切换
   ✅ 同名贴图初始隐藏
   ✅ 动画时长自动计算
   ✅ 可见性属性无插值
```

## Using the Converted Scene

### 1. Import Scene

In Godot Editor:
1. Open File System panel
2. Locate the generated `.tscn` file
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

### 3. Handle Events (Optional)

If your Spine animations include events:

```gdscript
extends Node2D

@onready var animation_player = $AnimationPlayer

func _ready():
    animation_player.animation_finished.connect(_on_animation_finished)
    animation_player.animation_started.connect(_on_animation_started)

func _on_animation_finished(anim_name: String):
    print("Animation finished: " + anim_name)

func _on_animation_started(anim_name: String):
    print("Animation started: " + anim_name)
```

## Understanding the Output Structure

The generated scene follows this hierarchy:

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

## Troubleshooting

### Issue: Conversion Fails

**Error**: `Cannot open JSON file`

**Solution**: 
- Ensure path is absolute or uses `res://` prefix
- Check file exists in the specified location
- Verify file permissions

### Issue: Animations Don't Play

**Solution**:
1. Check AnimationPlayer node exists in scene
2. Verify animation name matches exactly (case-sensitive)
3. Ensure animation is not disabled in AnimationPlayer
4. Check animation loop settings

### Issue: Textures Not Displaying

**Solution**:
1. Verify image files exist in the images folder
2. Check image resources are imported in Godot
3. Verify image path in generated scene file
4. Ensure ExtResource references are valid

### Issue: Incorrect Animation Timing

**Solution**:
- Visibility tracks use `interp = 0` for instant switching
- Check original Spine animation data
- Verify animation duration calculation

## Advanced Configuration

### Custom Image Path

If your images are in a different location:

```gdscript
# In v3.8_convert_tool_godot.gd
var images_directory: String = "res://assets/character/custom_images/"
```

### Batch Conversion

Convert multiple characters at once:

```gdscript
@tool
extends EditorScript

var characters = [
    {"input": "res://assets/char1/char1.json", "output": "res://assets/char1/char1_godot.tscn"},
    {"input": "res://assets/char2/char2.json", "output": "res://assets/char2/char2_godot.tscn"},
    {"input": "res://assets/char3/char3.json", "output": "res://assets/char3/char3_godot.tscn"},
]

func _run():
    var converter = load("res://addons/spine3.8_to_godot4.6_converter/spine38_converter_precise.gd").new()
    
    for char in characters:
        print("Converting: " + char["input"])
        if converter.convert_spine38_to_godot(char["input"], char["output"]):
            print("✅ Success")
        else:
            print("❌ Failed")
```

## Next Steps

- 📖 Read the [full documentation](README.md)
- 🎮 Check out [example projects](../examples/)
- 🐛 Report issues on [GitHub](https://github.com/yourusername/spine38-to-godot46-converter/issues)
- 💬 Join the [community discussions](https://github.com/yourusername/spine38-to-godot46-converter/discussions)

## Additional Resources

- [Spine Documentation](https://esotericsoftware.com/spine-documentation)
- [Godot Animation Documentation](https://docs.godotengine.org/en/stable/tutorials/animation/introduction.html)
- [Godot 2D Skeletal Animation](https://docs.godotengine.org/en/stable/tutorials/animation/2d_skeleton/2d_skeletons.html)

## Script Types Reference

### v3.8_convert_tool_godot.gd
**Best for**: Interactive development in Godot Editor

**Advantages**:
- Visual feedback during conversion
- Easy to configure through Godot interface
- No command line needed

**When to use**:
- Converting single files
- Testing and debugging
- Learning the converter

### v3.8_convert_tool_headless.gd
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

1. Check the [troubleshooting section](#troubleshooting)
2. Search [existing issues](https://github.com/yourusername/spine38-to-godot46-converter/issues)
3. Create a [new issue](https://github.com/yourusername/spine38-to-godot46-converter/issues/new) with:
   - Godot version
   - Spine version
   - Error message
   - Steps to reproduce

---

Happy converting! 🚀
