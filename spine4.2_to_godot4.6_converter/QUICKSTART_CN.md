# 快速开始指南

通过 3 个简单步骤开始使用 Spine 4.2 转 Godot 4.6 转换器。

## 前置条件

- [x] 已安装 Godot 引擎 4.4 或更高版本
- [x] Spine 4.2.x JSON 导出文件
- [x] Spine 图片资源（PNG 文件）

## 第 1 步：准备 Spine 文件

确保你有：
- Spine JSON 文件：`character.json`
- 图片文件夹：`images/` 包含所有 PNG 文件

示例结构：
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

## 第 2 步：配置转换器

### 用于 Godot 编辑器模式

编辑 `v4.2_convert_tool_godot.gd`：

```gdscript
# 输入 Spine JSON 文件路径
var spine_json_path: String = "res://assets/character/character.json"

# 输出 Godot 场景文件路径
var output_scene_path: String = "res://assets/character/character_godot.tscn"

# 图片目录（可选，默认使用配置设置）
var images_directory: String = ""
```

**提示**：如需要，在 `spine_converter.gd` 中配置图片路径。

### 用于无头模式

编辑 `v4.2_batch_convert_headless.gd`：

```gdscript
var input_file = "res://assets/character/character.json"
var output_file = "res://assets/character/character_godot.tscn"
```

## 第 3 步：运行转换器

### 选项 A：Godot 编辑器（推荐）

1. 打开你的 Godot 项目
2. 进入 `项目 -> 工具 -> 运行脚本`
3. 选择 `v4.2_convert_tool_godot.gd`
4. 等待转换完成

### 选项 B：命令行（无头模式）

```bash
godot --headless --script "addons/spine4.2_to_godot4.6_converter/v4.2_batch_convert_headless.gd"
```

## 预期输出

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

## 使用转换后的场景

### 1. 导入场景

在 Godot 编辑器中：
1. 打开文件系统面板
2. 找到生成的 `.tscn` 文件
3. 双击打开或拖拽到场景中

### 2. 播放动画

```gdscript
extends Node2D

@onready var animation_player = $AnimationPlayer

func _ready():
    # 播放待机动画
    animation_player.play("idle")
    
    # 播放其他动画
    # animation_player.play("walk")
    # animation_player.play("attack")
```

### 3. 处理动画事件

处理动画完成：

```gdscript
extends Node2D

@onready var animation_player = $AnimationPlayer

func _ready():
    animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: String):
    print("动画完成: " + anim_name)
```

## 理解输出结构

生成的场景遵循以下层级结构：

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

## 常见用例

### 播放不同动画

```gdscript
# 根据输入切换动画
func _process(delta):
    if Input.is_action_pressed("ui_right"):
        animation_player.play("walk")
    elif Input.is_action_pressed("ui_accept"):
        animation_player.play("attack")
    else:
        animation_player.play("idle")
```

### 动画混合

```gdscript
# 动画之间的平滑过渡
func change_animation(new_anim: String):
    if animation_player.current_animation != new_anim:
        animation_player.play(new_anim)
```

### 循环控制

```gdscript
# 设置动画循环
animation_player.play("idle", -1, 1.0)

# 播放一次
animation_player.play("attack", 1, 1.0)
```

## 转换模式

### 完整转换

一次性转换骨骼和所有动画：

```gdscript
@tool
extends EditorScript

func _run():
    var converter = load("res://addons/spine4.2_to_godot4.6_converter/spine_converter.gd").new()
    
    var input_file = "res://assets/character/character.json"
    var output_file = "res://assets/character/character_godot.tscn"
    
    if converter.convert_spine_complete(input_file, output_file):
        print("✅ 完整转换成功！")
    else:
        print("❌ 转换失败！")
```

### 单动画转换

将单个动画转换到现有场景：

```gdscript
@tool
extends EditorScript

func _run():
    var converter = load("res://addons/spine4.2_to_godot4.6_converter/spine_converter.gd").new()
    
    var input_file = "res://assets/character/character.json"
    var output_file = "res://assets/character/character_godot.tscn"
    var animation_name = "walk"
    
    if converter.convert_spine_animation_to_godot(input_file, output_file, animation_name):
        print("✅ 动画转换成功！")
    else:
        print("❌ 动画转换失败！")
```

## 故障排除

### 问题：转换失败

**错误**：`无法打开Spine JSON文件`

**解决方案**：
- 确保路径是绝对路径或使用 `res://` 前缀
- 检查文件存在于指定位置
- 验证文件权限

### 问题：动画不播放

**解决方案**：
1. 检查场景中是否存在 AnimationPlayer 节点
2. 验证动画名称完全匹配（区分大小写）
3. 确保动画在 AnimationPlayer 中未被禁用
4. 检查动画循环设置

### 问题：纹理不显示

**解决方案**：
1. 验证图片文件存在于 images 文件夹中
2. 检查图片资源已在 Godot 中导入
3. 验证生成的场景文件中的图片路径
4. 确保 ExtResource 引用有效

### 问题：变换问题

**解决方案**：
- 检查 `spine_converter.gd` 中的 `flip_y` 配置
- 验证 Transform2D 矩阵计算
- 确保坐标系转换正确

## 高级配置

### 自定义图片路径

如果你的图片位于不同位置，编辑 `spine_converter.gd`：

```gdscript
var config: Dictionary = {
    "image_path": "res://assets/character/custom_images/",
    "output_path": "res://assets/character/",
    "scale_factor": 1.0,
    "flip_y": true
}
```

### 缩放因子

调整转换动画的缩放：

```gdscript
var config: Dictionary = {
    "image_path": "res://assets/character/images/",
    "output_path": "res://assets/character/",
    "scale_factor": 2.0,  # 双倍缩放
    "flip_y": true
}
```

## 下一步

- 📖 阅读[完整文档](README_CN.md)
- 🎮 查看[示例项目](../examples/)
- 🐛 在 [GitHub](https://github.com/yourusername/spine42-to-godot46-converter/issues)上报告问题
- 💬 加入[社区讨论](https://github.com/yourusername/spine42-to-godot46-converter/discussions)

## 其他资源

- [Spine 文档](https://esotericsoftware.com/spine-documentation)
- [Godot 动画文档](https://docs.godotengine.org/en/stable/tutorials/animation/introduction.html)
- [Godot 2D 骨骼动画](https://docs.godotengine.org/en/stable/tutorials/animation/2d_skeleton/2d_skeletons.html)

## 脚本类型参考

### v4.2_convert_tool_godot.gd
**最适合**：在 Godot 编辑器中进行交互式开发

**优势**：
- 转换过程中的视觉反馈
- 通过 Godot 界面轻松配置
- 无需命令行

**何时使用**：
- 转换单个文件
- 测试和调试
- 学习转换器

### v4.2_batch_convert_headless.gd
**最适合**：自动化工作流和批量处理

**优势**：
- 无 GUI 开销
- 执行速度更快
- 适合 CI/CD 管道

**何时使用**：
- 转换多个文件
- 自动化构建系统
- 服务器环境
- 批量处理

## 获取帮助

如果遇到任何问题：

1. 检查[故障排除部分](#故障排除)
2. 搜索[现有问题](https://github.com/yourusername/spine42-to-godot46-converter/issues)
3. 创建[新问题](https://github.com/yourusername/spine42-to-godot46-converter/issues/new)，包括：
   - Godot 版本
   - Spine 版本
   - 错误信息
   - 复现步骤

---

祝你转换愉快！🚀
