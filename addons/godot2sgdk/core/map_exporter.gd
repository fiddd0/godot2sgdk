@tool

extends RefCounted
class_name MapExporter

var processor
var formatter

func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
	# Apenas para debug - mostrar que foi chamado
	print("🔧 [MapExporter] _export_begin called - Auto-export disabled for manual control")
	# Não fazer auto-export - vamos controlar manualmente via UI

# ADICIONE ESTE MÉTODO PARA EXPORTAÇÃO MANUAL
func export_scene_manually(scene_root: Node) -> void:
	print("🚀 [MapExporter] Starting MANUAL export...")
	
	if scene_root == null:
		print("❌ [MapExporter] No scene root to export")
		return
	
	# Inicializar processadores
	processor = load("res://addons/godot2sgdk/core/tile_processor.gd")
	formatter = load("res://addons/godot2sgdk/utils/sgdk_formatter.gd")
	
	if processor == null:
		print("❌ [MapExporter] Processor script not found")
		return
	
	if formatter == null:
		print("❌ [MapExporter] Formatter script not found")
		return
	
	# Garantir que o diretório de exportação existe
	var export_utils = load("res://addons/godot2sgdk/utils/export_utils.gd")
	if export_utils:
		export_utils.ensure_export_directory()
		print("✅ [MapExporter] Export directory ready")
	else:
		print("❌ [MapExporter] Export utilities not found")
		return
	
	# Encontrar todos os TileMaps na cena
	var tilemaps = _find_tilemaps_in_node(scene_root)
	print("📊 [MapExporter] Found ", tilemaps.size(), " tilemaps")
	
	if tilemaps.size() == 0:
		print("⚠️ [MapExporter] No tilemaps found in scene")
		return
	
	# Exportar cada tilemap
	for i in range(tilemaps.size()):
		var tilemap = tilemaps[i]
		print("🎯 [MapExporter] Exporting tilemap ", i + 1, "/", tilemaps.size(), ": ", tilemap.name)
		_export_tilemap(tilemap, scene_root.name.to_lower())
	
	print("✅ [MapExporter] Manual export completed!")

func _find_tilemaps_in_node(node: Node) -> Array:
	var tilemaps = []
	
	if node is TileMap:
		tilemaps.append(node)
		print("   📍 Found TileMap: ", node.name)
	
	for child in node.get_children():
		tilemaps.append_array(_find_tilemaps_in_node(child))
	
	return tilemaps

func _export_tilemap(tilemap: TileMap, base_name: String) -> void:
	print("   🛠️ Processing tilemap: ", tilemap.name)
	
	# Criar instância do processador (RefCounted - Godot gerencia automaticamente)
	var processor_instance = processor.new()
	if processor_instance:
		# Processar dados do tilemap
		var processed_data = processor_instance.process_tilemap(tilemap)
		print("   ✅ Tilemap processed: ", processed_data.size(), " layers")
		
		# Gerar arquivos de saída
		_generate_output_files(tilemap.name, processed_data, base_name)
		# processor_instance.free()  # ✅ REMOVIDO - Godot gerencia RefCounted
	else:
		print("   ❌ Failed to create processor instance")

func _generate_output_files(tilemap_name: String, data: Dictionary, base_name: String) -> void:
	var export_utils = load("res://addons/godot2sgdk/utils/export_utils.gd")
	if export_utils == null:
		print("   ❌ Export utils not available")
		return
		
	var export_utils_instance = export_utils.new()
	var sanitized_name = export_utils_instance.sanitize_name(tilemap_name)
	var export_path = "res://export/%s_%s" % [base_name, sanitized_name]
		
	# Criar instância do formatador (RefCounted - Godot gerencia automaticamente)
	var formatter_instance = formatter.new()
	if formatter_instance:
		# Gerar header principal se houver dados
		if not data.get("layer_data", {}).is_empty():
			var first_layer_key = data["layer_data"].keys()[0]
			var first_layer = data["layer_data"][first_layer_key]
			 
			print("   📝 Generating header for: ", sanitized_name)
			print("   📏 Layer size: ", first_layer.get("width", 0), "x", first_layer.get("height", 0))
			
			var header_content = formatter_instance.generate_header({
				"map_name": sanitized_name,
				"width": first_layer.get("width", 0),
				"height": first_layer.get("height", 0),
				"data": _format_tile_data(first_layer.get("tiles", []))
			})
			
			_save_file(export_path + ".h", header_content)
		else:
			print("   ⚠️ No layer data to export")
	
		# formatter_instance.free()  # ✅ REMOVIDO - Godot gerencia RefCounted
	else:
		print("   ❌ Failed to create formatter instance")

func _format_tile_data(tiles: Array) -> String:
	var output = ""
	
	if tiles.is_empty():
		print("   ⚠️ No tile data to format")
		return "    // Empty tilemap\n"
	
	for y in range(tiles.size()):
		output += "    "
		for x in range(tiles[y].size()):
			var tile_value = tiles[y][x]
			if tile_value is int:
				output += "0x%04X, " % tile_value
			else:
				output += "0x0000, "  # Valor padrão para tiles inválidos
		output += "\n"
	
	print("   ✅ Formatted ", tiles.size(), " rows of tile data")
	return output

func _save_file(path: String, content: String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(content)
		file.close()
		print("   💾 Saved: ", path)
		
		# Verificar se o arquivo realmente foi criado
		if FileAccess.file_exists(path):
			print("   ✅ File verified: ", path)
		else:
			print("   ❌ File not found after saving: ", path)
	else:
		print("   ❌ Failed to save file: ", path)
		print("   💡 Error: ", FileAccess.get_open_error())
