@tool
extends VBoxContainer

var plugin: EditorPlugin
var config: RefCounted
var palette_editor: PaletteEditor
var spritesheet_exporter: RefCounted
var animation_exporter: RefCounted
var map_exporter: RefCounted
var sprite_exporter: RefCounted
var collision_exporter: RefCounted
var entity_exporter: RefCounted
var memory_optimizer: RefCounted
var config_manager: ConfigManager
var settings_dialog: SettingsDialog

# Referências para os nodes da UI
var export_btn: Button
var sprite_btn: Button
var validate_btn: Button
var settings_btn: Button
var log_output: TextEdit
var progress_bar: ProgressBar
var test_btn: Button  # Novo botão para testes

func _ready():
	# Criar interface básica programaticamente
	var hbox = HBoxContainer.new()
	hbox.name = "ButtonContainer"
	config_manager = preload("res://addons/godot2sgdk/core/config_manager.gd").new()
		
	export_btn = Button.new()
	export_btn.name = "ExportBtn"
	export_btn.text = "Export TileMaps"
	export_btn.pressed.connect(_on_export_pressed)
	
	# Botão para exportar sprites
	sprite_btn = Button.new()
	sprite_btn.name = "SpriteBtn"
	sprite_btn.text = "Export Sprites"
	sprite_btn.pressed.connect(_on_sprite_export_pressed)

	# NOVO BOTÃO PARA ANIMAÇÕES
	var anim_btn = Button.new()
	anim_btn.name = "AnimBtn"
	anim_btn.text = "Export Animations"
	anim_btn.pressed.connect(_on_animation_export_pressed) # NOVO MÉTODO

	var spritesheet_btn = Button.new()
	spritesheet_btn.name = "SpritesheetBtn"
	spritesheet_btn.text = "Generate Spritesheet"
	spritesheet_btn.pressed.connect(_on_spritesheet_export_pressed)

	# Botão de exportação de colisão
	var collision_btn = Button.new()
	collision_btn.text = "Export Collision"
	collision_btn.pressed.connect(_on_export_collision)
	hbox.add_child(collision_btn)
	
	# Botão de exportação de entidades
	var entities_btn = Button.new()
	entities_btn.text = "Export Entities" 
	entities_btn.pressed.connect(_on_export_entities)
	hbox.add_child(entities_btn)
	
	# Botão de otimização de memória
	var optimize_btn = Button.new()
	optimize_btn.text = "Optimize Memory"
	optimize_btn.pressed.connect(_on_optimize_memory)
	hbox.add_child(optimize_btn)

	validate_btn = Button.new()
	validate_btn.name = "ValidateBtn"
	validate_btn.text = "Validate"
	validate_btn.pressed.connect(_on_validate_pressed)
	
	settings_btn = Button.new()
	settings_btn.name = "SettingsBtn"
	settings_btn.text = "Settings"
	settings_btn.pressed.connect(_on_settings_pressed)
	
	# NOVO BOTÃO PARA TESTES
	test_btn = Button.new()
	test_btn.name = "TestBtn"
	test_btn.text = "Test Complex Scenes"
	test_btn.pressed.connect(_test_complex_scenes)
	
	# Botão de teste de performance
	var performance_btn = Button.new()
	performance_btn.name = "PerformanceBtn"
	performance_btn.text = "Test Performance"
	performance_btn.pressed.connect(_on_performance_test_pressed)
	
	# Botão de teste de estresse
	var stress_btn = Button.new()
	stress_btn.name = "StressBtn"
	stress_btn.text = "Stress Test"
	stress_btn.pressed.connect(_on_stress_test_pressed)
	
	# ✅ BOTÃO DE TESTE EXTREMO - ADICIONE ESTE
	var extreme_btn = Button.new()
	extreme_btn.name = "ExtremeBtn"
	extreme_btn.text = "EXTREME TEST"
	extreme_btn.add_theme_color_override("font_color", Color.RED)
	extreme_btn.pressed.connect(_on_extreme_test_pressed)	

	
	hbox.add_child(export_btn)
	hbox.add_child(sprite_btn)
	hbox.add_child(anim_btn) # ADICIONAR AO HBOX
	hbox.add_child(spritesheet_btn)
	hbox.add_child(validate_btn)
	hbox.add_child(settings_btn)
	hbox.add_child(test_btn)  # ADICIONAR BOTÃO DE TESTE
	hbox.add_child(performance_btn)
	hbox.add_child(stress_btn)
	hbox.add_child(extreme_btn)
	add_child(hbox)
	
	log_output = TextEdit.new()
	log_output.name = "LogOutput"
	log_output.custom_minimum_size.y = 200
	log_output.editable = false
	add_child(log_output)
	
	progress_bar = ProgressBar.new()
	progress_bar.name = "ProgressBar"
	progress_bar.max_value = 100
	progress_bar.value = 0
	add_child(progress_bar)
	
	# Carregar os exportadores
	_load_sprite_exporter()
	_load_map_exporter()
	_load_animation_exporter()
	_load_spritesheet_exporter()		
	# Configurar interface baseada nas configurações
	_update_ui_from_config()
	
	print("✅ MainDock initialized")
	
	_create_palette_ui()

	
