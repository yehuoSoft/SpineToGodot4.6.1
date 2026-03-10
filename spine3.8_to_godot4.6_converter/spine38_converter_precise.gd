@tool
extends RefCounted

class_name Spine38ToGodotConverterPrecise

var config: Dictionary = {
	"image_path": "",
	"output_path": "res://assets/DarkMonster/",
	"scale_factor": 1.0,
	"flip_y": false
}

var spine_data: Dictionary
var animation_bones: Dictionary = {}

func _init():
	pass

func build_bone_hierarchy_precise() -> Dictionary:
	var bone_hierarchy = {}
	
	if not spine_data.has("bones"):
		return bone_hierarchy
	
	var bones = spine_data["bones"]
	
	for bone in bones:
		var bone_name = bone["name"]
		var parent_name = bone.get("parent", "")
		
		if parent_name == "":
			bone_hierarchy[bone_name] = {
				"parent": "",
				"children": [],
				"slots": []
			}
		else:
			if not bone_hierarchy.has(parent_name):
				bone_hierarchy[parent_name] = {
					"parent": "",
					"children": [],
					"slots": []
				}
			
			bone_hierarchy[parent_name]["children"].append(bone_name)
			
			bone_hierarchy[bone_name] = {
				"parent": parent_name,
				"children": [],
				"slots": []
			}
	
	if spine_data.has("slots"):
		var slots = spine_data["slots"]
		for slot in slots:
			var slot_name = slot["name"]
			var bone_name = slot.get("bone", "")
			
			if bone_name != "" and bone_hierarchy.has(bone_name):
				bone_hierarchy[bone_name]["slots"].append(slot_name)
			elif bone_hierarchy.has("root"):
				bone_hierarchy["root"]["slots"].append(slot_name)
	
	return bone_hierarchy

func generate_bone_node_text_precise(bone: Dictionary, parent_path: String, indent: int) -> String:
	var indent_str = "\t".repeat(indent)
	var bone_name = bone.get("name", "")
	
	var node_text = indent_str + "[node name=\"" + bone_name + "\" type=\"Bone2D\" parent=\"" + parent_path + "\"]\n"
	
	var bone_x = bone.get("x", 0.0)
	var bone_y = bone.get("y", 0.0)
	var bone_rotation = bone.get("rotation", 0.0)
	var bone_scale_x = bone.get("scaleX", 1.0)
	var bone_scale_y = bone.get("scaleY", 1.0)
	var bone_length = bone.get("length", 10.0)
	
	if bone_length == 0:
		bone_length = 10.0
	
	var rotation_rad = deg_to_rad(-bone_rotation)
	var cos_rot = cos(rotation_rad)
	var sin_rot = sin(rotation_rad)
	
	var x_axis_x = cos_rot * abs(bone_scale_x)
	var x_axis_y = sin_rot * abs(bone_scale_x)
	var y_axis_x = -sin_rot * abs(bone_scale_y)
	var y_axis_y = cos_rot * abs(bone_scale_y)
	
	if bone_scale_x < 0:
		x_axis_x = -x_axis_x
		x_axis_y = -x_axis_y
	if bone_scale_y < 0:
		y_axis_x = -y_axis_x
		y_axis_y = -y_axis_y
	
	var actual_rotation = atan2(x_axis_y, x_axis_x)
	var final_scale_x = abs(bone_scale_x)
	var final_scale_y = abs(bone_scale_y)
	
	node_text += indent_str + "\tposition = Vector2(" + str(bone_x) + ", " + str(-bone_y) + ")\n"
	node_text += indent_str + "\trotation = " + str(actual_rotation) + "\n"
	node_text += indent_str + "\tscale = Vector2(" + str(final_scale_x) + ", " + str(final_scale_y) + ")\n"
	node_text += indent_str + "\tlength = " + str(bone_length) + "\n"
	node_text += indent_str + "\trest = Transform2D(" + str(x_axis_x) + ", " + str(x_axis_y) + ", " + str(y_axis_x) + ", " + str(y_axis_y) + ", " + str(bone_x) + ", " + str(-bone_y) + ")\n"
	node_text += indent_str + "\n"
	
	return node_text

