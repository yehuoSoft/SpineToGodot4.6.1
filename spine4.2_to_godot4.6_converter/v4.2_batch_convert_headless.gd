extends SceneTree

# Spine到Godot批量自动转换器
# 一键转换SuperWEIRDGameKit_assets目录下所有.spinejson文件

func _init():
	var converter = load("res://addons/spine_to_godot_converter/spine_converter.gd").new()
	
	# 获取所有.spinejson文件
	var spine_json_files = get_all_spinejson_files()
	
	print("========================================")
	print("开始批量转换Spine到Godot")
	print("找到 " + str(spine_json_files.size()) + " 个.spinejson文件")
	print("========================================\n")
	
	var success_count = 0
	var error_count = 0
	
	for spine_json_path in spine_json_files:
		# 生成输出场景文件路径（与.spinejson文件在同一目录）
		var output_scene_path = spine_json_path.replace(".spinejson", ".tscn")
		
		print("正在转换: " + spine_json_path)
		print("输出到: " + output_scene_path)
		
		# 设置转换器的图像路径（与.spinejson文件在同一目录的images文件夹）
		var directory_path = spine_json_path.get_base_dir()
		converter.config.image_path = directory_path + "/images/"
		
		if converter.convert_spine_complete(spine_json_path, output_scene_path):
			print("✅ 转换成功！")
			success_count += 1
		else:
			print("❌ 转换失败！")
			error_count += 1
		
		print("")
	
	print("========================================")
	print("批量转换完成！")
	print("成功: " + str(success_count) + " 个文件")
	print("失败: " + str(error_count) + " 个文件")
	print("========================================")
	
	quit()

# 获取所有.spinejson文件路径
func get_all_spinejson_files() -> Array:
	var spine_json_files = []
	
	# alchemist_art_pack
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/alchemist_art_pack/spine/buildings/shop.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/alchemist_art_pack/spine/buildings/trashbin.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/alchemist_art_pack/spine/buildings/workbench.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/alchemist_art_pack/spine/characters/customer.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/alchemist_art_pack/spine/characters/main.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/alchemist_art_pack/spine/generators/generator1.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/alchemist_art_pack/spine/generators/generator2.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/alchemist_art_pack/spine/generators/generator3.spinejson")
	
	# boxboy_art_pack
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/boxboy_art_pack/spine/buildings/shop.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/boxboy_art_pack/spine/buildings/trashbin.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/boxboy_art_pack/spine/buildings/workbench.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/boxboy_art_pack/spine/characters/customer.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/boxboy_art_pack/spine/characters/main.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/boxboy_art_pack/spine/generators/generator1.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/boxboy_art_pack/spine/generators/generator2.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/boxboy_art_pack/spine/generators/generator3.spinejson")
	
	# gnomes_art_pack
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/gnomes_art_pack/spine/buildings/shop.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/gnomes_art_pack/spine/buildings/trashbin.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/gnomes_art_pack/spine/buildings/workbench.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/gnomes_art_pack/spine/characters/customer.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/gnomes_art_pack/spine/characters/main.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/gnomes_art_pack/spine/generators/generator2.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/gnomes_art_pack/spine/generators/generator3.spinejson")
	
	# patapon_art_pack
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/patapon_art_pack/spine/buildings/shop.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/patapon_art_pack/spine/buildings/trashbin.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/patapon_art_pack/spine/buildings/workbench.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/patapon_art_pack/spine/characters/customer.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/patapon_art_pack/spine/characters/main.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/patapon_art_pack/spine/generators/generator1.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/patapon_art_pack/spine/generators/generator2.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/patapon_art_pack/spine/generators/generator3.spinejson")
	
	# robots_art_pack
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/robots_art_pack/spine/buildings/shop.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/robots_art_pack/spine/buildings/trashbin.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/robots_art_pack/spine/buildings/workbench.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/robots_art_pack/spine/characters/customer.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/robots_art_pack/spine/characters/main.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/robots_art_pack/spine/generators/generator1.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/robots_art_pack/spine/generators/generator2.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/robots_art_pack/spine/generators/generator3.spinejson")
	
	# vikings_art_pack
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/vikings_art_pack/spine/buildings/shop.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/vikings_art_pack/spine/buildings/trashbin.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/vikings_art_pack/spine/buildings/workbench.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/vikings_art_pack/spine/characters/customer.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/vikings_art_pack/spine/characters/main.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/vikings_art_pack/spine/generators/generator1.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/vikings_art_pack/spine/generators/generator2.spinejson")
	spine_json_files.append("d:/A_Godot/A_SuperToy/assets/SuperWEIRDGameKit_assets/vikings_art_pack/spine/generators/generator3.spinejson")
	
	return spine_json_files