# LINHA 90: Novo método de carregamento

func _is_scene_empty(scene_root: Node) -> bool:
	# Uma cena está vazia se só tem o nó root sem filhos relevantes
	if scene_root.get_child_count() == 0:
		return true
	
	# Ou se só tem nodes de controle/UI sem conteúdo de jogo
	var has_game_content = false
	for child in scene_root.get_children():
		if (child is TileMap or child is Sprite2D or child is CharacterBody2D or 
			child is RigidBody2D or child is Area2D or child is CollisionShape2D):
			has_game_content = true
			break
	
	return not has_game_content

func _load_map_exporter():
	var map_exporter_script = preload("res://addons/godot2sgdk/core/map_exporter.gd")
	if map_exporter_script:
		map_exporter = map_exporter_script.new(self)  # ✅ PASSAR 'self' como referência
		_add_log_message("✅ MapExporter loaded successfully")
	else:
		_add_log_message("❌ Failed to load MapExporter")

func _load_sprite_exporter():
	var sprite_exporter_script = preload("res://addons/godot2sgdk/core/sprite_exporter.gd")
	if sprite_exporter_script:
		sprite_exporter = sprite_exporter_script.new() # ✅ CORRETO
		_add_log_message("✅ SpriteExporter loaded successfully")
	else:
		_add_log_message("❌ Failed to load SpriteExporter")

# LINHA 85: Novo método de carregamento
func _load_animation_exporter():
	var animation_exporter_script = preload("res://addons/godot2sgdk/core/animation_exporter.gd")
	if animation_exporter_script:
		animation_exporter = animation_exporter_script.new()
		_add_log_message("✅ AnimationExporter loaded successfully")
	else:
		_add_log_message("❌ Failed to load AnimationExporter")

func _load_spritesheet_exporter():
	var spritesheet_exporter_script = preload("res://addons/godot2sgdk/core/spritesheet_exporter.gd")
	if spritesheet_exporter_script:
		spritesheet_exporter = spritesheet_exporter_script.new()
		_add_log_message("✅ SpritesheetExporter loaded successfully")
	else:
		_add_log_message("❌ Failed to load SpritesheetExporter")

func _create_palette_ui():
	var palette_btn = Button.new()
	palette_btn.text = "🎨 Edit Palette"
	palette_btn.pressed.connect(_on_palette_editor_pressed)
	add_child(palette_btn)
	
	# Criar editor de paletas (inicialmente oculto)
	var palette_editor_script = load("res://addons/godot2sgdk/ui/palette_editor.gd")

	if palette_editor_script:
		palette_editor = palette_editor_script.new()
		palette_editor.visible = false
		palette_editor.palette_changed.connect(_on_palette_changed)
		add_child(palette_editor)


	# Criar editor de paletas (inicialmente oculto)
	palette_editor = PaletteEditor.new()
	palette_editor.visible = false
	add_child(palette_editor)

# LINHA 100: Adicionar handler do botão
func _on_palette_editor_pressed():
	palette_editor.visible = not palette_editor.visible
	if palette_editor.visible:
		_add_log_message("🎨 Palette editor opened")
	else:
		_add_log_message("🎨 Palette editor closed")

# LINHA 115-125: Adicionar handler de mudança de paleta
func _on_palette_changed():
	_add_log_message("🎨 Palette updated - changes will affect future exports")
	
func _on_export_pressed():
	_clear_log()
	_add_log_message("🚀 Starting TileMap export...")
	progress_bar.value = 10
	
   # ✅ CORREÇÃO: Usar edited_scene_root
	var scene_root = get_tree().edited_scene_root
	if not scene_root:
		_add_log_message("❌ Please open a scene first!")
		progress_bar.value = 0
		return
		
	if _is_scene_empty(scene_root):
		_add_log_message("❌ Scene is empty! Add some nodes before exporting.")
		progress_bar.value = 0
		return

	# Validar antes de exportar
	var validation_issues = _validate_current_scene()
	if not validation_issues.is_empty():
		_display_validation_results(validation_issues)
		_add_log_message("❌ Export aborted due to validation errors")
		progress_bar.value = 0
		return
	
	# Executar exportação REAL
	_export_current_scene()

