# Spine 4.2 转 Godot 4.6 转换工具

[![Godot](https://img.shields.io/badge/Godot-4.4+-478cbf?style=flat-square&logo=godot-engine)](https://godotengine.org)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](LICENSE)
[![Spine](https://img.shields.io/badge/Spine-4.2+-green.svg?style=flat-square)](https://esotericsoftware.com/spine)

一个强大而精确的转换器，用于将 Spine 4.2 骨骼动画转换为 Godot 4.6 场景，支持完整的动画功能。

## 功能特性

- ✨ **精确的骨骼层级** - 完整保留 Spine 的父子关系
- 🎨 **完整的动画支持** - 位置、旋转和缩放动画
- 🎬 **插槽/附件系统** - 完整支持附件管理
- 🎯 **Transform2D 矩阵** - 准确的变换矩阵计算
- 🔧 **自动图片检测** - 智能图片路径解析
- ⚡ **Y 轴翻转** - 正确处理坐标系差异
- 📊 **动画时长计算** - 自动动画长度计算
- 🔄 **完整转换** - 一次性转换骨骼和所有动画
- 🎯 **单动画转换** - 根据需要转换单个动画

## 安装

1. 将 `spine4.2_to_godot4.6_converter` 文件夹复制到项目的 `addons/` 目录
2. 在 Godot 中启用插件：`项目 -> 项目设置 -> 插件`
3. 如有需要，重启 Godot

## 快速开始

### 方法一：Godot 编辑器（推荐）

1. 打开你的 Godot 项目
2. 进入 `项目 -> 工具 -> 运行脚本`
3. 选择 `addons/spine4.2_to_godot4.6_converter/v4.2_convert_tool_godot.gd`
4. 编辑脚本以配置路径：

```gdscript
# 输入 Spine JSON 文件路径
var spine_json_path: String = "res://assets/character/character.json"

# 输出 Godot 场景文件路径
var output_scene_path: String = "res://assets/character/character_godot.tscn"

# 图片目录（可选，默认使用配置设置）
var images_directory: String = ""
```

5. 再次运行脚本

### 方法二：命令行（无头模式）

用于自动化构建或 CI/CD：

```bash
godot --headless --script "addons/spine4.2_to_godot4.6_converter/v4.2_batch_convert_headless.gd"
```

在运行前编辑 `v4.2_batch_convert_headless.gd` 以配置路径。

## 使用方法

### 基本示例

```gdscript
extends Node2D

@onready var animation_player = $AnimationPlayer

func _ready():
    # 播放动画
    animation_player.play("idle")
```

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

转换单个动画：

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

## 项目结构

```
addons/spine4.2_to_godot4.6_converter/
├── v4.2_convert_tool_godot.gd          # Godot 编辑器脚本（GUI 模式）
├── v4.2_batch_convert_headless.gd       # 命令行脚本（无头模式）
├── spine_converter.gd                   # 核心转换器引擎
├── plugin.cfg                           # 插件配置
├── README.md                           # 英文文档
└── QUICKSTART.md                       # 快速开始指南
```

## 脚本类型

### v4.2_convert_tool_godot.gd
**用途**：在 Godot 编辑器中运行转换，提供 GUI 反馈

**适用场景**：
- 交互式开发工作流
- 需要转换过程中的视觉反馈
- 在 Godot 编辑器内工作

**运行方式**：
1. 打开 Godot 编辑器
2. 进入 `项目 -> 工具 -> 运行脚本`
3. 选择 `v4.2_convert_tool_godot.gd`

### v4.2_batch_convert_headless.gd
**用途**：在无头模式下运行转换，无需 GUI

**适用场景**：
- 自动化构建管道
- CI/CD 集成
- 批量处理多个文件
- 服务器环境

**运行方式**：
```bash
godot --headless --script "path/to/v4.2_batch_convert_headless.gd"
```

## 配置

### 图片路径解析

转换器使用配置设置来处理图片路径：

```gdscript
var config: Dictionary = {
    "image_path": "res://assets/character/images/",
    "output_path": "res://assets/character/",
    "scale_factor": 1.0,
    "flip_y": true
}
```

### 高级选项

修改 `spine_converter.gd` 进行高级配置：

```gdscript
var config: Dictionary = {
    "image_path": "",           # 图片目录
    "output_path": "",          # 输出目录
    "scale_factor": 1.0,        # 缩放因子
    "flip_y": true            # 翻转 Y 轴（Spine 向上，Godot 向下）
}
```

## 输出结构

生成的 Godot 场景遵循以下结构：

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

## 技术细节

### 坐标系转换

- **Y 轴**：Spine（向上）→ Godot（向下）- 自动反转
- **旋转**：Spine（角度）→ Godot（弧度）- 自动转换
- **位置**：Y 坐标取负值
- **Transform2D 矩阵**：正确计算变换矩阵以实现精确变换

### 动画轨道

- **位置**：`NodePath("bone_name:position")`
- **旋转**：`NodePath("bone_name:rotation")`
- **缩放**：`NodePath("bone_name:scale")`
- **Transform2D**：`Transform2D` 矩阵用于休息姿态

### 转换模式

1. **完整转换**：一次性转换骨骼和所有动画
2. **单动画转换**：将单个动画转换到现有场景
3. **仅骨骼**：仅转换骨骼结构

## 系统要求

- **Godot 引擎**：4.4 或更高版本
- **Spine**：4.2.x
- **Python**：3.x（可选，用于无头模式）

## 故障排除

### 转换失败
**错误**：`无法打开 JSON 文件`
**解决方案**：确保 `spine_json_path` 是绝对路径

### 动画不播放
**解决方案**：
1. 检查场景中是否存在 AnimationPlayer 节点
2. 验证动画名称（区分大小写）
3. 检查动画循环设置

### 纹理不显示
**解决方案**：
1. 确保图片资源已导入
2. 验证图片路径是否正确
3. 检查 ExtResource 引用

### 变换问题
**解决方案**：
- 检查 `flip_y` 配置
- 验证 Transform2D 矩阵计算
- 确保坐标系转换正确

## 示例

查看 `examples/` 目录获取示例项目：
- `basic_character/` - 带有待机和行走动画的简单角色
- `complex_character/` - 带有多个动画的角色
- `batch_conversion/` - 用于转换多个角色的脚本

## 贡献

欢迎贡献！请遵循以下指南：

1. Fork 仓库
2. 创建功能分支
3. 进行更改
4. 如适用，添加测试
5. 提交 Pull Request

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。

## 致谢

- [Spine](https://esotericsoftware.com/spine) - 骨骼动画软件
- [Godot Engine](https://godotengine.org) - 开源游戏引擎

## 更新日志

### 版本 1.0.0 (2026-03-08)
- 初始发布
- 精确的骨骼层级转换
- 完整的动画支持
- Transform2D 矩阵计算
- Y 轴翻转支持
- 自动图片检测
- 动画时长计算
- 完整和单动画转换
- Godot 编辑器和无头模式支持

## 支持

- 📖 [文档](QUICKSTART.md)
- 🐛 [问题追踪](https://github.com/yourusername/spine42-to-godot46-converter/issues)
- 💬 [讨论区](https://github.com/yourusername/spine42-to-godot46-converter/discussions)

## 相关链接

- [Spine 文档](https://esotericsoftware.com/spine-documentation)
- [Godot 文档](https://docs.godotengine.org)
- [Godot 资源库](https://godotengine.org/asset-library)

---

为 Godot 社区用 ❤️ 制作
