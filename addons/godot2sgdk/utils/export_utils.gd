@tool
extends RefCounted

static func ensure_export_directory():
	var dir = DirAccess.open("res://")
	if dir:
		if not dir.dir_exists("res://export"):
			dir.make_dir("res://export")

static func sanitize_name(name: String) -> String:
	var invalid_chars = " -.,:;!?/\\()[]{}@#$%^&*+=|~<>\"'"
	var result = name
	for char in invalid_chars:
		result = result.replace(char, "_")
	return result.to_lower()

static func color_to_hex(color: Color) -> String:
	return "#%02X%02X%02X" % [
		int(color.r * 255),
		int(color.g * 255),
		int(color.b * 255)
	]

static func ensure_sgdk_directory(path: String) -> bool:
	var dir = DirAccess.open(path)
	if dir:
		return dir.dir_exists(path)
	return false