func _on_sprite_export_pressed():
	_clear_log()
	_add_log_message("🎨 Starting sprite export...")
	progress_bar.value = 10

	# ✅ ADICIONAR VALIDAÇÃO EM TODOS OS BOTÕES
	var scene_root = get_tree().edited_scene_root
	if not scene_root:
		_add_log_message("❌ Please open a scene first!")
		progress_bar.value = 0
		return
	
	if _is_scene_empty(scene_root):
		_add_log_message("❌ Scene is empty! Add some nodes before exporting.")
		progress_bar.value = 0
		return
	
	# Executar exportação de sprites
	_export_sprites()

func _on_export_collision():
	var collision_exporter = preload("res://addons/godot2sgdk/core/collision_exporter.gd").new()
	var scene_root = get_tree().edited_scene_root  # ✅ CORREÇÃO
	if scene_root:
		var collision_data = collision_exporter.export_collision_in_scene(scene_root)
		_add_log_message("Exported %d collision objects" % collision_data.size())
	else:
		_add_log_message("❌ No scene open for collision export")	
		
func _on_export_entities():
	var entity_exporter = preload("res://addons/godot2sgdk/core/entity_exporter.gd").new()
	var scene_root = get_tree().edited_scene_root  # ✅ CORREÇÃO
	if scene_root:
		var entities_data = entity_exporter.export_entities_in_scene(scene_root)
		_add_log_message("Exported %d entities" % entities_data.size())
	else:
		_add_log_message("❌ No scene open for entity export")
		
func _on_optimize_memory():
	var memory_optimizer = preload("res://addons/godot2sgdk/core/memory_optimizer.gd").new()
	var scene_root = get_tree().edited_scene_root  # ✅ CORREÇÃO
	if scene_root:
		# Coletar dados exportados primeiro
		var exported_data = {
			"tilemaps": map_exporter.export_tilemaps_in_scene(scene_root),
			"sprites": sprite_exporter.export_sprites_in_scene(scene_root),
			"animations": animation_exporter.export_animations_in_scene(scene_root)
		}

		var memory_usage = memory_optimizer.analyze_memory_usage(exported_data)
		_add_log_message("Memory analysis complete:")
		_add_log_message("VRAM Usage: %d/%d KB" % [
			memory_usage.vram_banks.reduce(func(a, b): return a + b, 0) / 1024,
			memory_optimizer.VRAM_BANKS * memory_optimizer.VRAM_BANK_SIZE / 1024
]		)
	else:
		_add_log_message("❌ No scene open for memory optimization")

func _on_animation_export_pressed():
	_clear_log()
	_add_log_message("🎬 Starting animation export...")
	progress_bar.value = 10
	
	if animation_exporter == null:
		_add_log_message("❌ Animation exporter not available!")
		progress_bar.value = 0
		return
	
	# Executar exportação de animações
	_export_animations()

func _on_spritesheet_export_pressed():
	_clear_log()
	_add_log_message("🖼️ Generating spritesheet...")
	progress_bar.value = 10
	
	if spritesheet_exporter == null:
		_add_log_message("❌ Spritesheet exporter not available!")
		progress_bar.value = 0
		return
	
		_export_spritesheet()  # 🆕 CHAMAR MÉTODO DE EXPORTAÇÃO
	
	var scene_root = get_tree().edited_scene_root
	if not scene_root:
		_add_log_message("❌ No scene to export")
		progress_bar.value = 0
		return
	
	var export_path = "res://export/spritesheet"
	var success = spritesheet_exporter.export_spritesheet_to_file(scene_root, export_path)
	
	if success:
		_add_log_message("✅ Spritesheet generated successfully!")
		_add_log_message("📁 Files: spritesheet.png + spritesheet.json")
		progress_bar.value = 100
	else:
		_add_log_message("❌ Spritesheet generation failed!")
		progress_bar.value = 0

func _on_validate_pressed():
	_clear_log()
	_add_log_message("🔍 Validating scene...")
	var scene_root = get_tree().edited_scene_root
	if not scene_root:
		_add_log_message("❌ Please open a scene first!")
		return  # ✅ Não chamar validação se não há cena	
	var issues = _validate_current_scene()
	_display_validation_results(issues)

func _on_performance_test_pressed():
	_clear_log()
	_add_log_message("⚡ INICIANDO TESTE DE PERFORMANCE")
	_add_log_message("Criando mapa 100x100 tiles (10,000 tiles)...")
	progress_bar.value = 10
	
	# Carregar e executar testador de performance
	var perf_test_script = load("res://addons/godot2sgdk/tests/performance_test.gd")
	if not perf_test_script:
		_add_log_message("❌ Script de performance não encontrado!")
		progress_bar.value = 0
		return
	
	var perf_tester = perf_test_script.new(self)
	progress_bar.value = 30
	
	# Executar teste de mapa grande
	var results = perf_tester.run_large_map_test()
	progress_bar.value = 70
	
	# Exibir resultados
	_display_performance_results(results)
	progress_bar.value = 100
	
	if results.success:
		_add_log_message("✅ Teste de performance concluído!")
	else:
		_add_log_message("❌ Teste de performance falhou!")



