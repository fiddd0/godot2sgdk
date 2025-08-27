@tool
extends VBoxContainer
class_name PaletteEditor

signal palette_changed

var palette_manager: PaletteManager
var color_buttons: Array = []
var hex_labels: Array = []  # ✅ Array para guardar referências

func _ready():
	palette_manager = PaletteManager.new()
	_create_palette_ui()
	_load_default_palette()

func _create_palette_ui():
	# Título
	var title = Label.new()
	title.text = "Mega Drive Palette Editor (16 colors)"
	title.add_theme_font_size_override("font_size", 16)
	add_child(title)
	
	add_child(HSeparator.new())
	
	# Grid de cores
	var grid = GridContainer.new()
	grid.columns = 8
	grid.custom_minimum_size = Vector2(500, 200)
	add_child(grid)
	
	for i in range(16):
		var vbox = VBoxContainer.new()
		vbox.custom_minimum_size = Vector2(60, 80)
		
		# Índice da cor
		var index_label = Label.new()
		index_label.text = "Color %d" % i
		index_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(index_label)
		
		# Botão de cor
		var color_btn = ColorPickerButton.new()
		color_btn.custom_minimum_size = Vector2(50, 50)
		color_btn.color = palette_manager.get_color_by_index(i)
		color_btn.color_changed.connect(_on_color_changed.bind(i))
		vbox.add_child(color_btn)
		
		# Valor HEX - ✅ GUARDAR REFERÊNCIA
		var hex_label = Label.new()
		hex_label.name = "hex_%d" % i
		hex_label.text = _color_to_hex(palette_manager.get_color_by_index(i))
		hex_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hex_label.add_theme_font_size_override("font_size", 10)
		vbox.add_child(hex_label)
		
		grid.add_child(vbox)
		color_buttons.append(color_btn)
		hex_labels.append(hex_label)  # ✅ Guardar referência
	
	add_child(HSeparator.new())
	
	# Botões de controle
	var control_hbox = HBoxContainer.new()
	control_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var save_btn = Button.new()
	save_btn.text = "💾 Save Palette"
	save_btn.pressed.connect(_on_save_pressed)
	control_hbox.add_child(save_btn)
	
	var reset_btn = Button.new()
	reset_btn.text = "🔄 Reset to Default"
	reset_btn.pressed.connect(_on_reset_pressed)
	control_hbox.add_child(reset_btn)
	
	add_child(control_hbox)

func _load_default_palette():
	# Tentar carregar paleta salva
	var config_utils = load("res://addons/godot2sgdk/utils/config_utils.gd")
	if config_utils:
		var saved_palette = config_utils.load_palette_config()
		if not saved_palette.is_empty():
			palette_manager.load_custom_palette(saved_palette)
	_update_color_buttons()

func _on_color_changed(color: Color, index: int):
	palette_manager.current_palette[index] = color
	_update_hex_label(index, color)
	palette_changed.emit()

func _update_hex_label(index: int, color: Color):
	# ✅ USAR ARRAY DE REFERÊNCIAS
	if index < hex_labels.size():
		hex_labels[index].text = _color_to_hex(color)

func _color_to_hex(color: Color) -> String:
	return "#%02X%02X%02X" % [color.r8, color.g8, color.b8]

func _on_save_pressed():
	var export_path = "res://export/palette.h"
	if palette_manager.save_palette_to_file(export_path):
		print("✅ Palette saved to: ", export_path)
		
		# Salvar também no config
		var config_utils = load("res://addons/godot2sgdk/utils/config_utils.gd")
		if config_utils:
			config_utils.save_palette_config(palette_manager.current_palette)
	else:
		print("❌ Failed to save palette")

func _on_reset_pressed():
	palette_manager.reset_to_default_palette()
	_update_color_buttons()
	palette_changed.emit()

func _update_color_buttons():
	for i in range(16):
		if i < color_buttons.size():
			var color = palette_manager.get_color_by_index(i)
			color_buttons[i].color = color
			_update_hex_label(i, color)

func get_palette_manager() -> PaletteManager:
	return palette_manager
