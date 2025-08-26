@tool
extends RefCounted

const MD_LIMITS = {
	"max_tiles": 1024,
	"max_sprites_per_line": 80,
	"max_palettes": 4,
	"colors_per_palette": 16,
	"vram_size": 65536,
	"max_tilemap_size": 4096
}

# Mudar para função estática para facilitar acesso
static func validate_scene_static(scene_root: Node) -> Array:
	var validator = load("res://addons/godot2sgdk/utils/validation_utils.gd")
	if validator:
		var validator_instance = validator.new()
		var result = validator_instance.validate_scene(scene_root)
		return result
	return []  # Retorna array vazio genérico

# CORREÇÃO: Remover a tipagem específica para evitar conflitos
func validate_scene(scene_root: Node) -> Array:
	var issues = []  # Array genérico
	
	if scene_root:
		issues.append_array(_validate_tilemaps(scene_root))
		issues.append_array(_validate_sprites(scene_root))
		issues.append_array(_validate_palettes(scene_root))
	
	return issues

# CORREÇÃO: Remover tipagem específica
func _validate_tilemaps(root: Node) -> Array:
	var issues = []  # Array genérico
	var tilemaps = _find_nodes_of_type(root, "TileMap")
	
	for tilemap in tilemaps:
		var unique_tiles = _count_unique_tiles(tilemap)
		if unique_tiles > MD_LIMITS.max_tiles:
			issues.append({
				"type": "error",
				"message": "Too many unique tiles: %d/%d" % [unique_tiles, MD_LIMITS.max_tiles],
				"node": tilemap,
				"fix": "Use metatiles or reduce tile variety"
			})
		
		var bounds = _get_tilemap_bounds(tilemap)
		if bounds.size.x * bounds.size.y > MD_LIMITS.max_tilemap_size:
			issues.append({
				"type": "warning",
				"message": "Large tilemap: %d tiles (max recommended: %d)" % [
					bounds.size.x * bounds.size.y, MD_LIMITS.max_tilemap_size
				],
				"node": tilemap
			})
	
	return issues

# CORREÇÃO: Remover tipagem específica
func _validate_sprites(root: Node) -> Array:
	var issues = []  # Array genérico
	var sprites = _find_nodes_of_type(root, "Sprite2D")
	
	for sprite in sprites:
		if sprite.texture:
			var texture_size = sprite.texture.get_size()
			if texture_size.x > 64 or texture_size.y > 64:
				issues.append({
					"type": "warning",
					"message": "Large sprite: %.0fx%.0f (max 64x64 recommended)" % [texture_size.x, texture_size.y],
					"node": sprite
				})
	
	return issues

# CORREÇÃO: Remover tipagem específica
func _validate_palettes(root: Node) -> Array:
	# TODO: Implementar validação de paletas
	return []  # Array genérico

func _find_nodes_of_type(root: Node, type: String) -> Array:
	var nodes = []
	if root.get_class() == type:
		nodes.append(root)
	
	for child in root.get_children():
		nodes.append_array(_find_nodes_of_type(child, type))
	
	return nodes

func _count_unique_tiles(tilemap: TileMap) -> int:
	var unique_tiles = {}
	
	for layer in range(tilemap.get_layers_count()):
		var used_cells = tilemap.get_used_cells(layer)
		for cell in used_cells:
			var tile_id = tilemap.get_cell_source_id(layer, cell)
			var atlas_coords = tilemap.get_cell_atlas_coords(layer, cell)
			var key = "%d_%d_%d" % [tile_id, atlas_coords.x, atlas_coords.y]
			unique_tiles[key] = true
	
	return unique_tiles.size()

func _get_tilemap_bounds(tilemap: TileMap) -> Rect2i:
	var used_cells = []
	for layer in range(tilemap.get_layers_count()):
		used_cells.append_array(tilemap.get_used_cells(layer))
	
	if used_cells.is_empty():
		return Rect2i(0, 0, 0, 0)
	
	var min_x = used_cells[0].x
	var min_y = used_cells[0].y
	var max_x = used_cells[0].x
	var max_y = used_cells[0].y
	
	for cell in used_cells:
		min_x = min(min_x, cell.x)
		min_y = min(min_y, cell.y)
		max_x = max(max_x, cell.x)
		max_y = max(max_y, cell.y)
	
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