func find_all_attachments_for_slot(slot_name: String) -> Array:
	var result = []
	
	if not spine_data.has("skins"):
		return result
	
	var skins = spine_data["skins"]
	for skin in skins:
		if skin["name"] == "default":
			var attachments = skin["attachments"]
			
			if attachments.has(slot_name):
				var slot_attachments = attachments[slot_name]
				
				for attachment_name in slot_attachments:
					var attachment = slot_attachments[attachment_name]
					result.append({"name": attachment_name, "data": attachment})
	
	return result

func generate_slot_node_text_precise(slot_name: String, bone_name: String, parent_path: String, indent: int, attachment_names: Array, has_animation: bool = false) -> String:
	var indent_str = "\t".repeat(indent)
	var full_bone_path = parent_path + "/" + bone_name
	
	var node_text = indent_str + "[node name=\"" + slot_name + "\" type=\"Node2D\" parent=\"" + full_bone_path + "\"]\n"
	
	var all_attachments = find_all_attachments_for_slot(slot_name)
	var has_multiple_attachments = all_attachments.size() > 1
	
	if has_multiple_attachments:
		node_text += indent_str + "\tvisible = false\n"
	
	node_text += indent_str + "\n"
	
	for attachment_info in all_attachments:
		var attachment_name = attachment_info["name"]
		var attachment_data = attachment_info["data"]
		
		var texture_name = attachment_name
		if attachment_data.has("path"):
			texture_name = attachment_data["path"]
		
		var texture_id = find_texture_resource_id_for_attachment(texture_name, attachment_names)
		
		var attach_x = attachment_data.get("x", 0.0)
		var attach_y = attachment_data.get("y", 0.0)
		var attach_rotation = attachment_data.get("rotation", 0.0)
		var attach_scale_x = attachment_data.get("scaleX", 1.0)
		var attach_scale_y = attachment_data.get("scaleY", 1.0)
		var attach_width = attachment_data.get("width", 0)
		var attach_height = attachment_data.get("height", 0)
		
		node_text += indent_str + "\t[node name=\"" + attachment_name + "\" type=\"Sprite2D\" parent=\"" + full_bone_path + "/" + slot_name + "\"]\n"
		
		if has_multiple_attachments:
			node_text += indent_str + "\t\tvisible = false\n"
		
		node_text += indent_str + "\t\ttexture = ExtResource(\"" + texture_id + "\")\n"
		node_text += indent_str + "\t\tposition = Vector2(" + str(attach_x) + ", " + str(-attach_y) + ")\n"
		node_text += indent_str + "\t\trotation = " + str(deg_to_rad(-attach_rotation)) + "\n"
		node_text += indent_str + "\t\tscale = Vector2(" + str(attach_scale_x) + ", " + str(attach_scale_y) + ")\n"
		
		if attach_width > 0 and attach_height > 0:
			node_text += indent_str + "\t\tregion_enabled = true\n"
			node_text += indent_str + "\t\tregion_rect = Rect2(0, 0, " + str(attach_width) + ", " + str(attach_height) + ")\n"
		
		node_text += indent_str + "\t\n"
	
	print("🔍 生成插槽节点: " + slot_name + " -> " + bone_name + " (包含 " + str(all_attachments.size()) + " 个附件)")
	
	return node_text

func find_texture_resource_id_for_attachment(attachment_name: String, attachment_names: Array) -> String:
	if attachment_name in attachment_names:
		var index = attachment_names.find(attachment_name)
		return str(index + 1) + "_" + attachment_name
	return "1_" + attachment_name

