@tool
extends RefCounted

const CONFIG_PATH = "res://addons/godot2sgdk/config.cfg"

static func save_palette_config(colors: Array):
	var config = ConfigFile.new()
	
	for i in range(colors.size()):
		if i < 16:
			config.set_value("palette", "color_%d" % i, colors[i])
	
	config.save(CONFIG_PATH)

static func load_palette_config() -> Array:
	var config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	
	var colors = []
	if err == OK:
		for i in range(16):
			var color = config.get_value("palette", "color_%d" % i, Color(0, 0, 0))
			colors.append(color)
	
	return colors
