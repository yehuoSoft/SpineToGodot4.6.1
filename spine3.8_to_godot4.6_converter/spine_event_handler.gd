extends Node2D

class_name SpineEventHandler

signal event_triggered(event_name: String, params: Dictionary)

var audio_player: AudioStreamPlayer2D
var effect_container: Node2D

func _ready():
	setup_audio_player()
	setup_effect_container()

func setup_audio_player():
	audio_player = AudioStreamPlayer2D.new()
	audio_player.name = "AudioPlayer"
	add_child(audio_player)

func setup_effect_container():
	effect_container = Node2D.new()
	effect_container.name = "EffectContainer"
	add_child(effect_container)

func handle_event(args: Array):
	if args.is_empty():
		return
	
	var event_name = args[0]
	var params = {}
	
	if args.size() > 1:
		for i in range(1, args.size(), 2):
			if i + 1 < args.size():
				var key = args[i]
				var value = args[i + 1]
				params[key] = value
	
	match event_name:
		"onSound":
			_handle_sound_event(params)
		"onAtk":
			_handle_attack_event(params)
		"onLoadHitAni":
			_handle_load_hit_animation_event(params)
		"onLoadTargetAni":
			_handle_load_target_animation_event(params)
		"onLoadCastAni":
			_handle_load_cast_animation_event(params)
		"onLight":
			_handle_light_event(params)
		"onEnd":
			_handle_end_event(params)
		_:
			_handle_custom_event(event_name, params)
	
	event_triggered.emit(event_name, params)

func parse_params_string(params_str: String) -> Dictionary:
	var params = {}
	if params_str.is_empty():
		return params
	
	var pairs = params_str.split(",", false)
	for pair in pairs:
		var parts = pair.split("=", false)
		if parts.size() == 2:
			var key = parts[0].strip_edges()
			var value = parts[1].strip_edges()
			if value.begins_with("\"") and value.ends_with("\""):
				value = value.substr(1, value.length() - 2)
			params[key] = value
	
	return params

func _handle_sound_event(params: Dictionary):
	if params.is_empty():
		return
	
	var sound_name = params.get("sound_name", "")
	if sound_name.is_empty():
		sound_name = params.get("name", "")
	
	if sound_name.is_empty():
		return
	
	play_sound(sound_name)

func _handle_attack_event(params: Dictionary):
	var rate = params.get("rate", "1.0")
	var x = params.get("x", "0")
	var y = params.get("y", "0")
	var shake = params.get("shake", "0")
	
	print("Attack event - rate: %s, x: %s, y: %s, shake: %s" % [rate, x, y, shake])
	
	if shake != "0":
		trigger_shake(int(shake))

func _handle_load_hit_animation_event(params: Dictionary):
	var path = params.get("path", "")
	var z_index_type = params.get("zIndexType", "0")
	
	print("Load hit animation - path: %s, zIndexType: %s" % [path, z_index_type])

func _handle_load_target_animation_event(params: Dictionary):
	var path = params.get("path", "")
	
	print("Load target animation - path: %s" % [path])

func _handle_load_cast_animation_event(params: Dictionary):
	var path = params.get("path", "")
	
	print("Load cast animation - path: %s" % [path])

func _handle_light_event(params: Dictionary):
	var visible = params.get("visible", "true")
	var color = params.get("color", "#FFFFFF")
	
	print("Light event - visible: %s, color: %s" % [visible, color])

func _handle_end_event(params: Dictionary):
	print("Animation ended")

func _handle_custom_event(event_name: String, params: Dictionary):
	print("Custom event: %s, params: %s" % [event_name, params])

func play_sound(sound_name: String):
	if not audio_player:
		return
	
	var sound_path = "res://assets/sounds/" + sound_name + ".ogg"
	if ResourceLoader.exists(sound_path):
		var sound = load(sound_path)
		if sound:
			audio_player.stream = sound
			audio_player.play()
			print("Playing sound: %s" % [sound_name])
		else:
			print("Failed to load sound: %s" % [sound_name])
	else:
		print("Sound file not found: %s" % [sound_path])

func trigger_shake(intensity: int):
	print("Triggering camera shake with intensity: %d" % [intensity])

func create_effect(effect_name: String, position: Vector2 = Vector2.ZERO):
	var effect = Node2D.new()
	effect.name = effect_name
	effect.position = position
	effect_container.add_child(effect)
	
	print("Created effect: %s at position: %s" % [effect_name, position])
	
	return effect

func clear_effects():
	for child in effect_container.get_children():
		child.queue_free()
