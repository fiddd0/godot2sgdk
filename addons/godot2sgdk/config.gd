@tool
extends RefCounted

const CONFIG_PATH = "res://addons/godot2sgdk/plugin_config.cfg"

var settings = {
	"general": {
		"export_path": "res://export/",
		"sgdk_project_path": "../sgdk_project/",
		"auto_validate": true,
		"generate_metatiles": true
	},
	"graphics": {
		"default_palette": "megadrive",
		"optimize_tiles": true,
		"max_colors_per_palette": 16,
		"max_palettes": 4
	},
	"export": {
		"generate_headers": true,
		"generate_binaries": false,
		"compress_data": true
	}
}

func load_config() -> void:
	var config_file = ConfigFile.new()
	var err = config_file.load(CONFIG_PATH)
	
	if err == OK:
		for section in settings:
			for key in settings[section]:
				if config_file.has_section_key(section, key):
					settings[section][key] = config_file.get_value(section, key)

func save_config() -> void:
	var config_file = ConfigFile.new()
	
	for section in settings:
		for key in settings[section]:
			config_file.set_value(section, key, settings[section][key])
	
	config_file.save(CONFIG_PATH)

func get_setting(section: String, key: String):
	if settings.has(section) and settings[section].has(key):
		return settings[section][key]
	return null

func set_setting(section: String, key: String, value) -> void:
	if settings.has(section) and settings[section].has(key):
		settings[section][key] = value
