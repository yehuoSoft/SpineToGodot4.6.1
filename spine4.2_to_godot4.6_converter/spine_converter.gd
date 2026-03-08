extends RefCounted

# Spine到Godot骨骼通用转换器
# 基于Spine和Godot坐标系差异的正确转换

class_name SpineToGodotConverter

# 主转换器类
var spine_data: Dictionary
var bones: Array
var slots: Array
var attachments: Dictionary
var skeleton_info: Dictionary

# 转换配置
var config: Dictionary = {
	"image_path": "res://assets/SuperWEIRDGameKit_assets/robots_art_pack/spine/characters/images/",
	"output_path": "res://assets/世界1/角色/",
	"scale_factor": 1.0,
	"flip_y": true
}

# 解析骨骼数据
func parse_bone_data(bone_data: Dictionary) -> Dictionary:
	return {
		"name": bone_data.get("name", ""),
		"parent": bone_data.get("parent", ""),
		"length": bone_data.get("length", 0.0),
		"rotation": bone_data.get("rotation", 0.0),
		"x": bone_data.get("x", 0.0),
		"y": bone_data.get("y", 0.0),
		"scale_x": bone_data.get("scaleX", 1.0),
		"scale_y": bone_data.get("scaleY", 1.0),
		"inherit": bone_data.get("inherit", "normal"),
		"icon": bone_data.get("icon", "")
	}

# 解析插槽数据
func parse_slot_data(slot_data: Dictionary) -> Dictionary:
	return {
		"name": slot_data.get("name", ""),
		"bone": slot_data.get("bone", ""),
		"attachment": slot_data.get("attachment", ""),
		"color": slot_data.get("color", ""),
		"blend": slot_data.get("blend", "normal")
	}

# 解析attachment数据
func parse_attachment_data(attachment_data: Dictionary) -> Dictionary:
	return {
		"x": attachment_data.get("x", 0.0),
		"y": attachment_data.get("y", 0.0),
		"rotation": attachment_data.get("rotation", 0.0),
		"scale_x": attachment_data.get("scaleX", 1.0),
		"scale_y": attachment_data.get("scaleY", 1.0),
		"width": attachment_data.get("width", 0),
		"height": attachment_data.get("height", 0)
	}

# 加载Spine JSON文件
func load_spine_json(file_path: String) -> bool:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("错误: 无法打开Spine JSON文件: " + file_path)
		return false
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	if parse_result != OK:
		print("错误: 解析Spine JSON失败: " + json.get_error_message())
		return false
	
	spine_data = json.data
	
	if spine_data.has("skeleton"):
		skeleton_info = spine_data["skeleton"]
	
	if spine_data.has("bones"):
		bones.clear()
		for bone_data in spine_data["bones"]:
			var bone = parse_bone_data(bone_data)
			bones.append(bone)
	
	if spine_data.has("slots"):
		slots.clear()
		for slot_data in spine_data["slots"]:
			var slot = parse_slot_data(slot_data)
			slots.append(slot)
	
	if spine_data.has("skins"):
		attachments.clear()
		var default_skin = spine_data["skins"][0] if spine_data["skins"].size() > 0 else null
		if default_skin and default_skin.has("attachments"):
			for slot_name in default_skin["attachments"]:
				var slot_attachments = default_skin["attachments"][slot_name]
				for attachment_name in slot_attachments:
					var attachment_data = parse_attachment_data(slot_attachments[attachment_name])
					# 使用 slot_name 作为key，因为同一个slot可能有多个attachment
					attachments[slot_name] = attachment_data
	
	print("成功加载Spine JSON文件: " + file_path)
	print("骨骼数量: " + str(bones.size()))
	print("插槽数量: " + str(slots.size()))
	print("Attachment数量: " + str(attachments.size()))
	
	return true

# 获取实际贴图文件名（直接使用attachment名称）
func get_actual_texture_filename(attachment_name: String) -> String:
	return attachment_name

# 检查贴图文件是否存在
func texture_file_exists(texture_filename: String) -> bool:
	var texture_path = config.image_path + texture_filename + ".png"
	return FileAccess.file_exists(texture_path)

