@tool
extends RefCounted
class_name ConfigManager

const CONFIG_PATH = "res://addons/godot2sgdk/godot2sgdk.cfg"
const DEFAULT_SETTINGS = {
	"general": {
		"export_path": "res://export/",
		"auto_validate": true,
		"auto_save": false,
		"log_level": "normal"  # normal, verbose, minimal
	},
	"performance": {
		"multithreading": true,
		"compression_level": 1,  # 0-3
		"cache_size": 100,  # MB
		"max_memory_usage": 500  # MB
	},
	"sgdk": {
		"output_format": "c_header",  # c_header, binary, json
		"generate_makefile": true,
		"optimize_for_size": false,
		"palette_mode": "indexed"  # indexed, rgb, both
	},
	"mobile": {
		"touch_friendly": true,
		"large_buttons": true,
		"auto_rotate": false,
		"performance_mode": true
	}
}

var config: ConfigFile

func _init():
	config = ConfigFile.new()
	_load_or_create_config()

func _load_or_create_config() -> void:
	var err = config.load(CONFIG_PATH)
	if err != OK:
		print("Creating new config file...")
		_set_default_settings()
		save_config()

func _set_default_settings():
	for section in DEFAULT_SETTINGS:
		for key in DEFAULT_SETTINGS[section]:
			config.set_value(section, key, DEFAULT_SETTINGS[section][key])

func save_config() -> bool:
	var err = config.save(CONFIG_PATH)
	if err == OK:
		print("Config saved successfully")
		return true
	else:
		print("Error saving config: ", err)
		return false

func get_setting(section: String, key: String, default = null):
	if config.has_section_key(section, key):
		return config.get_value(section, key, default)
	return default

func set_setting(section: String, key: String, value) -> void:
	config.set_value(section, key, value)

func get_all_settings() -> Dictionary:
	var settings = {}
	for section in config.get_sections():
		settings[section] = {}
		for key in config.get_section_keys(section):
			settings[section][key] = config.get_value(section, key)
	return settings

func reset_to_defaults() -> void:
	config = ConfigFile.new()
	_set_default_settings()
	save_config()
	print("Config reset to defaults")

# Validações específicas
func validate_export_path(path: String) -> bool:
	return path.is_absolute_path() or path.begins_with("res://")

func validate_memory_value(value: int) -> bool:
	return value >= 10 and value <= 4096  # 10MB to 4GB