func generate_bone_hierarchy_text_precise(bone_name: String, bone_hierarchy: Dictionary, parent_path: String, indent: int, attachment_names: Array = [], animated_slots: Dictionary = {}) -> String:
	var node_text = ""
	
	var bone_data = find_bone_by_name(bone_name)
	if bone_data:
		node_text += generate_bone_node_text_precise(bone_data, parent_path, indent)
		
		var bone_info = bone_hierarchy[bone_name]
		for slot_name in bone_info["slots"]:
			node_text += generate_slot_node_text_precise(slot_name, bone_name, parent_path, indent + 1, attachment_names)
		
		for child_bone_name in bone_info["children"]:
			var child_parent_path = parent_path + "/" + bone_name
			node_text += generate_bone_hierarchy_text_precise(child_bone_name, bone_hierarchy, child_parent_path, indent + 1, attachment_names, animated_slots)
	
	return node_text

func find_bone_by_name(bone_name: String) -> Dictionary:
	if not spine_data.has("bones"):
		return {}
	
	var bones = spine_data["bones"]
	for bone in bones:
		if bone["name"] == bone_name:
			return bone
	
	return {}

func deg_to_rad(degrees: float) -> float:
	return degrees * PI / 180.0

func get_animation_names() -> Array:
	var result = []
	if spine_data.has("animations"):
		for anim_name in spine_data["animations"].keys():
			result.append(anim_name)
	return result

func get_animation_events(anim_name: String) -> Array:
	var result = []
	if not spine_data.has("animations"):
		return result
	
	var animations = spine_data["animations"]
	if not animations.has(anim_name):
		return result
	
	var anim_data = animations[anim_name]
	if anim_data.has("events"):
		result = anim_data["events"]
	
	return result

func get_animation_slots(anim_name: String) -> Dictionary:
	var result = {}
	if not spine_data.has("animations"):
		return result
	
	var animations = spine_data["animations"]
	if not animations.has(anim_name):
		return result
	
	var anim_data = animations[anim_name]
	if anim_data.has("slots"):
		result = anim_data["slots"]
	
	return result

func find_slot_path(slot_name: String, bone_list: Array) -> Dictionary:
	var slot_bone = ""
	if spine_data.has("slots"):
		var slots = spine_data["slots"]
		for slot in slots:
			if slot.get("name", "") == slot_name:
				slot_bone = slot.get("bone", "")
				break
	
	if slot_bone.is_empty():
		return {"path": "", "bone_path": ""}
	
	var bone_path = find_bone_path(slot_bone, bone_list)
	var slot_path = bone_path + "/" + slot_name
	
	return {"path": slot_path, "bone_path": bone_path}

func parse_event_parameters(event_string: String) -> Dictionary:
	var params = {}
	if event_string.is_empty():
		return params
	
	var pairs = []
	var current_pair = ""
	var in_quotes = false
	var i = 0
	
	while i < event_string.length():
		var char = event_string[i]
		
		if char == '"':
			in_quotes = !in_quotes
			current_pair += char
		elif char == ',' and not in_quotes:
			pairs.append(current_pair)
			current_pair = ""
		else:
			current_pair += char
		
		i += 1
	
	if not current_pair.is_empty():
		pairs.append(current_pair)
	
	for pair in pairs:
		var eq_pos = pair.find("=")
		if eq_pos > 0:
			var key = pair.substr(0, eq_pos).strip_edges()
			var value = pair.substr(eq_pos + 1).strip_edges()
			if value.begins_with("\"") and value.ends_with("\""):
				value = value.substr(1, value.length() - 2)
			params[key] = value
	
	return params

func parse_animation_data(animation_data: Dictionary) -> Dictionary:
	var parsed = {}
	
	if animation_data.has("bones"):
		for bone_name in animation_data["bones"]:
			var bone_anim = animation_data["bones"][bone_name]
			parsed[bone_name] = bone_anim
	
	return parsed

