@tool
extends EditorScript

# Spine到Godot转换工具
# 在Godot编辑器中通过"运行脚本"菜单执行

# 输入Spine JSON文件路径
var spine_json_path: String = "d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/robots_art_pack/spine/characters/customer.spinejson"

# 输出Godot场景文件路径
var output_scene_path: String = "d:/A_Godot/A_SuperToy/assets/世界1/角色/customer.tscn"

func _run():
	print("========================================")
	print("开始Spine到Godot转换")
	print("========================================")
	print("输入文件: " + spine_json_path)
	print("输出文件: " + output_scene_path)
	print("========================================\n")
	
	var converter = load("res://addons/spine_to_godot_converter/spine_converter.gd").new()
	
	if converter.convert_spine_complete(spine_json_path, output_scene_path):
		print("\n✅ 转换成功！")
		print("输出文件: " + output_scene_path)
	else:
		print("\n❌ 转换失败！")
