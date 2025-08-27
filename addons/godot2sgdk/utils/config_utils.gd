@tool
extends RefCounted

const CONFIG_PATH = "res://addons/godot2sgdk/config.cfg"

static func save_palette_config(colors: Array) -> bool:
	var config = ConfigFile.new()
	
	# Carregar config existente primeiro
	var err = config.load(CONFIG_PATH)
	if err != OK:
		config = ConfigFile.new()
	
	for i in range(colors.size()):
		if i < 16:
			config.set_value("palette", "color_%d" % i, colors[i])
	
	return config.save(CONFIG_PATH) == OK

static func load_palette_config() -> Array:
	var config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	
	var colors = []
	if err == OK:
		for i in range(16):
			var color = config.get_value("palette", "color_%d" % i, Color(0, 0, 0))
			colors.append(color)
	else:
		# Paleta padrão se não existir config - CORREÇÃO AQUI
		var palette_manager = load("res://addons/godot2sgdk/core/palette_manager.gd")
		if palette_manager:
			var default_palette = palette_manager.DEFAULT_PALETTE  # ✅ CORRIGIDO
			colors = default_palette.duplicate()
	
	return colors

static func get_export_path() -> String:
	var config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	if err == OK:
		return config.get_value("export", "base_path", "res://export/")
	return "res://export/"

static func set_export_path(path: String) -> bool:
	var config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	if err != OK:
		config = ConfigFile.new()
	
	config.set_value("export", "base_path", path)
	return config.save(CONFIG_PATH) == OK
