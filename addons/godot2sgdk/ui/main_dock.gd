@tool
extends VBoxContainer

var plugin: EditorPlugin
var config: RefCounted
# LINHA 6: Adicionar variável
var palette_editor: PaletteEditor
# LINHA 7: Adicionar variável
var animation_exporter: RefCounted
var map_exporter: RefCounted
var sprite_exporter: RefCounted

# Referências para os nodes da UI
var export_btn: Button
var sprite_btn: Button
var validate_btn: Button
var settings_btn: Button
var log_output: TextEdit
var progress_bar: ProgressBar

func _ready():
	# Criar interface básica programaticamente
	var hbox = HBoxContainer.new()
	hbox.name = "ButtonContainer"
	
	export_btn = Button.new()
	export_btn.name = "ExportBtn"
	export_btn.text = "Export TileMaps"
	export_btn.pressed.connect(_on_export_pressed)
	
	# Botão para exportar sprites
	sprite_btn = Button.new()
	sprite_btn.name = "SpriteBtn"
	sprite_btn.text = "Export Sprites"
	sprite_btn.pressed.connect(_on_sprite_export_pressed)

	# NO HBOX EXISTENTE, ADICIONAR APÓS O BOTÃO DE SPRITES:
	# NOVO BOTÃO PARA ANIMAÇÕES
	var anim_btn = Button.new()
	anim_btn.name = "AnimBtn"
	anim_btn.text = "Export Animations"
	anim_btn.pressed.connect(_on_animation_export_pressed) # NOVO MÉTODO

	
	validate_btn = Button.new()
	validate_btn.name = "ValidateBtn"
	validate_btn.text = "Validate"
	validate_btn.pressed.connect(_on_validate_pressed)
	
	settings_btn = Button.new()
	settings_btn.name = "SettingsBtn"
	settings_btn.text = "Settings"
	settings_btn.pressed.connect(_on_settings_pressed)
	
	hbox.add_child(export_btn)
	hbox.add_child(sprite_btn)
	hbox.add_child(anim_btn) # ADICIONAR AO HBOX
	hbox.add_child(validate_btn)
	hbox.add_child(settings_btn)
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
	# Carregar exporter	
	_load_animation_exporter()
		
	# Configurar interface baseada nas configurações
	_update_ui_from_config()
	
	print("✅ MainDock initialized")
	
	_create_palette_ui()

	
func _load_map_exporter():
	var map_exporter_script = load("res://addons/godot2sgdk/core/map_exporter.gd")
	if map_exporter_script:
		map_exporter = map_exporter_script.new()  # ✅ CORRETO
		_add_log_message("✅ MapExporter loaded successfully")
	else:
		_add_log_message("❌ Failed to load MapExporter")

func _load_sprite_exporter():
	var sprite_exporter_script = load("res://addons/godot2sgdk/core/sprite_exporter.gd")
	if sprite_exporter_script:
		sprite_exporter = sprite_exporter_script.new() # ✅ CORRETO
		_add_log_message("✅ SpriteExporter loaded successfully")
	else:
		_add_log_message("❌ Failed to load SpriteExporter")

# LINHA 85: Novo método de carregamento
func _load_animation_exporter():
	var animation_exporter_script = load("res://addons/godot2sgdk/core/animation_exporter.gd")
	if animation_exporter_script:
		animation_exporter = animation_exporter_script.new()
		_add_log_message("✅ AnimationExporter loaded successfully")
	else:
		_add_log_message("❌ Failed to load AnimationExporter")

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
	
	# Executar exportação de sprites
	_export_sprites()

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

func _on_validate_pressed():
	_clear_log()
	_add_log_message("🔍 Validating scene...")
	var issues = _validate_current_scene()
	_display_validation_results(issues)

func _on_settings_pressed():
	_add_log_message("⚙️ Settings button pressed")
	# TODO: Implementar diálogo de configurações

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
		# Retorna array vazio SEM mensagem - a UI já mostra que não há cena
		return []

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
		
		# Listar arquivos gerados
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
	
	# ADICIONAR APÓS _run_real_sprite_export():
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
	if scene_root and map_exporter:
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

	# Exportar sprites da cena atual
	var scene_root = get_tree().edited_scene_root
	if scene_root and sprite_exporter:
		# Chamar método de exportação do sprite_exporter
		if sprite_exporter.has_method("export_sprites_in_scene"):
			_add_log_message("🎯 Calling export_sprites_in_scene...")
			var result = sprite_exporter.export_sprites_in_scene(scene_root, "res://export/sprites.h")
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
	# Atualizar UI baseado nas configurações
	if config:
		var auto_validate = config.get_setting("general", "auto_validate")
		if auto_validate:
			_add_log_message("🔔 Auto-validation is enabled")
		
		var export_path = config.get_setting("general", "export_path")
		_add_log_message("📁 Export path: %s" % export_path)
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
