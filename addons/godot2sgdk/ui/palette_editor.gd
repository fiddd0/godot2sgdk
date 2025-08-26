@tool
extends VBoxContainer
class_name PaletteEditor

signal palette_changed

var palette_manager: PaletteManager
var color_buttons: Array = []

func _ready():
	palette_manager = PaletteManager.new()
	_create_palette_ui()

func _create_palette_ui():
	# Título
	var title = Label.new()
	title.text = "Mega Drive Palette Editor (16 colors)"
	add_child(title)
	
	# Grid de cores
	var grid = GridContainer.new()
	grid.columns = 8
	grid.custom_minimum_size = Vector2(400, 100)
	add_child(grid)
	
	for i in range(16):
		var hbox = HBoxContainer.new()
		hbox.custom_minimum_size = Vector2(50, 50)
		
		# Índice da cor
		var index_label = Label.new()
		index_label.text = str(i)
		index_label.custom_minimum_size = Vector2(20, 20)
		hbox.add_child(index_label)
		
		# Botão de cor
		var color_btn = ColorPickerButton.new()
		color_btn.color = palette_manager.get_color_by_index(i)
		color_btn.custom_minimum_size = Vector2(30, 30)
		color_btn.color_changed.connect(_on_color_changed.bind(i))
		hbox.add_child(color_btn)
		
		grid.add_child(hbox)
		color_buttons.append(color_btn)
	
	# Botões de controle
	var control_hbox = HBoxContainer.new()
	
	var save_btn = Button.new()
	save_btn.text = "Save Palette"
	save_btn.pressed.connect(_on_save_pressed)
	control_hbox.add_child(save_btn)
	
	var reset_btn = Button.new()
	reset_btn.text = "Reset to Default"
	reset_btn.pressed.connect(_on_reset_pressed)
	control_hbox.add_child(reset_btn)
	
	add_child(control_hbox)

func _on_color_changed(color: Color, index: int):
	palette_manager.current_palette[index] = color
	palette_changed.emit()

func _on_save_pressed():
	var export_path = "res://export/palette.h"
	if palette_manager.save_palette_to_file(export_path):
		print("✅ Palette saved to: ", export_path)
	else:
		print("❌ Failed to save palette")

func _on_reset_pressed():
	palette_manager.reset_to_default_palette()
	_update_color_buttons()
	palette_changed.emit()

func _update_color_buttons():
	for i in range(16):
		if i < color_buttons.size():
			color_buttons[i].color = palette_manager.get_color_by_index(i)

func get_palette_manager() -> PaletteManager:
	return palette_manager