func _display_performance_results(results: Dictionary):
	_add_log_message("📊 RESULTADOS DE PERFORMANCE:")
	_add_log_message("✅ Sucesso: " + str(results.get("success", false)))
	_add_log_message("🧱 Total de tiles: " + str(results.get("total_tiles", 0)))
	_add_log_message("⏱️ Tempo de exportação: %.3f segundos" % results.get("export_time", 0.0))
	_add_log_message("💾 Uso de memória: ~%d MB" % results.get("memory_usage", 0))
	_add_log_message("🎯 Classificação: " + results.get("performance_rating", "Desconhecida"))
	
	for error in results.get("errors", []):
		_add_log_message("❌ ERRO: " + error)
	
	for warning in results.get("warnings", []):
		_add_log_message("⚠️ AVISO: " + warning)
	
	# Recomendações baseadas na performance
	_add_log_message("")
	_add_log_message("💡 RECOMENDAÇÕES:")
	if results.get("export_time", 0.0) > 3.0:
		_add_log_message("   • Considerar otimização de exportação em lote")
		_add_log_message("   • Reduzir complexidade de tilesets muito grandes")
	else:
		_add_log_message("   • Performance adequada para projetos de grande escala")

# Adicione também esta função para teste de estresse
func _on_stress_test_pressed():
	_clear_log()
	_add_log_message("🔥 INICIANDO TESTE DE ESTRESSE")
	_add_log_message("Criando 3 mapas 50x50 (7,500 tiles cada)...")
	progress_bar.value = 10
	
	var perf_test_script = load("res://addons/godot2sgdk/tests/performance_test.gd")
	if not perf_test_script:
		_add_log_message("❌ Script de performance não encontrado!")
		progress_bar.value = 0
		return
	
	var perf_tester = perf_test_script.new(self)
	progress_bar.value = 30
	
	var results = perf_tester.run_stress_test()
	progress_bar.value = 70
	
	_add_log_message("📊 RESULTADOS DO TESTE DE ESTRESSE:")
	_add_log_message("✅ Sucesso: " + str(results.get("success", false)))
	_add_log_message("🗺️ Total de mapas: " + str(results.get("total_maps", 0)))
	_add_log_message("🧱 Total de tiles: " + str(results.get("total_tiles", 0)))
	_add_log_message("⏱️ Tempo total: %.3f segundos" % results.get("export_time", 0.0))
	_add_log_message("📈 Pico de memória: ~%d MB" % results.get("memory_peak", 0))
	
	progress_bar.value = 100

func _display_stress_test_results(results: Dictionary):
	_add_log_message("")
	_add_log_message("💥 RESULTADOS DO TESTE DE ESTRESSE:")
	_add_log_message("✅ Sucesso: " + str(results.get("success", false)))
	_add_log_message("🗺️ Total de mapas: " + str(results.get("total_maps", 0)))
	_add_log_message("🧱 Total de tiles: " + str(results.get("total_tiles", 0)))
	_add_log_message("⏱️ Tempo total: %.3f segundos" % results.get("export_time", 0.0))
	_add_log_message("📈 Pico de memória: ~%d MB" % results.get("memory_peak", 0))
	_add_log_message("🚀 Velocidade: %.1f tiles/segundo" % results.get("tiles_per_second", 0))
	
	# Análise de performance
	var export_time = results.get("export_time", 1.0)
	var total_tiles = results.get("total_tiles", 1)
	var tiles_per_second = total_tiles / export_time
	
	_add_log_message("")
	_add_log_message("📊 ANÁLISE DE PERFORMANCE:")
	_add_log_message("   • Throughput: %.0f tiles/segundo" % tiles_per_second)
	
	if tiles_per_second > 10000:
		_add_log_message("   • Status: ⚡ ULTRA RÁPIDO")
	elif tiles_per_second > 5000:
		_add_log_message("   • Status: 🚀 EXCELENTE")
	elif tiles_per_second > 1000:
		_add_log_message("   • Status: ✅ BOM")
	else:
		_add_log_message("   • Status: ⚠️ NECESSITA OTIMIZAÇÃO")
	
	# Verificar se há erros ou warnings
	for error in results.get("errors", []):
		_add_log_message("❌ ERRO CRÍTICO: " + error)
	
	for warning in results.get("warnings", []):
		_add_log_message("⚠️ AVISO: " + warning)
	
	# Recomendações finais
	_add_log_message("")
	_add_log_message("💡 RECOMENDAÇÕES PARA PRODUÇÃO:")
	if tiles_per_second > 5000:
		_add_log_message("   • Pronto para projetos AAA")
		_add_log_message("   • Suporta world maps gigantes")
	else:
		_add_log_message("   • Considerar otimizações para mapas muito grandes")
		_add_log_message("   • Implementar exportação em threads")