# 获取attachment的位置偏移（正确处理坐标系转换）
# Spine: Y轴向上, Godot: Y轴向下
# Spine的attachment位置是相对于骨骼的局部偏移
# 使用slot名称作为key来获取attachment数据
func get_attachment_offset(slot_name: String) -> Vector2:
	if attachments.has(slot_name):
		var attachment = attachments[slot_name]
		# Spine中的位置是相对于骨骼的局部偏移
		# 需要翻转Y轴（Spine Y向上，Godot Y向下）
		var offset = Vector2(attachment["x"], -attachment["y"]) * config.scale_factor
		return offset
	return Vector2.ZERO

# 获取attachment的旋转角度（需要翻转）
# 使用slot名称作为key来获取attachment数据
func get_attachment_rotation(slot_name: String) -> float:
	if attachments.has(slot_name):
		var attachment = attachments[slot_name]
		# Spine的旋转需要翻转（顺时针vs逆时针）
		return deg_to_rad(-attachment["rotation"])
	return 0.0

# 获取attachment的缩放
# 使用slot名称作为key来获取attachment数据
func get_attachment_scale(slot_name: String) -> Vector2:
	if attachments.has(slot_name):
		var attachment = attachments[slot_name]
		return Vector2(attachment["scale_x"], attachment["scale_y"])
	return Vector2.ONE

# 转换角度（度到弧度）
func deg_to_rad(degrees: float) -> float:
	return degrees * PI / 180.0

# 生成骨骼节点文本（正确处理骨骼位置的Y轴翻转）
func generate_bone_node_text(bone: Dictionary, parent_path: String, indent: int) -> String:
	var indent_str = "\t".repeat(indent)
	var bone_name = bone.get("name", "")
	
	var node_text = indent_str + "[node name=\"" + bone_name + "\" type=\"Bone2D\" parent=\"" + parent_path + "\"]\n"
	
	var bone_x = bone.get("x", 0.0)
	var bone_y = bone.get("y", 0.0)
	var bone_rotation = bone.get("rotation", 0.0)
	var bone_scale_x = bone.get("scale_x", 1.0)
	var bone_scale_y = bone.get("scale_y", 1.0)
	var bone_length = bone.get("length", 10.0)
	
	# 如果长度为0，设置一个默认长度以避免Bone2D警告
	if bone_length == 0:
		bone_length = 10.0
	
	# Spine骨骼位置也需要翻转Y轴
	var position = Vector2(bone_x, -bone_y) * config.scale_factor
	
	# 计算Transform2D矩阵分量
	var rotation_rad = deg_to_rad(-bone_rotation)
	var cos_rot = cos(rotation_rad)
	var sin_rot = sin(rotation_rad)
	
	# 构建Transform2D矩阵
	# 正确处理负scale的情况
	var x_axis_x = cos_rot * abs(bone_scale_x)
	var x_axis_y = sin_rot * abs(bone_scale_x)
	var y_axis_x = -sin_rot * abs(bone_scale_y)
	var y_axis_y = cos_rot * abs(bone_scale_y)
	
	# 如果scale为负，需要调整旋转方向
	if bone_scale_x < 0:
		x_axis_x = -x_axis_x
		x_axis_y = -x_axis_y
	if bone_scale_y < 0:
		y_axis_x = -y_axis_x
		y_axis_y = -y_axis_y
	
	# 计算Transform2D矩阵的实际旋转角度
	var actual_rotation = atan2(x_axis_y, x_axis_x)
	
	# 当scale为负值时，将scale重置为正值（因为旋转角度已经包含了负scale的效果）
	var final_scale_x = abs(bone_scale_x)
	var final_scale_y = abs(bone_scale_y)
	
	node_text += indent_str + "\tposition = Vector2(" + str(position.x) + ", " + str(position.y) + ")\n"
	node_text += indent_str + "\trotation = " + str(actual_rotation) + "\n"
	node_text += indent_str + "\tscale = Vector2(" + str(final_scale_x) + ", " + str(final_scale_y) + ")\n"
	node_text += indent_str + "\tlength = " + str(bone_length) + "\n"
	
	# 添加rest属性（Transform2D矩阵）
	node_text += indent_str + "\trest = Transform2D(" + str(x_axis_x) + ", " + str(x_axis_y) + ", " + str(y_axis_x) + ", " + str(y_axis_y) + ", " + str(position.x) + ", " + str(position.y) + ")\n"
	
	node_text += indent_str + "\n"
	
	return node_text