func calculate_animation_length(animation_bones: Dictionary, animation_slots: Dictionary = {}, animation_events: Array = []) -> float:
	var max_time = 0.0
	
	for bone_name in animation_bones:
		var bone_anim = animation_bones[bone_name]
		
		if bone_anim.has("translate"):
			for track in bone_anim["translate"]:
				if track.has("time"):
					max_time = max(max_time, track["time"])
		
		if bone_anim.has("rotate"):
			for track in bone_anim["rotate"]:
				if track.has("time"):
					max_time = max(max_time, track["time"])
		
		if bone_anim.has("scale"):
			for track in bone_anim["scale"]:
				if track.has("time"):
					max_time = max(max_time, track["time"])
	
	for slot_name in animation_slots:
		var slot_anim = animation_slots[slot_name]
		
		if slot_anim.has("attachment"):
			for track in slot_anim["attachment"]:
				if track.has("time"):
					max_time = max(max_time, track["time"])
		
		if slot_anim.has("color"):
			for track in slot_anim["color"]:
				if track.has("time"):
					max_time = max(max_time, track["time"])
	
	for event in animation_events:
		if event.has("time"):
			max_time = max(max_time, event["time"])
	
	return max_time

func generate_animation_resource_text(anim_name: String, anim_data: Dictionary, bone_list: Array) -> String:
	var slot_anim_data = get_animation_slots(anim_name)
	var events = get_animation_events(anim_name)
	var anim_length = calculate_animation_length(anim_data, slot_anim_data, events)
	
	var resource_text = "[sub_resource type=\"Animation\" id=\"Animation_" + anim_name + "\"]\n"
	resource_text += "resource_name = \"" + anim_name + "\"\n"
	resource_text += "length = " + str(anim_length) + "\n"
	
	var track_index = 0
	
	for bone_name in anim_data:
		var bone_anim = anim_data[bone_name]
		var bone_path = find_bone_path(bone_name, bone_list)
		
		if bone_anim.has("translate"):
			resource_text += generate_translate_track(bone_path, bone_anim["translate"], track_index, bone_name)
			track_index += 1
		
		if bone_anim.has("rotate"):
			resource_text += generate_rotate_track(bone_path, bone_anim["rotate"], track_index, bone_name)
			track_index += 1
		
		if bone_anim.has("scale"):
			resource_text += generate_scale_track(bone_path, bone_anim["scale"], track_index)
			track_index += 1
	
	for slot_name in slot_anim_data:
		var slot_anim = slot_anim_data[slot_name]
		if slot_anim.has("attachment"):
			var slot_path = find_slot_path(slot_name, bone_list)
			var result = generate_slot_attachment_track(slot_path, slot_anim["attachment"], track_index, slot_name)
			resource_text += result["text"]
			track_index = result["track_index"]
	
	if events.size() > 0:
		resource_text += generate_event_track(events, track_index)
		track_index += 1
	
	resource_text += "\n"
	
	return resource_text

func find_bone_path(bone_name: String, bone_list: Array) -> String:
	var bone_hierarchy = build_bone_hierarchy_precise()
	var path_parts = []
	var current_bone = bone_name
	
	while current_bone != "":
		path_parts.push_front(current_bone)
		if bone_hierarchy.has(current_bone):
			current_bone = bone_hierarchy[current_bone]["parent"]
		else:
			current_bone = ""
	
	return "VisualContainer/Skeleton2D/" + "/".join(path_parts)

func generate_translate_track(bone_path: String, tracks: Array, track_index: int, bone_name: String) -> String:
	var track_text = "tracks/" + str(track_index) + "/type = \"value\"\n"
	track_text += "tracks/" + str(track_index) + "/imported = false\n"
	track_text += "tracks/" + str(track_index) + "/enabled = true\n"
	track_text += "tracks/" + str(track_index) + "/path = NodePath(\"" + bone_path + ":position\")\n"
	track_text += "tracks/" + str(track_index) + "/interp = 1\n"
	track_text += "tracks/" + str(track_index) + "/loop_wrap = true\n"
	track_text += "tracks/" + str(track_index) + "/keys = {\n"
	
	var bone_data = find_bone_by_name(bone_name)
	var bone_x = bone_data.get("x", 0.0) if bone_data else 0.0
	var bone_y = bone_data.get("y", 0.0) if bone_data else 0.0
	
	var times = []
	var values = []
	var transitions = []
	
	for track in tracks:
		var time = track.get("time", 0.0)
		var anim_x = track.get("x", 0.0)
		var anim_y = track.get("y", 0.0)
		
		var abs_x = bone_x + anim_x
		var abs_y = bone_y + anim_y
		
		times.append(str(time))
		values.append("Vector2(" + str(abs_x) + ", " + str(-abs_y) + ")")
		transitions.append("1")
	
	track_text += "\"times\": PackedFloat32Array(" + ", ".join(times) + "),\n"
	track_text += "\"transitions\": PackedFloat32Array(" + ", ".join(transitions) + "),\n"
	track_text += "\"update\": 0,\n"
	track_text += "\"values\": [" + ", ".join(values) + "]\n"
	track_text += "}\n"
	
	return track_text