func _on_extreme_test_pressed():
	_clear_log()
	_add_log_message("💀🔥⚠️  INICIANDO TESTE EXTREMO - 5 MAPAS GIGANTES")  # ✅ Atualizado
	_add_log_message("⚠️  AVISO: Este teste pode travar computadores fracos!")
	_add_log_message("💻 Recomendado apenas para hardware moderno")
	_add_log_message("🔄 Criando 5 mapas de até 120x120 tiles...")
	progress_bar.value = 5
	
	# Confirmação de segurança
	if not _confirm_extreme_test():
		_add_log_message("❌ Teste extremo cancelado pelo usuário")
		progress_bar.value = 0
		return
	
	var perf_test_script = load("res://addons/godot2sgdk/tests/performance_test.gd")
	if not perf_test_script:
		_add_log_message("❌ Script de performance não encontrado!")
		progress_bar.value = 0
		return
	
	var perf_tester = perf_test_script.new(self)
	progress_bar.value = 20
	
	# Executar teste EXTREMO
	var results = perf_tester.run_extreme_test()
	progress_bar.value = 80
	
	# Exibir resultados EPICOS
	_display_extreme_results(results)
	progress_bar.value = 100
	
	if results.get("success", false):
		_add_log_message("🎉💀🔥 TESTE EXTREMO SUPERADO!")
	else:
		_add_log_message("⚠️  Teste extremo falhou - hardware limitado?")

func _confirm_extreme_test() -> bool:
	# Em uma implementação real, aqui viria um diálogo de confirmação
	# Por enquanto, vamos apenas retornar true (usuário confirmou)
	print("⚠️  Confirmação de teste extremo solicitada")
	return true

func _display_extreme_results(results: Dictionary):
	_add_log_message("")
	_add_log_message("💀🔥📊 RESULTADOS DO TESTE EXTREMO:")
	_add_log_message("✅ Sucesso: " + str(results.get("success", false)))
	_add_log_message("🗺️ Total de mapas: " + str(results.get("total_maps", 0)))
	_add_log_message("🧱 Total de tiles: " + str(results.get("total_tiles", 0)) + " TILES!")
	_add_log_message("⏱️ Tempo total: %.3f segundos" % results.get("export_time", 0.0))
	_add_log_message("📈 Pico de memória: ~%d MB" % results.get("memory_peak", 0))
	
	if results.has("tiles_per_second"):
		var tps = results["tiles_per_second"]
		_add_log_message("🚀 Velocidade: %.0f tiles/segundo" % tps)
		
		# Classificação EPICA
		if tps > 2000000:
			_add_log_message("💎 Classificação: GOD-TIER")
		elif tps > 1000000:
			_add_log_message("🔥 Classificação: EXTREME")
		elif tps > 500000:
			_add_log_message("⭐ Classificação: ULTRA")
		else:
			_add_log_message("✅ Classificação: ACEITÁVEL")
	
	# Mostrar tamanhos dos mapas
	if results.has("map_sizes"):
		_add_log_message("📏 Tamanhos dos mapas: " + str(results["map_sizes"]))
	
	# Verificar se há erros ou warnings
	for error in results.get("errors", []):
		_add_log_message("❌💀 ERRO CRÍTICO: " + error)
	
	for warning in results.get("warnings", []):
		_add_log_message("⚠️  AVISO EXTREMO: " + warning)
	
	# Recomendações finais EPICAS
	_add_log_message("")
	_add_log_message("💡🎯 RECOMENDAÇÕES PARA PROJETOS EPICOS:")
	if results.get("success", false):
		_add_log_message("   • Pronto para MMOs e open worlds gigantes")
		_add_log_message("   • Suporta streaming de mundo infinito")
		_add_log_message("   • Performance de supercomputador")
	else:
		_add_log_message("   • Considerar otimizações para projetos muito grandes")
		_add_log_message("   • Implementar carregamento assíncrono")
		_add_log_message("   • Adicionar sistema de paginação de mapas")

func _on_settings_pressed():
	_add_log_message("⚙️ Settings button pressed")
	# TODO: Implementar diálogo de configurações	
	_add_log_message("⚙️ Opening settings...")
	
	if not settings_dialog:
		var settings_script = load("res://addons/godot2sgdk/ui/settings_dialog.gd")
		if settings_script:
			settings_dialog = settings_script.new(self, config_manager)
			add_child(settings_dialog)
		else:
			_add_log_message("❌ Settings dialog script not found")
			return
	
	settings_dialog.popup_centered()