# 生成精灵节点文本
func generate_sprite_node_text(slot: Dictionary, parent_path: String, texture_resources: Dictionary, indent: int) -> String:
	var indent_str = "\t".repeat(indent)
	var slot_attachment = slot.get("attachment", "")
	var slot_bone = slot.get("bone", "")
	var slot_name = slot.get("name", "")
	
	if slot_attachment == "" or slot_bone == "":
		return ""
	
	var actual_texture_name = get_actual_texture_filename(slot_attachment)
	var texture_path = config.image_path + actual_texture_name + ".png"
	
	if not texture_file_exists(actual_texture_name):
		print("跳过不存在的贴图: " + slot_attachment)
		return ""
	
	if not texture_resources.has(texture_path):
		return ""
	
	var position_offset = get_attachment_offset(slot_name)
	var rotation_offset = get_attachment_rotation(slot_name)
	var scale_offset = get_attachment_scale(slot_name)
	
	var node_text = indent_str + "[node name=\"" + slot_name + "\" type=\"Sprite2D\" parent=\"" + parent_path + "\"]\n"
	node_text += indent_str + "\tposition = Vector2(" + str(position_offset.x) + ", " + str(position_offset.y) + ")\n"
	node_text += indent_str + "\trotation = " + str(rotation_offset) + "\n"
	node_text += indent_str + "\tscale = Vector2(" + str(scale_offset.x) + ", " + str(scale_offset.y) + ")\n"
	node_text += indent_str + "\ttexture = ExtResource(\"" + str(texture_resources[texture_path]) + "\")\n"
	node_text += indent_str + "\n"
	
	return node_text

# 递归构建骨骼层级
func build_bone_hierarchy_recursive(bones: Array, bone_children: Dictionary, parent_path: String, bone_name: String, indent: int, texture_resources: Dictionary, slots: Array) -> String:
	var result = ""
	
	var current_bone = null
	for bone in bones:
		if bone.get("name", "") == bone_name:
			current_bone = bone
			break
	
	if current_bone == null:
		return result
	
	result += generate_bone_node_text(current_bone, parent_path, indent)
	
	var current_bone_path = parent_path + "/" + bone_name
	for slot in slots:
		if slot.get("bone", "") == bone_name:
			result += generate_sprite_node_text(slot, current_bone_path, texture_resources, indent + 1)
	
	if bone_children.has(bone_name):
		for child_bone in bone_children[bone_name]:
			result += build_bone_hierarchy_recursive(bones, bone_children, current_bone_path, child_bone, indent + 1, texture_resources, slots)
	
	return result

