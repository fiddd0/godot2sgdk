@tool
extends Window
class_name SettingsDialog

var config_manager: ConfigManager
var plugin

# Controles da UI
var export_path_edit: LineEdit
var auto_validate_check: CheckBox
var log_level_option: OptionButton
var multithreading_check: CheckBox
var compression_slider: HSlider
var output_format_option: OptionButton
var touch_friendly_check: CheckBox
var save_btn: Button
var cancel_btn: Button
var reset_btn: Button

func _init(plugin_ref, config_ref):
	plugin = plugin_ref
	config_manager = config_ref
	title = "Godot2SGDK Settings"
	size = Vector2i(600, 500)
	min_size = Vector2i(500, 400)
	
	_create_ui()

func _create_ui():
	var vbox = VBoxContainer.new()
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(vbox)
	
	# TabContainer para organizar as settings
	var tabs = TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(tabs)
	
	# ABA: General
	var general_tab = _create_general_tab()
	tabs.add_child(general_tab)
	tabs.set_tab_title(0, "General")
	
	# ABA: Performance
	var performance_tab = _create_performance_tab()
	tabs.add_child(performance_tab)
	tabs.set_tab_title(1, "Performance")
	
	# ABA: SGDK
	var sgdk_tab = _create_sgdk_tab()
	tabs.add_child(sgdk_tab)
	tabs.set_tab_title(2, "SGDK")
	
	# ABA: Mobile
	var mobile_tab = _create_mobile_tab()
	tabs.add_child(mobile_tab)
	tabs.set_tab_title(3, "Mobile")
	
	# Botões de ação
	var button_hbox = HBoxContainer.new()
	button_hbox.alignment = BoxContainer.ALIGNMENT_END
	
	reset_btn = Button.new()
	reset_btn.text = "Reset to Defaults"
	reset_btn.pressed.connect(_on_reset_pressed)
	button_hbox.add_child(reset_btn)
	
	cancel_btn = Button.new()
	cancel_btn.text = "Cancel"
	cancel_btn.pressed.connect(_on_cancel_pressed)
	button_hbox.add_child(cancel_btn)
	
	save_btn = Button.new()
	save_btn.text = "Save"
	save_btn.pressed.connect(_on_save_pressed)
	button_hbox.add_child(save_btn)
	
	vbox.add_child(button_hbox)
	
	_load_current_settings()

func _create_general_tab() -> ScrollContainer:
	var scroll = ScrollContainer.new()
	var vbox = VBoxContainer.new()
	scroll.add_child(vbox)
	
	# Export Path
	var export_hbox = HBoxContainer.new()
	var export_label = Label.new()
	export_label.text = "Export Path:"
	export_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	export_label.custom_minimum_size.x = 150
	export_hbox.add_child(export_label)
	
	export_path_edit = LineEdit.new()
	export_path_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	export_path_edit.placeholder_text = "res://export/"
	export_hbox.add_child(export_path_edit)
	
	var browse_btn = Button.new()
	browse_btn.text = "Browse"
	browse_btn.pressed.connect(_on_browse_export_path)
	export_hbox.add_child(browse_btn)
	
	vbox.add_child(export_hbox)
	
	# Auto Validate
	auto_validate_check = CheckBox.new()
	auto_validate_check.text = "Auto Validate before Export"
	vbox.add_child(auto_validate_check)
	
	# Auto Save
	var auto_save_check = CheckBox.new()
	auto_save_check.text = "Auto Save after Export"
	vbox.add_child(auto_save_check)
	
	# Log Level
	var log_hbox = HBoxContainer.new()
	var log_label = Label.new()
	log_label.text = "Log Level:"
	log_label.custom_minimum_size.x = 150
	log_hbox.add_child(log_label)
	
	log_level_option = OptionButton.new()
	log_level_option.add_item("Normal", 0)
	log_level_option.add_item("Verbose", 1)
	log_level_option.add_item("Minimal", 2)
	log_hbox.add_child(log_level_option)
	
	vbox.add_child(log_hbox)
	
	return scroll