func get_export_path() -> String:
	if config_manager:
		return config_manager.get_setting("general", "export_path", "res://export/")
	return "res://export/"

func _apply_touch_friendly_style():
	# Aplicar estilo mobile-friendly nos botões
	var buttons = [export_btn, sprite_btn, validate_btn, settings_btn, test_btn]
	for button in buttons:
		if button:
			button.custom_minimum_size = Vector2(120, 40)
			button.add_theme_font_size_override("font_size", 16)


# ✅ FUNÇÃO DE TESTE DE CENAS COMPLEXAS ADICIONADA AQUI
func _test_complex_scenes():
	_clear_log()
	_add_log_message("=== INICIANDO TESTE DE CENAS COMPLEXAS ===")
	progress_bar.value = 10
	
	# Carregar e criar a cena de teste
	var test_scene_script = load("res://addons/godot2sgdk/tests/complex_scene_test.gd")
	if not test_scene_script:
		_add_log_message("❌ Script de teste não encontrado!")
		progress_bar.value = 0
		return
	
	var test_scene = test_scene_script.new()
	# ✅ CORREÇÃO: Adicionar à árvore de cena atual em vez da raiz
	var current_scene = get_tree().edited_scene_root
	if current_scene:
		current_scene.add_child(test_scene)
	else:
		# Se não há cena aberta, criar uma nova
		get_tree().root.add_child(test_scene)
	
	# Carregar e executar o testador
	var tester_script = load("res://addons/godot2sgdk/tests/complex_scene_tester.gd")
	if not tester_script:
		_add_log_message("❌ Script testador não encontrado!")
		test_scene.queue_free()
		progress_bar.value = 0
		return
	
	var tester = tester_script.new(self)
	var results = tester.run_test(test_scene)
	progress_bar.value = 50
	
	# Exibir resultados
	_add_log_message("Resultados do teste:")
	_add_log_message("- Sucesso: " + str(results.get("success", false)))
	_add_log_message("- Elementos exportados: " + str(results.get("exported_elements", 0)) + "/5")
	_add_log_message("- Tempo: " + str(results.get("export_time", 0.0)) + " segundos")
	
	for error in results.get("errors", []):
		_add_log_message("ERRO: " + error)
	
	for warning in results.get("warnings", []):
		_add_log_message("AVISO: " + warning)
	
	# Limpar
	test_scene.queue_free()
	progress_bar.value = 100
	
	if results.get("success", false):
		_add_log_message("✅ Teste de cenas complexas concluído com sucesso!")
	else:
		_add_log_message("❌ Teste de cenas complexas falhou!")

func _validate_current_scene() -> Array:
	var scene_root = get_tree().edited_scene_root
	if scene_root:
		# Usar validação estática
		var validation_script = preload("res://addons/godot2sgdk/utils/validation_utils.gd")
		if validation_script:
			return validation_script.validate_scene_static(scene_root)
		else:
			_add_log_message("❌ Validation script not found")
			return []
	else:
		_add_log_message("⚠️ No scene open for validation")
		return ["error: No scene open, message: Please Open a scene first"]  # Retornar array vazio pode enganar a UI

func _export_current_scene():
	_add_log_message("📦 Preparing TileMap export...")
	progress_bar.value = 25
	
	if map_exporter == null:
		_add_log_message("❌ Map exporter not available!")
		progress_bar.value = 0
		return
	
	# Chamar exportação REAL
	var success = _run_real_export()
	
	if success:
		_add_log_message("🎉 TileMap export completed successfully!")
		progress_bar.value = 100
		_add_log_message("📁 Files saved to: res://export/")
		
		# Listar arquivos gerados (agora inclui colisão)
		_list_exported_files()
	else:
		_add_log_message("❌ TileMap export failed!")
		progress_bar.value = 0

func _export_sprites():
	_add_log_message("🖼️ Preparing sprite export...")
	progress_bar.value = 25
	
	if sprite_exporter == null:
		_add_log_message("❌ Sprite exporter not available!")
		progress_bar.value = 0
		return
	
	# Chamar exportação REAL de sprites
	var success = _run_real_sprite_export()
	
	if success:
		_add_log_message("🎉 Sprite export completed successfully!")
		progress_bar.value = 100
		_add_log_message("📁 Sprite files saved to: res://export/")
		
		# Listar arquivos gerados
		_list_exported_files()
	else:
		_add_log_message("❌ Sprite export failed!")
		progress_bar.value = 0

# ADICIONAR APÓS _export_sprites():
func _export_animations():
	
	_add_log_message("📽️ Preparing animation export...")
	progress_bar.value = 25
	
	if animation_exporter == null:
		_add_log_message("❌ Animation exporter not available!")
		progress_bar.value = 0
		return
	
	# Chamar exportação REAL de animações
	var success = _run_real_animation_export()
	
	if success:
		_add_log_message("🎉 Animation export completed successfully!")
		progress_bar.value = 100
		_add_log_message("📁 Animation files saved to: res://export/")
		
		# Listar arquivos gerados
		_list_exported_files()
	else:
		_add_log_message("❌ Animation export failed!")
		progress_bar.value = 0
	