# 生成Godot场景文本内容
func generate_godot_scene_text(scene_name: String) -> String:
	var scene_text = "[gd_scene format=3]\n\n"
	
	var texture_resources = {}
	var resource_id = 1
	
	for slot in slots:
		var attachment = slot.get("attachment", "")
		if attachment != "":
			var actual_texture_name = get_actual_texture_filename(attachment)
			var texture_path = config.image_path + actual_texture_name + ".png"
			
			if texture_file_exists(actual_texture_name):
				if not texture_resources.has(texture_path):
					texture_resources[texture_path] = resource_id
					resource_id += 1
			else:
				print("警告: 贴图文件不存在: " + texture_path)
	
	for texture_path in texture_resources:
		var resource_id_str = str(texture_resources[texture_path])
		scene_text += "[ext_resource type=\"Texture2D\" path=\"" + texture_path + "\" id=\"" + resource_id_str + "\"]\n"
	
	scene_text += "\n"
	
	scene_text += "[sub_resource type=\"Animation\" id=\"Animation_RESET\"]\n"
	scene_text += "resource_name = \"RESET\"\n"
	scene_text += "length = 0.001\n"
	scene_text += "\n"
	
	scene_text += "[sub_resource type=\"AnimationLibrary\" id=\"AnimationLibrary_main\"]\n"
	scene_text += "_data = {\n"
	scene_text += "&\"RESET\": SubResource(\"Animation_RESET\"),\n"
	scene_text += "}\n"
	scene_text += "\n"
	
	scene_text += "[node name=\"" + scene_name + "\" type=\"CharacterBody2D\"]\n\n"
	scene_text += "[node name=\"视觉容器\" type=\"Node2D\" parent=\".\"]\n\n"
	scene_text += "[node name=\"Skeleton2D\" type=\"Skeleton2D\" parent=\"视觉容器\"]\n\n"
	
	var root_bones = []
	var bone_children = {}
	
	for bone in bones:
		var bone_name = bone.get("name", "")
		var bone_parent = bone.get("parent", "")
		
		if bone_parent == "":
			root_bones.append(bone_name)
		else:
			if not bone_children.has(bone_parent):
				bone_children[bone_parent] = []
			bone_children[bone_parent].append(bone_name)
	
	for root_bone in root_bones:
		scene_text += build_bone_hierarchy_recursive(bones, bone_children, "视觉容器/Skeleton2D", root_bone, 0, texture_resources, slots)
	
	scene_text += "[node name=\"AnimationPlayer\" type=\"AnimationPlayer\" parent=\".\"]\n"
	scene_text += "libraries = {\n"
	scene_text += "SubResource(\"AnimationLibrary_main\"): SubResource(\"AnimationLibrary_main\")\n"
	scene_text += "}\n"
	
	return scene_text

# 保存场景到文件
func save_scene(scene_text: String, file_path: String) -> bool:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		print("错误: 无法创建场景文件: " + file_path)
		return false
	
	file.store_string(scene_text)
	file.close()
	
	return true

# 主转换函数
func convert_spine_to_godot(spine_json_path: String, output_scene_path: String) -> bool:
	if not load_spine_json(spine_json_path):
		return false
	
	var scene_name = output_scene_path.get_file().get_basename()
	var scene_text = generate_godot_scene_text(scene_name)
	
	if save_scene(scene_text, output_scene_path):
		print("成功创建Godot骨骼场景: " + output_scene_path)
		return true
	else:
		print("错误: 保存场景失败: " + output_scene_path)
		return false

# 设置配置
func set_config(new_config: Dictionary):
	config = new_config

# 获取当前配置
func get_config() -> Dictionary:
	return config.duplicate()

# 解析动画数据
func parse_animation_data(animation_data: Dictionary) -> Dictionary:
	var bones = {}
	if animation_data.has("bones"):
		for bone_name in animation_data["bones"]:
			var bone_anim = animation_data["bones"][bone_name]
			bones[bone_name] = bone_anim
	return bones

# 加载Spine JSON文件并获取动画数据
func load_spine_json_with_animation(spine_json_path: String, animation_name: String) -> bool:
	if not load_spine_json(spine_json_path):
		return false
	
	if spine_data.has("animations"):
		var animations = spine_data["animations"]
		if animations.has(animation_name):
			var animation_data = animations[animation_name]
			animation_bones = parse_animation_data(animation_data)
			print("成功加载动画: " + animation_name)
			print("动画骨骼数量: " + str(animation_bones.size()))
			return true
		else:
			print("错误: 动画不存在: " + animation_name)
			return false
	else:
		print("错误: Spine JSON中没有动画数据")
		return false

