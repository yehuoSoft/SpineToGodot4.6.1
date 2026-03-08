@tool
extends EditorScript

# Spine 3.8到Godot 4.6转换工具
# 在Godot编辑器中通过"运行脚本"菜单执行

# 输入Spine JSON文件路径
var spine_json_path: String = "res://assets/DarkMonster/volcano_json/volcano.json"

# 输出Godot场景文件路径
var output_scene_path: String = "d:/A_Godot/A_SuperToy/assets/DarkMonster/volcano_spine38.tscn"

# 图片目录路径（可选，如果不指定则使用JSON文件所在目录的images文件夹）
var images_directory: String = ""

func _run():
	print("========================================")
	print("开始Spine 3.8到Godot 4.6转换")
	print("========================================")
	print("输入文件: " + spine_json_path)
	print("输出文件: " + output_scene_path)
	if images_directory != "":
		print("图片目录: " + images_directory)
	print("========================================\n")
	
	var converter = load("res://addons/spine3.8_to_godot4.6_converter/spine38_converter_precise.gd").new()
	
	if images_directory != "":
		converter.config["image_path"] = images_directory
	
	if converter.convert_spine38_to_godot(spine_json_path, output_scene_path):
		print("\n✅ 转换成功！")
		print("输出文件: " + output_scene_path)
		print("\n📊 转换统计:")
		print("   - 骨骼数量: " + str(converter.spine_data.get("bones", []).size()))
		print("   - 插槽数量: " + str(converter.spine_data.get("slots", []).size()))
		print("   - 动画数量: " + str(converter.get_animation_names().size()))
		print("\n🎯 功能特性:")
		print("   ✅ 精确构建骨骼层级关系")
		print("   ✅ 每个插槽包含所有附件贴图")
		print("   ✅ 动画转换功能（位置、旋转、缩放）")
		print("   ✅ 事件系统支持")
		print("   ✅ 插槽/附件动画切换")
		print("   ✅ 同名贴图初始隐藏")
		print("   ✅ 动画时长自动计算")
		print("   ✅ 可见性属性无插值")
	else:
		print("\n❌ 转换失败！")