func generate_rotate_track(bone_path: String, tracks: Array, track_index: int, bone_name: String) -> String:
	var track_text = "tracks/" + str(track_index) + "/type = \"value\"\n"
	track_text += "tracks/" + str(track_index) + "/imported = false\n"
	track_text += "tracks/" + str(track_index) + "/enabled = true\n"
	track_text += "tracks/" + str(track_index) + "/path = NodePath(\"" + bone_path + ":rotation\")\n"
	track_text += "tracks/" + str(track_index) + "/interp = 1\n"
	track_text += "tracks/" + str(track_index) + "/loop_wrap = true\n"
	track_text += "tracks/" + str(track_index) + "/keys = {\n"
	
	var bone_data = find_bone_by_name(bone_name)
	var base_rotation = bone_data.get("rotation", 0.0) if bone_data else 0.0
	
	var times = []
	var values = []
	var transitions = []
	
	for track in tracks:
		var time = track.get("time", 0.0)
		var anim_angle = track.get("angle", 0.0)
		
		var total_rotation = base_rotation + anim_angle
		var total_rotation_rad = deg_to_rad(-total_rotation)
		
		times.append(str(time))
		values.append(str(total_rotation_rad))
		transitions.append("1")
	
	track_text += "\"times\": PackedFloat32Array(" + ", ".join(times) + "),\n"
	track_text += "\"transitions\": PackedFloat32Array(" + ", ".join(transitions) + "),\n"
	track_text += "\"update\": 0,\n"
	track_text += "\"values\": PackedFloat32Array(" + ", ".join(values) + ")\n"
	track_text += "}\n"
	
	return track_text

func generate_scale_track(bone_path: String, tracks: Array, track_index: int) -> String:
	var track_text = "tracks/" + str(track_index) + "/type = \"value\"\n"
	track_text += "tracks/" + str(track_index) + "/imported = false\n"
	track_text += "tracks/" + str(track_index) + "/enabled = true\n"
	track_text += "tracks/" + str(track_index) + "/path = NodePath(\"" + bone_path + ":scale\")\n"
	track_text += "tracks/" + str(track_index) + "/interp = 1\n"
	track_text += "tracks/" + str(track_index) + "/loop_wrap = true\n"
	track_text += "tracks/" + str(track_index) + "/keys = {\n"
	
	var times = []
	var values = []
	var transitions = []
	
	for track in tracks:
		var time = track.get("time", 0.0)
		var scale_x = track.get("x", 1.0)
		var scale_y = track.get("y", 1.0)
		
		times.append(str(time))
		values.append("Vector2(" + str(scale_x) + ", " + str(scale_y) + ")")
		transitions.append("1")
	
	track_text += "\"times\": PackedFloat32Array(" + ", ".join(times) + "),\n"
	track_text += "\"transitions\": PackedFloat32Array(" + ", ".join(transitions) + "),\n"
	track_text += "\"update\": 0,\n"
	track_text += "\"values\": [" + ", ".join(values) + "]\n"
	track_text += "}\n"
	
	return track_text