# 生成Godot动画轨道文本
# 注意：Spine动画中的rotate和translate是相对于骨骼初始姿态的增量
# 需要将动画增量叠加到骨骼初始变换上
func generate_godot_animation_track_text(bone_name: String, bone_anim: Dictionary, indent: int, bone_index_map: Dictionary, base_track_index: int) -> Dictionary:
	var indent_str = "\t".repeat(indent)
	var track_text = ""
	var track_count = 0
	
	if not bone_index_map.has(bone_name):
		return {"text": "", "count": 0}
	
	var bone_data = bone_index_map[bone_name]
	
	var bone_initial_rotation = bone_data.get("rotation", 0.0)
	var bone_initial_x = bone_data.get("x", 0.0)
	var bone_initial_y = bone_data.get("y", 0.0)
	var bone_initial_scale_x = bone_data.get("scale_x", 1.0)
	var bone_initial_scale_y = bone_data.get("scale_y", 1.0)
	
	# 计算骨骼的初始Transform2D矩阵
	var rotation_rad = deg_to_rad(-bone_initial_rotation)
	var cos_rot = cos(rotation_rad)
	var sin_rot = sin(rotation_rad)
	
	var x_axis_x = cos_rot * abs(bone_initial_scale_x)
	var x_axis_y = sin_rot * abs(bone_initial_scale_x)
	var y_axis_x = -sin_rot * abs(bone_initial_scale_y)
	var y_axis_y = cos_rot * abs(bone_initial_scale_y)
	
	if bone_initial_scale_x < 0:
		x_axis_x = -x_axis_x
		x_axis_y = -x_axis_y
	if bone_initial_scale_y < 0:
		y_axis_x = -y_axis_x
		y_axis_y = -y_axis_y
	
	var bone_initial_transform = Transform2D(Vector2(x_axis_x, x_axis_y), Vector2(y_axis_x, y_axis_y), Vector2(bone_initial_x, -bone_initial_y))
	var bone_initial_godot_rotation = bone_initial_transform.get_rotation()
	
	var bone_path = "视觉容器/Skeleton2D/"
	var current_bone_name = bone_name
	var path_parts = []
	var traverse_data = bone_data
	
	while current_bone_name != "":
		path_parts.push_front(current_bone_name)
		var parent_name = traverse_data.get("parent", "")
		if parent_name == "":
			break
		current_bone_name = parent_name
		if bone_index_map.has(current_bone_name):
			traverse_data = bone_index_map[current_bone_name]
		else:
			break
	
	bone_path += "/".join(path_parts)
	
	if bone_anim.has("rotate"):
		var rotates = bone_anim["rotate"]
		if rotates.size() > 0:
			var current_track_index = base_track_index + track_count
			track_text += indent_str + "tracks/" + str(current_track_index) + "/type = \"value\"\n"
			track_text += indent_str + "tracks/" + str(current_track_index) + "/imported = false\n"
			track_text += indent_str + "tracks/" + str(current_track_index) + "/enabled = true\n"
			track_text += indent_str + "tracks/" + str(current_track_index) + "/path = NodePath(\"" + bone_path + ":rotation\")\n"
			track_text += indent_str + "tracks/" + str(current_track_index) + "/interp = 1\n"
			track_text += indent_str + "tracks/" + str(current_track_index) + "/loop_wrap = true\n"
			track_text += indent_str + "tracks/" + str(current_track_index) + "/keys = {\n"
			
			var times = []
			var values = []
			for rotate in rotates:
				var time = rotate.get("time", 0.0)
				var delta_rotation = rotate.get("value", 0.0)
				times.append(time)
				var godot_delta_rotation = deg_to_rad(-delta_rotation)
				var final_rotation = bone_initial_godot_rotation + godot_delta_rotation
				values.append(final_rotation)
			
			var times_str = ""
			for i in range(times.size()):
				if i > 0:
					times_str += ", "
				times_str += str(times[i])
			
			var transitions_str = ""
			for i in range(times.size()):
				if i > 0:
					transitions_str += ", "
				transitions_str += "1"
			
			var values_str = ""
			for i in range(values.size()):
				if i > 0:
					values_str += ", "
				values_str += str(values[i])
			
			track_text += indent_str + "\"times\": PackedFloat32Array(" + times_str + "),\n"
			track_text += indent_str + "\"transitions\": PackedFloat32Array(" + transitions_str + "),\n"
			track_text += indent_str + "\"update\": 0,\n"
			track_text += indent_str + "\"values\": [" + values_str + "]\n"
			track_text += indent_str + "}\n"
			track_count += 1
	
	if bone_anim.has("translate"):
		var translates = bone_anim["translate"]
		if translates.size() > 0:
			var current_track_index = base_track_index + track_count
			track_text += indent_str + "tracks/" + str(current_track_index) + "/type = \"value\"\n"
			track_text += indent_str + "tracks/" + str(current_track_index) + "/imported = false\n"
			track_text += indent_str + "tracks/" + str(current_track_index) + "/enabled = true\n"
			track_text += indent_str + "tracks/" + str(current_track_index) + "/path = NodePath(\"" + bone_path + ":position\")\n"
			track_text += indent_str + "tracks/" + str(current_track_index) + "/interp = 1\n"
			track_text += indent_str + "tracks/" + str(current_track_index) + "/loop_wrap = true\n"
			track_text += indent_str + "tracks/" + str(current_track_index) + "/keys = {\n"
			
			var times = []
			var values = []
			for translate in translates:
				var time = translate.get("time", 0.0)
				var delta_x = translate.get("x", 0.0)
				var delta_y = translate.get("y", 0.0)
				times.append(time)
				var godot_initial_x = bone_initial_x
				var godot_initial_y = -bone_initial_y
				var godot_delta_x = delta_x
				var godot_delta_y = -delta_y
				var final_x = (godot_initial_x + godot_delta_x) * config.scale_factor
				var final_y = (godot_initial_y + godot_delta_y) * config.scale_factor
				values.append("Vector2(" + str(final_x) + ", " + str(final_y) + ")")
			
			var times_str = ""
			for i in range(times.size()):
				if i > 0:
					times_str += ", "
				times_str += str(times[i])
			
			var transitions_str = ""
			for i in range(times.size()):
				if i > 0:
					transitions_str += ", "
				transitions_str += "1"
			
			var values_str = ""
			for i in range(values.size()):
				if i > 0:
					values_str += ", "
				values_str += values[i]
			
			track_text += indent_str + "\"times\": PackedFloat32Array(" + times_str + "),\n"
			track_text += indent_str + "\"transitions\": PackedFloat32Array(" + transitions_str + "),\n"
			track_text += indent_str + "\"update\": 0,\n"
			track_text += indent_str + "\"values\": [" + values_str + "]\n"
			track_text += indent_str + "}\n"
			track_count += 1
	
	if bone_anim.has("scale"):
		var scales = bone_anim["scale"]
		if scales.size() > 0:
			var current_track_index = base_track_index + track_count
			track_text += indent_str + "tracks/" + str(current_track_index) + "/type = \"value\"\n"
			track_text += indent_str + "tracks/" + str(current_track_index) + "/imported = false\n"
			track_text += indent_str + "tracks/" + str(current_track_index) + "/enabled = true\n"
			track_text += indent_str + "tracks/" + str(current_track_index) + "/path = NodePath(\"" + bone_path + ":scale\")\n"
			track_text += indent_str + "tracks/" + str(current_track_index) + "/interp = 1\n"
			track_text += indent_str + "tracks/" + str(current_track_index) + "/loop_wrap = true\n"
			track_text += indent_str + "tracks/" + str(current_track_index) + "/keys = {\n"
			
			var times = []
			var values = []
			for scale in scales:
				var time = scale.get("time", 0.0)
				var delta_scale_x = scale.get("x", 1.0)
				var delta_scale_y = scale.get("y", 1.0)
				times.append(time)
				var final_scale_x = bone_initial_scale_x * delta_scale_x
				var final_scale_y = bone_initial_scale_y * delta_scale_y
				values.append("Vector2(" + str(final_scale_x) + ", " + str(final_scale_y) + ")")
			
			var times_str = ""
			for i in range(times.size()):
				if i > 0:
					times_str += ", "
				times_str += str(times[i])
			
			var transitions_str = ""
			for i in range(times.size()):
				if i > 0:
					transitions_str += ", "
				transitions_str += "1"
			
			var values_str = ""
			for i in range(values.size()):
				if i > 0:
					values_str += ", "
				values_str += values[i]
			
			track_text += indent_str + "\"times\": PackedFloat32Array(" + times_str + "),\n"
			track_text += indent_str + "\"transitions\": PackedFloat32Array(" + transitions_str + "),\n"
			track_text += indent_str + "\"update\": 0,\n"
			track_text += indent_str + "\"values\": [" + values_str + "]\n"
			track_text += indent_str + "}\n"
			track_count += 1
	
	return {"text": track_text, "count": track_count}

