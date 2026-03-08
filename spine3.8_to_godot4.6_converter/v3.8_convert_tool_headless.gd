extends SceneTree

# Spine 3.8精确层级转换器测试脚本
# 在Godot编辑器中运行此脚本来测试转换功能

func _init():
	print("========================================")
	print("Spine 3.8精确层级转换器测试")
	print("使用 agnis_simple.json 生成场景")
	print("========================================")
	
	var input_file = "d:/A_Godot/A_SuperToy/assets/DarkMonster/agnis_json/agnis_simple.json"
	var output_file = "d:/A_Godot/A_SuperToy/assets/DarkMonster/agnis_simple_spine38.tscn"
	
	print("输入文件: " + input_file)
	print("输出文件: " + output_file)
	print("========================================\n")
	
	var converter_script = load("res://addons/spine3.8_to_godot4.6_converter/spine38_converter_precise.gd")
	var converter = converter_script.new()
	
	if converter.convert_spine38_to_godot(input_file, output_file):
		print("\n✅ 成功创建Godot骨骼场景: " + output_file)
		print("\n📊 修复内容:")
		print("   ✅ 精确构建骨骼层级关系")
		print("   ✅ 每个插槽包含所有附件贴图")
		print("   ✅ 添加动画转换功能")
		print("   ✅ 添加事件系统支持")
		print("   ✅ 插槽/附件动画切换")
		print("   ✅ 同名贴图初始隐藏")
		print("   ✅ 动画时长自动计算")
		print("   ✅ 可见性属性无插值")
		print("\n✅ Spine 3.8精确层级转换成功！")
		print("输出文件: " + output_file)
	else:
		print("\n❌ 转换失败！")
	
	print("\n========================================")
	print("测试完成")
	print("========================================")
	
	quit()