func _create_performance_tab() -> ScrollContainer:
	var scroll = ScrollContainer.new()
	var vbox = VBoxContainer.new()
	scroll.add_child(vbox)
	
	multithreading_check = CheckBox.new()
	multithreading_check.text = "Enable Multithreading"
	vbox.add_child(multithreading_check)
	
	var compression_hbox = HBoxContainer.new()
	var compression_label = Label.new()
	compression_label.text = "Compression Level:"
	compression_label.custom_minimum_size.x = 150
	compression_hbox.add_child(compression_label)
	
	compression_slider = HSlider.new()
	compression_slider.min_value = 0
	compression_slider.max_value = 3
	compression_slider.step = 1
	compression_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	compression_hbox.add_child(compression_slider)
	
	var compression_value = Label.new()
	compression_value.custom_minimum_size.x = 30
	compression_hbox.add_child(compression_value)
	compression_slider.value_changed.connect(func(value): compression_value.text = str(value))
	
	vbox.add_child(compression_hbox)
	
	return scroll

func _create_sgdk_tab() -> ScrollContainer:
	var scroll = ScrollContainer.new()
	var vbox = VBoxContainer.new()
	scroll.add_child(vbox)
	
	var format_hbox = HBoxContainer.new()
	var format_label = Label.new()
	format_label.text = "Output Format:"
	format_label.custom_minimum_size.x = 150
	format_hbox.add_child(format_label)
	
	output_format_option = OptionButton.new()
	output_format_option.add_item("C Header (.h)", 0)
	output_format_option.add_item("Binary", 1)
	output_format_option.add_item("JSON", 2)
	format_hbox.add_child(output_format_option)
	
	vbox.add_child(format_hbox)
	
	var makefile_check = CheckBox.new()
	makefile_check.text = "Generate Makefile"
	vbox.add_child(makefile_check)
	
	var optimize_check = CheckBox.new()
	optimize_check.text = "Optimize for Size"
	vbox.add_child(optimize_check)
	
	return scroll

func _create_mobile_tab() -> ScrollContainer:
	var scroll = ScrollContainer.new()
	var vbox = VBoxContainer.new()
	scroll.add_child(vbox)
	
	touch_friendly_check = CheckBox.new()
	touch_friendly_check.text = "Touch-Friendly Interface"
	vbox.add_child(touch_friendly_check)
	
	var large_buttons_check = CheckBox.new()
	large_buttons_check.text = "Large Buttons"
	vbox.add_child(large_buttons_check)
	
	var auto_rotate_check = CheckBox.new()
	auto_rotate_check.text = "Auto Rotate UI"
	vbox.add_child(auto_rotate_check)
	
	var performance_check = CheckBox.new()
	performance_check.text = "Performance Mode"
	vbox.add_child(performance_check)
	
	return scroll

func _load_current_settings():
	# General
	export_path_edit.text = config_manager.get_setting("general", "export_path", "res://export/")
	auto_validate_check.button_pressed = config_manager.get_setting("general", "auto_validate", true)
	log_level_option.select(config_manager.get_setting("general", "log_level", 0))
	
	# Performance
	multithreading_check.button_pressed = config_manager.get_setting("performance", "multithreading", true)
	compression_slider.value = config_manager.get_setting("performance", "compression_level", 1)
	
	# SGDK
	output_format_option.select(config_manager.get_setting("sgdk", "output_format", 0))
	
	# Mobile
	touch_friendly_check.button_pressed = config_manager.get_setting("mobile", "touch_friendly", true)

func _on_save_pressed():
	# Save settings
	config_manager.set_setting("general", "export_path", export_path_edit.text)
	config_manager.set_setting("general", "auto_validate", auto_validate_check.button_pressed)
	config_manager.set_setting("general", "log_level", log_level_option.get_selected_id())
	
	config_manager.set_setting("performance", "multithreading", multithreading_check.button_pressed)
	config_manager.set_setting("performance", "compression_level", compression_slider.value)
	
	config_manager.set_setting("sgdk", "output_format", output_format_option.get_selected_id())
	
	config_manager.set_setting("mobile", "touch_friendly", touch_friendly_check.button_pressed)
	
	if config_manager.save_config():
		plugin._add_log_message("⚙️ Settings saved successfully")
		hide()
	else:
		plugin._add_log_message("❌ Error saving settings")

func _on_cancel_pressed():
	hide()

func _on_reset_pressed():
	config_manager.reset_to_defaults()
	_load_current_settings()
	plugin._add_log_message("⚙️ Settings reset to defaults")

func _on_browse_export_path():
	# Implementar file dialog se necessário
	plugin._add_log_message("📁 Browse export path clicked")
