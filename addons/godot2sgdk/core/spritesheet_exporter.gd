@tool
extends RefCounted
class_name SpritesheetExporter

# Configurações de spritesheet
const DEFAULT_SETTINGS = {
	"max_width": 256,      # Largura máxima do spritesheet
	"max_height": 256,     # Altura máxima do spritesheet  
	"padding": 2,          # Espaçamento entre sprites
	"detect_animations": true,  # Detectar automaticamente animações
	"optimize_space": true     # Otimizar uso de espaço
}

var current_settings: Dictionary = DEFAULT_SETTINGS.duplicate()

# Dados do spritesheet
class SpritesheetData:
	var texture: ImageTexture
	var regions: Dictionary = {}  # sprite_name: Rect2
	var animations: Dictionary = {} # sprite_name: Array[Rect2]
	var metadata: Dictionary = {}

# Gerar spritesheet automaticamente
func generate_spritesheet(scene_root: Node) -> SpritesheetData:
	var data := SpritesheetData.new()
	var sprites := _find_all_sprites(scene_root)
	
	if sprites.is_empty():
		push_error("No sprites found for spritesheet generation")
		return data
	
	# Coletar todas as texturas únicas
	var unique_textures := _collect_unique_textures(sprites)
	
	if unique_textures.is_empty():
		push_error("No textures found for spritesheet")
		return data
	
	# Criar spritesheet
	var spritesheet_image := _create_spritesheet_image(unique_textures)
	data.texture = ImageTexture.create_from_image(spritesheet_image)
	
	# Gerar metadata com regiões
	data.regions = _generate_regions_metadata(unique_textures)
	
	# Detectar animações se configurado
	if current_settings.detect_animations:
		data.animations = _detect_animations(scene_root)
	
	return data

# Encontrar todos os sprites na cena
func _find_all_sprites(node: Node) -> Array:
	var sprites := []
	
	if node is Sprite2D or node is AnimatedSprite2D:
		sprites.append(node)
	
	for child in node.get_children():
		sprites.append_array(_find_all_sprites(child))
	
	return sprites

# Coletar texturas únicas
func _collect_unique_textures(sprites: Array) -> Array:
	var unique_textures := []
	var seen_textures := {}
	
	for sprite in sprites:
		var textures_to_check := []
		
		if sprite is Sprite2D:
			textures_to_check.append(sprite.texture)
	
		elif sprite is AnimatedSprite2D and sprite.sprite_frames:
			var sprite_frames = sprite.sprite_frames
			for anim_name in sprite_frames.get_animation_names():
				for frame_idx in sprite_frames.get_frame_count(anim_name):
					textures_to_check.append(sprite_frames.get_frame_texture(anim_name, frame_idx))
	
		# Verificar todas as texturas coletadas
		for texture in textures_to_check:
			if texture and texture.resource_path and not seen_textures.has(texture.resource_path):
				unique_textures.append(texture)
				seen_textures[texture.resource_path] = true
	
	return unique_textures

# Criar imagem do spritesheet
func _create_spritesheet_image(textures: Array) -> Image:
	var padding = current_settings.padding
	var max_width = current_settings.max_width
	var max_height = current_settings.max_height
	
	# Calcular layout do spritesheet
	var layout := _calculate_layout(textures, padding, max_width)
	
	# Criar imagem vazia
	var spritesheet_image := Image.create(
		layout.total_width, 
		layout.total_height,
		false,
		Image.FORMAT_RGBA8
	)
	
	spritesheet_image.fill(Color(0, 0, 0, 0))
	
	# Copiar texturas para o spritesheet
	for i in range(textures.size()):
		var texture: Texture2D = textures[i]
		var position: Vector2 = layout.positions[i]
		var image: Image = texture.get_image()
		
		spritesheet_image.blit_rect(
			image,
			Rect2(0, 0, texture.get_width(), texture.get_height()),
			position
		)
	
	return spritesheet_image

# Calcular layout do spritesheet (bin packing simples)
func _calculate_layout(textures: Array, padding: int, max_width: int) -> Dictionary:
	var result := {
		"positions": [],
		"total_width": 0,
		"total_height": 0
	}	
	
	var x = 0
	var y = 0
	var row_height = 0
	
	# ✅ 1. ORDENAR TEXTURAS POR ALTURA (melhor packing)
	textures.sort_custom(func(a, b): return a.get_height() > b.get_height())
	
	for texture in textures:
		var width = texture.get_width() + padding
		var height = texture.get_height() + padding
		
		# ✅ 2. LIMITAR LARGURA MÁXIMA (evitar spritesheets gigantes)
		var actual_max_width = min(max_width, 512)  # Máximo 512px de largura
		
		# Quebra de linha se necessário
		if x + width > actual_max_width:
			x = 0
			y += row_height + padding
			row_height = 0
		
		result.positions.append(Vector2(x, y))
		x += width
		row_height = max(row_height, height)
		
		result.total_width = max(result.total_width, x)
		result.total_height = max(result.total_height, y + height)
	
	# ✅ 3. VALIDAÇÃO DE TAMANHO MÁXIMO
	if result.total_width > 1024 or result.total_height > 1024:
		push_warning("Spritesheet very large: %dx%d pixels" % [result.total_width, result.total_height])
		push_warning("Consider using smaller textures or increasing padding")
	
	# ✅ 4. LOG DE OTIMIZAÇÃO
	print("Spritesheet layout: %dx%d (%.1f%% efficiency)" % [
		result.total_width, 
		result.total_height,
		_calculate_efficiency(textures, result) * 100
	])
	
	return result

