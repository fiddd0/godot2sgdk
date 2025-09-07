extends Node2D
class_name ComplexSceneTest

# Cena de teste com múltiplos TileMaps e elementos
func _ready():
	# Configurar viewport para teste
	get_viewport().size = Vector2i(720, 1280)
	
	# Criar fundo
	var background = ColorRect.new()
	background.color = Color.DARK_BLUE
	background.size = Vector2(2000, 2000)
	background.position = Vector2(-1000, -1000)
	add_child(background)
	
	# Criar múltiplos TileMaps em diferentes posições
	_create_tilemap_layer("GroundLayer", 0, Vector2i(0, 500), 16, 30, 1)
	_create_tilemap_layer("PlatformLayer", 1, Vector2i(100, 300), 8, 15, 2)
	_create_tilemap_layer("DecorationLayer", 2, Vector2i(-50, 200), 12, 10, 3)
	
	# Adicionar áreas de colisão complexas
	_create_collision_test_zones()
	
	print("Cena complexa de teste criada com sucesso!")

func _create_tilemap_layer(layer_name: String, z_index: int, position: Vector2i, width: int, height: int, tile_set_index: int):
	var tilemap = TileMap.new()
	tilemap.name = layer_name
	tilemap.position = position
	tilemap.z_index = z_index
	
	# ✅ CORREÇÃO: Usar caminho correto para o exportador
	var tilemap_exporter_script = load("res://addons/godot2sgdk/core/map_exporter.gd")
	if tilemap_exporter_script:
		tilemap.set_script(tilemap_exporter_script)
	else:
		print("⚠️ Map exporter não encontrado, continuando sem script")
	
	# Configurar células (simulação básica)
	tilemap.tile_set = TileSet.new()
	
	# Adicionar algumas células para teste
	for x in range(width):
		for y in range(height):
			if randf() > 0.8:  # 20% de chance de colocar um tile
				tilemap.set_cell(0, Vector2i(x, y), 0)
	
	add_child(tilemap)
	return tilemap

func _create_collision_test_zones():
	# Área de colisão retangular
	var rect_area = Area2D.new()
	rect_area.position = Vector2(400, 600)
	rect_area.name = "RectCollisionZone"
	
	var rect_collision = CollisionShape2D.new()
	rect_collision.shape = RectangleShape2D.new()
	rect_collision.shape.size = Vector2(200, 50)
	rect_area.add_child(rect_collision)
	add_child(rect_area)
	
	# Área de colisão circular
	var circle_area = Area2D.new()
	circle_area.position = Vector2(600, 400)
	circle_area.name = "CircleCollisionZone"
	
	var circle_collision = CollisionShape2D.new()
	circle_collision.shape = CircleShape2D.new()
	circle_collision.shape.radius = 60
	circle_area.add_child(circle_collision)
	add_child(circle_area)

# Função para testar a exportação
func test_export() -> bool:
	print("Iniciando teste de exportação de cena complexa...")
	
	# Verificar se todos os elementos estão presentes
	var elements = [
		get_node_or_null("GroundLayer"),
		get_node_or_null("PlatformLayer"), 
		get_node_or_null("DecorationLayer"),
		get_node_or_null("RectCollisionZone"),
		get_node_or_null("CircleCollisionZone")
	]
	
	for element in elements:
		if not element:
			print("FALHA: Elemento não encontrado!")
			return false
	
	print("SUCESSO: Todos os elementos da cena complexa estão presentes!")
	return true