func generate_event_track(events: Array, track_index: int) -> String:
	var track_text = "tracks/" + str(track_index) + "/type = \"method\"\n"
	track_text += "tracks/" + str(track_index) + "/imported = false\n"
	track_text += "tracks/" + str(track_index) + "/enabled = true\n"
	track_text += "tracks/" + str(track_index) + "/path = NodePath(\".\")\n"
	track_text += "tracks/" + str(track_index) + "/keys = {\n"
	
	var times = []
	var values = []
	
	for event in events:
		var time = event.get("time", 0.0)
		var event_name = event.get("name", "")
		var event_string = event.get("string", "")
		
		var params = parse_event_parameters(event_string)
		
		var args = ["event_name", event_name]
		for key in params:
			var value = params[key]
			args.append(key)
			args.append(value)
		
		var call_value = "{\"method\": &\"handle_event\", \"args\": ["
		for i in range(args.size()):
			if i > 0:
				call_value += ", "
			var arg = args[i]
			if typeof(arg) == TYPE_STRING:
				call_value += "\"" + arg + "\""
			else:
				call_value += str(arg)
		call_value += "]}"
		
		times.append(str(time))
		values.append(call_value)
	
	track_text += "\"times\": PackedFloat32Array(" + ", ".join(times) + "),\n"
	track_text += "\"values\": [" + ", ".join(values) + "]\n"
	track_text += "}\n"
	
	return track_text

func generate_slot_attachment_track(slot_path_dict: Dictionary, attachment_tracks: Array, track_index: int, slot_name: String) -> Dictionary:
	var slot_path = slot_path_dict.get("path", "")
	if slot_path.is_empty():
		return {"text": "", "track_index": track_index}
	
	var all_attachments = find_all_attachments_for_slot(slot_name)
	if all_attachments.is_empty():
		return {"text": "", "track_index": track_index}
	
	var track_text = ""
	
	var attachment_map = {}
	for attachment_info in all_attachments:
		var attachment_name = attachment_info["name"]
		attachment_map[attachment_name] = {"times": ["0.0"], "values": ["false"]}
	
	var current_attachment = ""
	var last_time = -1.0
	
	for track in attachment_tracks:
		var time = track.get("time", 0.0)
		var name = track.get("name", "")
		
		if name != null:
			current_attachment = name
		else:
			current_attachment = ""
		
		if time != last_time:
			for attachment_name in attachment_map:
				if current_attachment == attachment_name:
					attachment_map[attachment_name]["times"].append(str(time))
					attachment_map[attachment_name]["values"].append("true")
				else:
					attachment_map[attachment_name]["times"].append(str(time))
					attachment_map[attachment_name]["values"].append("false")
			
			last_time = time
	
	var first_attachment = all_attachments[0]["name"]
	var slot_visible_times = ["0.0"]
	var slot_visible_values = ["false"]
	
	for track in attachment_tracks:
		var time = track.get("time", 0.0)
		var name = track.get("name", "")
		
		if name != null:
			slot_visible_times.append(str(time))
			slot_visible_values.append("true")
		else:
			if slot_visible_times.size() > 0 and slot_visible_times[slot_visible_times.size() - 1] == str(time):
				slot_visible_values[slot_visible_values.size() - 1] = "false"
			else:
				slot_visible_times.append(str(time))
				slot_visible_values.append("false")
	
	if slot_visible_times.size() > 0:
		var transitions = []
		for i in range(slot_visible_times.size()):
			transitions.append("1")
		
		track_text += "tracks/" + str(track_index) + "/type = \"value\"\n"
		track_text += "tracks/" + str(track_index) + "/imported = false\n"
		track_text += "tracks/" + str(track_index) + "/enabled = true\n"
		track_text += "tracks/" + str(track_index) + "/path = NodePath(\"" + slot_path + ":visible\")\n"
		track_text += "tracks/" + str(track_index) + "/interp = 0\n"
		track_text += "tracks/" + str(track_index) + "/loop_wrap = true\n"
		track_text += "tracks/" + str(track_index) + "/keys = {\n"
		track_text += "\"times\": PackedFloat32Array(" + ", ".join(slot_visible_times) + "),\n"
		track_text += "\"transitions\": PackedFloat32Array(" + ", ".join(transitions) + "),\n"
		track_text += "\"update\": 0,\n"
		track_text += "\"values\": [" + ", ".join(slot_visible_values) + "]\n"
		track_text += "}\n"
		track_index += 1
	
	for attachment_name in attachment_map:
		var times = attachment_map[attachment_name]["times"]
		var values = attachment_map[attachment_name]["values"]
		
		if times.size() > 0:
			var transitions = []
			for i in range(times.size()):
				transitions.append("1")
			
			var attachment_path = slot_path + "/" + attachment_name
			
			track_text += "tracks/" + str(track_index) + "/type = \"value\"\n"
			track_text += "tracks/" + str(track_index) + "/imported = false\n"
			track_text += "tracks/" + str(track_index) + "/enabled = true\n"
			track_text += "tracks/" + str(track_index) + "/path = NodePath(\"" + attachment_path + ":visible\")\n"
			track_text += "tracks/" + str(track_index) + "/interp = 0\n"
			track_text += "tracks/" + str(track_index) + "/loop_wrap = true\n"
			track_text += "tracks/" + str(track_index) + "/keys = {\n"
			track_text += "\"times\": PackedFloat32Array(" + ", ".join(times) + "),\n"
			track_text += "\"transitions\": PackedFloat32Array(" + ", ".join(transitions) + "),\n"
			track_text += "\"update\": 0,\n"
			track_text += "\"values\": [" + ", ".join(values) + "]\n"
			track_text += "}\n"
			track_index += 1
	
	return {"text": track_text, "track_index": track_index}

