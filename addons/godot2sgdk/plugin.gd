@tool
extends EditorPlugin

var main_dock


func _enter_tree():	
	# Interface principal (RefCounted - gerenciado automaticamente)
	var main_dock_script = load("res://addons/godot2sgdk/ui/main_dock.gd")
	if main_dock_script:
		main_dock = main_dock_script.new()
		main_dock.plugin = self
		add_control_to_dock(DOCK_SLOT_RIGHT_BL, main_dock)
		# Inicializar
		main_dock.initialize()  # ✅ CORRIGIDO
		
		print("Godot2SGDK Plugin loaded successfully!")
	else:
		push_error("Failed to load main_dock.gd")
			
	# Exportadores (RefCounted - gerenciado automaticamente)
	var map_exporter_script = load("res://addons/godot2sgdk/core/map_exporter.gd")
	if map_exporter_script:
		add_export_plugin(map_exporter_script.new())
	
	print("Godot2SGDK Plugin loaded successfully!")

func _exit_tree():
	# Remover interfaces
	if main_dock:
		remove_control_from_docks(main_dock)
		main_dock.free()
		print("Godot2SGDK Plugin unloaded!")
