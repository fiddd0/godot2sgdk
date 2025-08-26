@tool
extends RefCounted

const TILE_SIZE = 16
const META_TILE_SIZE = 2  # 2x2 tiles

class MetaTile:
	var base_tiles: Array = []
	var hash: int = 0
	var sgdk_index: int = -1
	
	func _init(tiles: Array):
		base_tiles = tiles
		hash = _calculate_hash()
	
	func _calculate_hash() -> int:
		var hash_value = 0
		for tile in base_tiles:
			if tile is int:
				hash_value = hash_value * 31 + tile
		return hash_value

# ADICIONAR ESTA FUNÇÃO QUE ESTAVA FALTANDO
func _get_tile_data(tilemap: TileMap, layer: int, cell: Vector2i) -> Dictionary:
	return {
		"tile_id": tilemap.get_cell_source_id(layer, cell),
		"atlas_coords": tilemap.get_cell_atlas_coords(layer, cell)
	}

func process_tilemap(tilemap: TileMap) -> Dictionary:
	var result = {
		"tileset": {},
		"metatiles": [],
		"layer_data": {},
		"collision_data": {}
	}
	
	# Processar cada layer
	for layer in range(tilemap.get_layers_count()):
		var layer_name = tilemap.get_layer_name(layer)
		if layer_name.is_empty():
			layer_name = "layer_%d" % layer
		
		result.layer_data[layer_name] = _process_layer(tilemap, layer)
		
		# Extrair dados de colisão se for uma layer de colisão
		if _is_collision_layer(tilemap, layer):
			result.collision_data[layer_name] = _extract_collision_data(tilemap, layer)
	
	return result

func _process_layer(tilemap: TileMap, layer: int) -> Dictionary:
	var layer_data = {
		"width": 0,
		"height": 0,
		"tiles": [],
		"bounds": Rect2i()
	}
	
	var used_cells = tilemap.get_used_cells(layer)
	if used_cells.is_empty():
		return layer_data
	
	var bounds = _calculate_bounds(used_cells)
	layer_data.bounds = bounds
	layer_data.width = bounds.size.x
	layer_data.height = bounds.size.y
	
	# Inicializar grid vazio
	for y in range(bounds.size.y):
		var row = []
		row.resize(bounds.size.x)
		row.fill(0)
		layer_data.tiles.append(row)
	
	# Preencher com dados reais
	for cell in used_cells:
		var local_x = cell.x - bounds.position.x
		var local_y = cell.y - bounds.position.y
		
		if local_x >= 0 and local_y >= 0 and local_x < bounds.size.x and local_y < bounds.size.y:
			var tile_id = tilemap.get_cell_source_id(layer, cell)
			var atlas_coords = tilemap.get_cell_atlas_coords(layer, cell)
			var sgdk_index = _convert_to_sgdk_index(tile_id, atlas_coords)
			
			layer_data.tiles[local_y][local_x] = sgdk_index
	
	return layer_data

func _calculate_bounds(cells: Array) -> Rect2i:
	if cells.is_empty():
		return Rect2i(0, 0, 0, 0)
	
	var min_x = cells[0].x
	var min_y = cells[0].y
	var max_x = cells[0].x
	var max_y = cells[0].y
	
	for cell in cells:
		min_x = min(min_x, cell.x)
		min_y = min(min_y, cell.y)
		max_x = max(max_x, cell.x)
		max_y = max(max_y, cell.y)
	
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)

func _convert_to_sgdk_index(tile_id: int, atlas_coords: Vector2i) -> int:
	# Implementação básica - pode ser personalizada
	return atlas_coords.y * 16 + atlas_coords.x

func _is_collision_layer(tilemap: TileMap, layer: int) -> bool:
	var layer_name = tilemap.get_layer_name(layer)
	return layer_name.to_lower().contains("collision")

func _extract_collision_data(tilemap: TileMap, layer: int) -> Dictionary:
	# TODO: Implementar extração de dados de colisão
	return {}