func generate_animation_library_text(animations: Dictionary, bone_list: Array) -> String:
	var lib_text = "[node name=\"AnimationPlayer\" type=\"AnimationPlayer\" parent=\".\"]\n"
	lib_text += "libraries = {\n"
	lib_text += "SubResource(\"AnimationLibrary_1\"): SubResource(\"AnimationLibrary_1\")\n"
	lib_text += "}\n\n"
	
	lib_text += "[sub_resource type=\"AnimationLibrary\" id=\"AnimationLibrary_1\"]\n"
	lib_text += "data = {\n"
	
	var first = true
	for anim_name in animations:
		if not first:
			lib_text += ",\n"
		lib_text += "&\"" + anim_name + "\": SubResource(\"Animation_" + anim_name + "\")"
		first = false
	
	lib_text += "\n}\n\n"
	
	return lib_text

func convert_spine38_to_godot(spine_json_path: String, output_scene_path: String) -> bool:
	print("=== Spine 3.8精确层级转换器 ===")
	print("====================================")
	
	var file = FileAccess.open(spine_json_path, FileAccess.READ)
	if file == null:
		print("❌ 无法打开JSON文件: " + spine_json_path)
		return false
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	if parse_result != OK:
		print("❌ JSON解析失败: " + json.get_error_message())
		return false
	
	spine_data = json.get_data()
	
	print("✅ 成功加载Spine JSON文件")
	
	if spine_data.has("bones"):
		print("骨骼数量: " + str(spine_data["bones"].size()))
	
	if spine_data.has("slots"):
		print("插槽数量: " + str(spine_data["slots"].size()))
	
	if spine_data.has("animations"):
		print("动画数量: " + str(spine_data["animations"].size()))
	
	var bone_hierarchy = build_bone_hierarchy_precise()
	print("🔍 构建的骨骼层级数量: " + str(bone_hierarchy.size()))
	
	var scene_text = generate_scene_text_precise(bone_hierarchy, spine_json_path)
	
	var output_file = FileAccess.open(output_scene_path, FileAccess.WRITE)
	if output_file == null:
		print("❌ 无法创建输出文件: " + output_scene_path)
		return false
	
	output_file.store_string(scene_text)
	output_file.close()
	
	print("\n✅ 成功创建Godot骨骼场景: " + output_scene_path)
	print("📊 修复内容:")
	print("   ✅ 精确构建骨骼层级关系")
	print("   ✅ 每个插槽包含所有附件贴图")
	print("   ✅ 添加动画转换功能")
	print("   ✅ 添加事件系统支持")
	
	return true

