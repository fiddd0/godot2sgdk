@tool
extends RefCounted
class_name MemoryOptimizer

const VRAM_BANKS := 4
const VRAM_BANK_SIZE := 16 * 1024  # 16KB por bank

class MemoryUsage:
	var vram_banks: Array = [0, 0, 0, 0]  # Uso por bank
	var cram_usage: int = 0                # Uso de CRAM (cores)
	var total_tiles: int = 0
	var total_sprites: int = 0
	var total_animations: int = 0

func analyze_memory_usage(exported_data: Dictionary) -> MemoryUsage:
	var usage = MemoryUsage.new()
	
	# Analisar uso de tiles
	if exported_data.has("tilemaps"):
		for tilemap in exported_data["tilemaps"]:
			usage.total_tiles += tilemap.data.size()
			_allocate_vram(tilemap.data.size() * 2, usage)  # 2 bytes por tile
	
	# Analisar uso de sprites
	if exported_data.has("sprites"):
		usage.total_sprites = exported_data["sprites"].size()
		for sprite in exported_data["sprites"]:
			var sprite_size = sprite.width * sprite.height * 2  # 2 bytes por pixel
			_allocate_vram(sprite_size, usage)
	
	# Analisar uso de animações
	if exported_data.has("animations"):
		usage.total_animations = exported_data["animations"].size()
	
	return usage

func _allocate_vram(size: int, usage: MemoryUsage) -> bool:
	for i in range(VRAM_BANKS):
		if usage.vram_banks[i] + size <= VRAM_BANK_SIZE:
			usage.vram_banks[i] += size
			return true
	return false  # Sem espaço disponível

# ... (restante do código permanece igual)

func optimize_tilemap(tilemap_data: Array, max_unique_tiles: int = 256) -> Array:
	# Otimizar tilemap reduzindo tiles únicos
	var unique_tiles = {}
	var optimized_data = []
	var next_tile_id = 0
	
	for tile in tilemap_data:
		if not unique_tiles.has(tile):
			if unique_tiles.size() >= max_unique_tiles:
				# Usar tile mais similar existente
				tile = _find_similar_tile(tile, unique_tiles)
			else:
				unique_tiles[tile] = next_tile_id
				next_tile_id += 1
		
		optimized_data.append(unique_tiles[tile])
	
	print("Otimização reduziu de %d para %d tiles únicos" % [
		tilemap_data.size(), unique_tiles.size()])
	
	return optimized_data

func _find_similar_tile(tile: int, existing_tiles: Dictionary) -> int:
	# Encontrar o tile mais similar (implementação básica)
	var best_tile = 0
	var best_similarity = 0
	
	for existing_tile in existing_tiles:
		var similarity = _calculate_tile_similarity(tile, existing_tile)
		if similarity > best_similarity:
			best_similarity = similarity
			best_tile = existing_tile
	
	return best_tile

func _calculate_tile_similarity(tile1: int, tile2: int) -> int:
	# Calcular similaridade entre tiles (implementação simplificada)
	return 0  # Placeholder - implementar lógica real