func calculate_animation_length(animation_bones: Dictionary) -> float:
	var max_time = 0.001
	
	for bone_name in animation_bones:
		var bone_anim = animation_bones[bone_name]
		
		if bone_anim.has("rotate"):
			for rotate in bone_anim["rotate"]:
				var time = rotate.get("time", 0.0)
				if time > max_time:
					max_time = time
		
		if bone_anim.has("translate"):
			for translate in bone_anim["translate"]:
				var time = translate.get("time", 0.0)
				if time > max_time:
					max_time = time
		
		if bone_anim.has("scale"):
			for scale in bone_anim["scale"]:
				var time = scale.get("time", 0.0)
				if time > max_time:
					max_time = time
	
	return max_time

func generate_godot_animation_resource_text(animation_name: String, animation_bones: Dictionary, bone_list: Array) -> String:
	var anim_length = calculate_animation_length(animation_bones)
	
	var resource_text = "[sub_resource type=\"Animation\" id=\"Animation_" + animation_name + "\"]\n"
	resource_text += "resource_name = \"" + animation_name + "\"\n"
	resource_text += "length = " + str(anim_length) + "\n"
	
	var bone_index_map: Dictionary
	for bone in bone_list:
		bone_index_map[bone.get("name", "")] = bone
	
	var track_index = 0
	for bone_name in animation_bones:
		var bone_anim = animation_bones[bone_name]
		var result = generate_godot_animation_track_text(bone_name, bone_anim, 0, bone_index_map, track_index)
		resource_text += result["text"]
		track_index += result["count"]
	
	return resource_text