func generate_scene_text_precise(bone_hierarchy: Dictionary, json_file_path: String) -> String:
	var scene_text = ""
	
	var image_path = config.get("image_path", "")
	
	if image_path == "":
		var json_dir = json_file_path.get_base_dir()
		image_path = json_dir + "/images/"
		print("🔍 自动检测图片目录: " + image_path)
	
	var texture_id = 1
	var texture_resources = ""
	
	var attachment_names = []
	if spine_data.has("skins"):
		var skins = spine_data["skins"]
		for skin in skins:
			if skin.has("attachments"):
				var attachments = skin["attachments"]
				for slot_name in attachments:
					var slot_attachments = attachments[slot_name]
					for attachment_name in slot_attachments:
						var attachment = slot_attachments[attachment_name]
						var texture_name = attachment_name
						if attachment.has("path"):
							texture_name = attachment["path"]
						if not texture_name in attachment_names:
							attachment_names.append(texture_name)
	
	var load_steps = 2
	var animations = {}
	if spine_data.has("animations"):
		animations = spine_data["animations"]
		load_steps += animations.size() + 1
	
	var has_events = false
	for anim_name in animations:
		var events = get_animation_events(anim_name)
		if events.size() > 0:
			has_events = true
			break
	
	if has_events:
		load_steps += 1
	
	scene_text += "[gd_scene load_steps=" + str(load_steps) + " format=3]\n\n"
	
	for attachment_name in attachment_names:
		var texture_path = image_path + attachment_name + ".png"
		texture_resources += "[ext_resource type=\"Texture2D\" path=\"" + texture_path + "\" id=\"" + str(texture_id) + "_" + attachment_name + "\"]\n"
		texture_id += 1
	
	if has_events:
		texture_resources += "[ext_resource type=\"Script\" path=\"res://addons/spine38_to_godot_converter/spine_event_handler.gd\" id=\"EventHandler\"]\n"
	
	scene_text += texture_resources
	scene_text += "\n"
	
	var bone_list = []
	if spine_data.has("bones"):
		for bone in spine_data["bones"]:
			bone_list.append(bone["name"])
	
	var animated_slots = {}
	for anim_name in animations:
		var slot_anim_data = get_animation_slots(anim_name)
		for slot_name in slot_anim_data:
			if slot_anim_data[slot_name].has("attachment"):
				animated_slots[slot_name] = true
	
	for anim_name in animations:
		var anim_data = parse_animation_data(animations[anim_name])
		scene_text += generate_animation_resource_text(anim_name, anim_data, bone_list)
	
	scene_text += "[sub_resource type=\"AnimationLibrary\" id=\"AnimationLibrary_1\"]\n"
	scene_text += "_data = {\n"
	var first = true
	for anim_name in animations:
		if not first:
			scene_text += ",\n"
		scene_text += "&\"" + anim_name + "\": SubResource(\"Animation_" + anim_name + "\")"
		first = false
	scene_text += ",\n}\n\n"
	
	scene_text += "[node name=\"agnis_spine38_precise\" type=\"Node2D\"]\n\n"
	
	scene_text += "[node name=\"VisualContainer\" type=\"Node2D\" parent=\".\"]\n\n"
	
	scene_text += "[node name=\"Skeleton2D\" type=\"Skeleton2D\" parent=\"VisualContainer\"]\n\n"
	
	scene_text += generate_bone_hierarchy_text_precise("root", bone_hierarchy, "VisualContainer/Skeleton2D", 0, attachment_names, animated_slots)
	
	if has_events:
		scene_text += "[node name=\"EventHandler\" type=\"Node2D\" parent=\".\"]\n"
		scene_text += "script = ExtResource(\"EventHandler\")\n\n"
	
	scene_text += "[node name=\"AnimationPlayer\" type=\"AnimationPlayer\" parent=\".\"]\n"
	scene_text += "libraries = {\n"
	scene_text += "SubResource(\"AnimationLibrary_1\"): SubResource(\"AnimationLibrary_1\")\n"
	scene_text += "}\n"
	
	return scene_text

func set_config(new_config: Dictionary):
	config = new_config

func get_config() -> Dictionary:
	return config.duplicate()