# ✅ 5. CALCULAR EFICIÊNCIA DO PACKING
func _calculate_efficiency(textures: Array, layout: Dictionary) -> float:
	var total_texture_area = 0
	for texture in textures:
		total_texture_area += texture.get_width() * texture.get_height()
	
	var spritesheet_area = layout.total_width * layout.total_height
	if spritesheet_area == 0:
		return 0.0
	
	return float(total_texture_area) / float(spritesheet_area)

# Gerar metadata das regiões
func _generate_regions_metadata(textures: Array) -> Dictionary:
	var regions := {}
	var layout = _calculate_layout(textures, current_settings.padding, current_settings.max_width)
	
	for i in range(textures.size()):
		var texture: Texture2D = textures[i]
		var pos: Vector2 = layout.positions[i]
		
		# ✅ VERIFICAR SE A TEXTURA TEM NOME VÁLIDO
		#var texture_name = texture.resource_path.get_file() if texture.resource_path else "texture_%d" % i
		var texture_name = "texture_%d" % i
		if texture and texture.resource_path:
			texture_name = texture.resource_path.get_file()
		regions[texture_name] = Rect2(
			pos.x,
			pos.y,
			texture.get_width(),
			texture.get_height()
		)
	
	return regions

# Detectar animações automaticamente
func _detect_animations(scene_root: Node) -> Dictionary:
	var animations := {}
	var animated_sprites := _find_animated_sprites(scene_root)
	
	for sprite in animated_sprites:
		if sprite is AnimatedSprite2D and sprite.sprite_frames:
			var sprite_anims := {}
			var anim_names = sprite.sprite_frames.get_animation_names()
			
			for anim_name in anim_names:
				var frames = []
				for frame_idx in sprite.sprite_frames.get_frame_count(anim_name):
					var frame_texture = sprite.sprite_frames.get_frame_texture(anim_name, frame_idx)
					if frame_texture:
						var texture_path = frame_texture.resource_path
						var texture_name = texture_path.get_file() if texture_path else "unknown"
						if frame_texture and frame_texture.resource_path:
							frames.append(frame_texture.resource_path.get_file())
						else:
							frames.append("frame_%d" % frame_idx)
										
				sprite_anims[anim_name] = frames
			
			animations[sprite.name] = sprite_anims
	
	return animations

# Encontrar apenas AnimatedSprite2D
func _find_animated_sprites(node: Node) -> Array:
	var sprites := []
	
	if node is AnimatedSprite2D:
		sprites.append(node)
	
	for child in node.get_children():
		sprites.append_array(_find_animated_sprites(child))
	
	return sprites

# Exportar spritesheet para arquivo
func export_spritesheet_to_file(scene_root: Node, export_path: String) -> bool:
	var data = generate_spritesheet(scene_root)
	
	if not data.texture:
		return false
	
	# Salvar imagem
	var image = data.texture.get_image()
	var image_error = image.save_png(export_path + ".png")
	if image_error != OK:
		push_error("Failed to save spritesheet image")
		return false
	
	# Salvar metadata
	var metadata_path = export_path + ".json"
	return _save_metadata(data, metadata_path)

# Salvar metadata em JSON
func _save_metadata(data: SpritesheetData, file_path: String) -> bool:
	var metadata := {
		"regions": {},
		"animations": data.animations,
		"spritesheet_size": {
			"width": data.texture.get_width(),
			"height": data.texture.get_height()
		}
	}
	
	# Converter Rect2 para formato serializável
	for key in data.regions:
		var rect: Rect2 = data.regions[key]
		metadata["regions"][key] = {
			"x": rect.position.x,
			"y": rect.position.y,
			"width": rect.size.x,
			"height": rect.size.y
		}
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(metadata, "\t"))
		file.close()
		return true
	
	return false

# Gerar header SGDK para spritesheet
func generate_spritesheet_header(data: SpritesheetData, base_name: String) -> String:
	var header := "// Spritesheet: %s\n" % base_name
	header += "// Generated by Godot2SGDK\n\n"
	
	header += "// Sprite regions\n"
	for region_name in data.regions:
		var rect: Rect2 = data.regions[region_name]
		header += "#define %s_RECT {%.0f, %.0f, %.0f, %.0f}\n" % [
			region_name.to_upper().replace(".", "_"),
			rect.position.x,
			rect.position.y,
			rect.size.x,
			rect.size.y
		]
	
	header += "\n// Spritesheet dimensions\n"
	header += "#define SPRITESHEET_WIDTH %d\n" % data.texture.get_width()
	header += "#define SPRITESHEET_HEIGHT %d\n" % data.texture.get_height()
	
	return header