# 生成Godot动画库文本
func generate_godot_animation_library_text() -> String:
	var library_text = "[sub_resource type=\"AnimationLibrary\" id=\"AnimationLibrary_" + "idle" + "\"]\n"
	library_text += "_data = {\n"
	library_text += "\t&\"idle\": SubResource(\"Animation_idle\")\n"
	library_text += "}\n"
	return library_text

# 主动画转换函数
func convert_spine_animation_to_godot(spine_json_path: String, output_scene_path: String, animation_name: String) -> bool:
	if not load_spine_json_with_animation(spine_json_path, animation_name):
		return false
	
	print("动画骨骼数据: " + str(animation_bones))
	
	var scene_text = ""
	var file = FileAccess.open(output_scene_path, FileAccess.READ)
	if file != null:
		scene_text = file.get_as_text()
		file.close()
	
	var target_anim_id = ""
	var lib_pattern = "&\"" + animation_name + "\": SubResource(\""
	var lib_pos = scene_text.find(lib_pattern)
	if lib_pos != -1:
		var id_start = scene_text.find("SubResource(\"", lib_pos)
		if id_start != -1:
			var id_end = scene_text.find("\")", id_start + 12)
			if id_end != -1:
				target_anim_id = scene_text.substr(id_start + 12, id_end - id_start - 12)
				if target_anim_id.begins_with("\""):
					target_anim_id = target_anim_id.substr(1)
				print("找到目标动画ID: " + target_anim_id)
	
	if target_anim_id == "":
		target_anim_id = "Animation_" + animation_name
	
	var animation_resource = generate_godot_animation_resource_text_with_id(animation_name, animation_bones, bones, target_anim_id)
	
	print("生成的动画资源:\n" + animation_resource)
	
	var lines = scene_text.split("\n")
	var new_lines = []
	var in_target_animation = false
	var animation_library_index = -1
	var in_animation_library = false
	var anim_added_to_library = false
	var i = 0
	
	var anim_ids_to_remove = [target_anim_id, "Animation_" + animation_name]
	
	while i < lines.size():
		var line = lines[i]
		
		if line.find("[sub_resource type=\"AnimationLibrary\"") != -1:
			animation_library_index = new_lines.size()
			in_animation_library = true
		
		if in_animation_library and not anim_added_to_library:
			if line.find("&\"RESET\":") != -1:
				new_lines.append(line)
				new_lines.append("&\"" + animation_name + "\": SubResource(\"" + target_anim_id + "\"),\n")
				anim_added_to_library = true
				i += 1
				continue
			elif line.strip_edges() == "}":
				new_lines.append("&\"" + animation_name + "\": SubResource(\"" + target_anim_id + "\"),\n")
				new_lines.append(line)
				anim_added_to_library = true
				in_animation_library = false
				i += 1
				continue
		
		if line.begins_with("[sub_resource type=\"Animation\""):
			var current_anim_id = ""
			var id_match_start = line.find("id=\"")
			if id_match_start != -1:
				var id_match_end = line.find("\"", id_match_start + 4)
				if id_match_end != -1:
					current_anim_id = line.substr(id_match_start + 4, id_match_end - id_match_start - 4)
			
			if current_anim_id in anim_ids_to_remove:
				in_target_animation = true
				i += 1
				continue
		
		if in_target_animation:
			if line.begins_with("[sub_resource") or line.begins_with("[node") or line.begins_with("[gd_scene"):
				in_target_animation = false
				new_lines.append(line)
			i += 1
			continue
		
		new_lines.append(line)
		i += 1
	
	if animation_library_index != -1:
		new_lines.insert(animation_library_index, animation_resource)
		print("在AnimationLibrary前插入动画资源，位置: " + str(animation_library_index))
	else:
		new_lines.append(animation_resource)
		print("在文件末尾添加动画资源")
	
	var new_scene_text = "\n".join(new_lines)
	
	if save_scene(new_scene_text, output_scene_path):
		print("成功创建Godot动画: " + animation_name)
		return true
	else:
		print("错误: 保存场景失败: " + output_scene_path)
		return false