func _export_spritesheet():
	_add_log_message("📦 Preparing spritesheet export...")
	progress_bar.value = 25
	
	if spritesheet_exporter == null:
		_add_log_message("❌ Spritesheet exporter not available!")
		progress_bar.value = 0
		return
	
	var success = _run_real_spritesheet_export()
	
	if success:
		_add_log_message("🎉 Spritesheet export completed successfully!")
		progress_bar.value = 100
		_add_log_message("📁 Spritesheet files saved to: res://export/")
		_list_exported_files()
	else:
		_add_log_message("❌ Spritesheet export failed!")
		progress_bar.value = 0

func _run_real_spritesheet_export() -> bool:
	_add_log_message("🔄 Running real spritesheet export process...")
	progress_bar.value = 50

	# Verificar se o diretório de exportação existe
	var export_utils = preload("res://addons/godot2sgdk/utils/export_utils.gd")
	if export_utils:
		export_utils.ensure_export_directory()
		_add_log_message("✅ Export directory ready")
	else:
		_add_log_message("❌ Export utilities not found")
		return false

	# Exportar spritesheet da cena atual
	var scene_root = get_tree().edited_scene_root
	if scene_root and spritesheet_exporter:
		if spritesheet_exporter.has_method("export_spritesheet_to_file"):
			_add_log_message("🎯 Calling export_spritesheet_to_file...")
			var success = spritesheet_exporter.export_spritesheet_to_file(scene_root, "res://export/spritesheet")
			progress_bar.value = 75
			
			if success:
				_add_log_message("✅ Spritesheet export successful!")
				return true
			else:
				_add_log_message("❌ Spritesheet export failed!")
				return false
		else:
			_add_log_message("❌ export_spritesheet_to_file method not found")
			return false

	_add_log_message("❌ No scene to export spritesheet from")
	return false

func _run_real_animation_export() -> bool:
	_add_log_message("🎞️ Running real animation export process...")
	progress_bar.value = 50

	# Verificar se o diretório de exportação existe
	var export_utils = preload("res://addons/godot2sgdk/utils/export_utils.gd")
	if export_utils:
		export_utils.ensure_export_directory()
		_add_log_message("✅ Export directory ready")
	else:
		_add_log_message("❌ Export utilities not found")
		return false

	# Exportar animações da cena atual
	var scene_root = get_tree().edited_scene_root
	if scene_root and animation_exporter:
		# Chamar método de exportação do animation_exporter
		if animation_exporter.has_method("export_animations_in_scene"):
			_add_log_message("🎯 Calling export_animations_in_scene...")
			var result = animation_exporter.export_animations_in_scene(scene_root, "res://export/animations.h")
			progress_bar.value = 75
	
			if result.get("success", false):
				_add_log_message("✅ Animation export successful!")
				return true
			else:
				_add_log_message("❌ Animation export failed: " + result.get("message", "Unknown error"))
				return false
		else:
			_add_log_message("❌ export_animations_in_scene method not found")
			return false

	_add_log_message("❌ No scene to export animations from")
	return false

func _run_real_export() -> bool:
	_add_log_message("🔧 Running real TileMap export process...")
	progress_bar.value = 50
	
	# Verificar se o diretório de exportação existe
	var export_utils = preload("res://addons/godot2sgdk/utils/export_utils.gd")
	if export_utils:
		export_utils.ensure_export_directory()
		_add_log_message("✅ Export directory ready")
	else:
		_add_log_message("❌ Export utilities not found")
		return false
	
	# Exportar cena atual
	var scene_root = get_tree().edited_scene_root
	if not scene_root:
		_add_log_message("❌ Export failed: No scene open")
		return false
		
	if _is_scene_empty(scene_root):
		_add_log_message("❌ Export failed: Scene is empty")
		return false

	if not map_exporter:
		_add_log_message("❌ Map exporter not available!")
		return false
		
	# Chamar método de exportação do map_exporter
	if map_exporter.has_method("export_scene_manually"):
		_add_log_message("🎯 Calling export_scene_manually...")
		map_exporter.export_scene_manually(scene_root)
		progress_bar.value = 75
		return true
	else:
		_add_log_message("❌ export_scene_manually method not found")
		return false
	
	_add_log_message("❌ No scene to export")
	return false

func _run_real_sprite_export() -> bool:
	_add_log_message("🎨 Running real sprite export process...")
	progress_bar.value = 50

	# Verificar se o diretório de exportação existe
	var export_utils = preload("res://addons/godot2sgdk/utils/export_utils.gd")
	if export_utils:
		export_utils.ensure_export_directory()
		_add_log_message("✅ Export directory ready")
	else:
		_add_log_message("❌ Export utilities not found")
		return false

	# ✅ CORREÇÃO: Usar diretório, não arquivo
	var export_dir = "res://export"  # ← DIRETÓRIO, não arquivo .h

	# Exportar sprites da cena atual
	var scene_root = get_tree().edited_scene_root
	if scene_root and sprite_exporter:
		# Chamar método de exportação do sprite_exporter
		if sprite_exporter.has_method("export_sprites_in_scene"):
			_add_log_message("🎯 Calling export_sprites_in_scene...")
			var result = sprite_exporter.export_sprites_in_scene(scene_root, export_dir)
			progress_bar.value = 75
	
			if result.get("success", false):
				_add_log_message("✅ Sprite export successful!")
				return true
			else:
				_add_log_message("❌ Sprite export failed: " + result.get("message", "Unknown error"))
				return false
		else:
			_add_log_message("❌ export_sprites_in_scene method not found")
			return false

	_add_log_message("❌ No scene to export sprites from")
	return false

func _list_exported_files():
	var dir = DirAccess.open("res://export/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var file_count = 0
		
		_add_log_message("📋 Generated files:")
		while file_name != "":
			if not dir.current_is_dir() and not file_name.begins_with("."):
				_add_log_message("   📄 " + file_name)
				file_count += 1
			file_name = dir.get_next()
		
		if file_count == 0:
			_add_log_message("   ❌ No files found in export directory!")
		else:
			_add_log_message("   ✅ Total: " + str(file_count) + " files")
	else:
		_add_log_message("❌ Cannot access export directory!")

func _display_validation_results(issues: Array) -> void:
	if issues.is_empty():
		_add_log_message("✅ No validation issues found!")
		_add_log_message("🎉 Scene is ready for export!")
		return
	
	var error_count = 0
	var warning_count = 0
	
	for issue in issues:
		if issue.get("type") == "error":
			error_count += 1
			_add_log_message("❌ ERROR: %s" % issue.get("message", ""))
		else:
			warning_count += 1
			_add_log_message("⚠️ WARNING: %s" % issue.get("message", ""))
		
		if issue.has("fix"):
			_add_log_message("   💡 Suggestion: %s" % issue["fix"])
		
		if issue.has("node"):
			var node = issue["node"]
			_add_log_message("   📍 Node: %s" % node.name)
	
	_add_log_message("")
	_add_log_message("📊 Validation complete: %d errors, %d warnings" % [error_count, warning_count])
	
	if error_count > 0:
		_add_log_message("❌ Please fix errors before exporting")
	elif warning_count > 0:
		_add_log_message("⚠️ Warnings found, but export can proceed")

func _add_log_message(message: String) -> void:
	if log_output:
		log_output.text += message + "\n"
		# Scroll to bottom - abordagem alternativa para Godot 4
		_scroll_to_bottom()
	print("[UI] " + message)  # Também log no console

func _scroll_to_bottom() -> void:
	if log_output:
		# Alternativa para scroll automático no Godot 4
		var scrollbar = log_output.get_v_scroll_bar()
		if scrollbar:
			scrollbar.value = scrollbar.max_value

func _clear_log() -> void:
	if log_output:
		log_output.text = ""

func _update_ui_from_config():
	if config_manager:
		var auto_validate = config_manager.get_setting("general", "auto_validate", true)
		if auto_validate:
			_add_log_message("🔔 Auto-validation is enabled")
		
		var export_path = config_manager.get_setting("general", "export_path", "res://export/")
		_add_log_message("📁 Export path: %s" % export_path)
		
		# Aplicar configurações de mobile
		var touch_friendly = config_manager.get_setting("mobile", "touch_friendly", true)
		if touch_friendly:
			_apply_touch_friendly_style()
	else:
		_add_log_message("⚠️ Configuration not loaded")

# Função para atualizar o progresso (pode ser chamada de outros scripts)
func update_progress(value: int, message: String = "") -> void:
	if progress_bar:
		progress_bar.value = value
	if message != "":
		_add_log_message(message)

# Função para limpar e resetar a interface
func reset_interface() -> void:
	_clear_log()
	progress_bar.value = 0
	_add_log_message("🔄 Godot2SGDK Ready")
	_add_log_message("👉 Open a scene and click 'Validate' to start")

# Chamado quando o plugin é inicializado
# LINHA ~280: Chamado quando o plugin é inicializado
func initialize() -> void:  # ✅ COM Z
	reset_interface()
	_add_log_message("✨ Godot2SGDK Plugin Initialized")
	_add_log_message("Version 1.0.0")