# 生成Godot动画资源文本（使用指定ID）
func generate_godot_animation_resource_text_with_id(animation_name: String, animation_bones: Dictionary, bone_list: Array, resource_id: String) -> String:
	var anim_length = calculate_animation_length(animation_bones)
	
	var resource_text = "[sub_resource type=\"Animation\" id=\"" + resource_id + "\"]\n"
	resource_text += "resource_name = \"" + animation_name + "\"\n"
	resource_text += "length = " + str(anim_length) + "\n"
	
	var bone_index_map: Dictionary
	for bone in bone_list:
		bone_index_map[bone.get("name", "")] = bone
	
	var track_index = 0
	for bone_name in animation_bones:
		var bone_anim = animation_bones[bone_name]
		var result = generate_godot_animation_track_text(bone_name, bone_anim, 0, bone_index_map, track_index)
		resource_text += result["text"]
		track_index += result["count"]
	
	return resource_text

# 动画骨骼数据
var animation_bones: Dictionary = {}

# 获取Spine JSON中所有动画名称
func get_animation_names() -> Array:
	var anim_names = []
	if spine_data.has("animations"):
		for anim_name in spine_data["animations"].keys():
			anim_names.append(anim_name)
	return anim_names

# 完整转换：骨骼 + 所有动画
func convert_spine_complete(spine_json_path: String, output_scene_path: String) -> bool:
	print("\n========================================")
	print("开始完整Spine到Godot转换")
	print("========================================")
	print("输入文件: " + spine_json_path)
	print("输出文件: " + output_scene_path)
	print("========================================\n")
	
	print("步骤1: 转换骨骼结构...")
	if not convert_spine_to_godot(spine_json_path, output_scene_path):
		print("❌ 骨骼转换失败！")
		return false
	print("✅ 骨骼转换完成！\n")
	
	if not load_spine_json(spine_json_path):
		print("❌ 无法重新加载Spine JSON！")
		return false
	
	var anim_names = get_animation_names()
	if anim_names.size() == 0:
		print("⚠️ 没有找到动画数据")
		return true
	
	print("步骤2: 转换动画 (" + str(anim_names.size()) + " 个)...")
	print("动画列表: " + str(anim_names))
	print("")
	
	for anim_name in anim_names:
		print("转换动画: " + anim_name)
		if convert_spine_animation_to_godot(spine_json_path, output_scene_path, anim_name):
			print("✅ " + anim_name + " 转换成功")
		else:
			print("❌ " + anim_name + " 转换失败")
		print("")
	
	print("========================================")
	print("✅ 完整转换完成！")
	print("输出文件: " + output_scene_path)
	print("========================================")
	
	return true
