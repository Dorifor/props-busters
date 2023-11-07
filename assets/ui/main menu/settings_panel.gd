class_name SettingsBase
extends Control

@export var music_player: AudioStreamPlayer
@export var volume_slider: HSlider
@export var screen_resolution_options: OptionButton
@export var fullscreen_toggle: CheckButton
@export var shader_toggle: CheckButton
@export var shader: Control


func _ready() -> void:
	_on_volume_slider_value_changed(Globals.VOLUME_VALUE)
	fullscreen_toggle.set_pressed_no_signal(Globals.IS_FULLSCREEN)
	shader_toggle.set_pressed_no_signal(Globals.IS_SHADER_ON)
	
	screen_resolution_options.select(Globals.SELECTED_RESOLUTION_INDEX)
	shader.visible = Globals.IS_SHADER_ON
	volume_slider.value = Globals.VOLUME_VALUE


func _on_button_pressed() -> void:
	hide()


func _on_volume_slider_value_changed(value: float) -> void:
	Globals.VOLUME_VALUE = value
	music_player.volume_db = value


func _on_fullscreen_check_button_toggled(button_pressed: bool) -> void:
	var new_mode = Window.MODE_FULLSCREEN if button_pressed else Window.MODE_WINDOWED
	Globals.IS_FULLSCREEN = button_pressed
	get_window().mode = new_mode


func _on_shader_check_button_toggled(button_pressed: bool) -> void:
	Globals.IS_SHADER_ON = button_pressed
	shader.visible = button_pressed


func _on_screen_resolution_options_item_selected(index: int) -> void:
	var selected_resolution: String = screen_resolution_options.get_item_text(index)
	var parsed_resolution = selected_resolution.split("x")
	var new_window_size = Vector2i(int(parsed_resolution[0]), int(parsed_resolution[1]))
	get_window().mode = Window.MODE_WINDOWED
	get_window().size = new_window_size
	fullscreen_toggle.button_pressed = false
	Globals.SELECTED_RESOLUTION_INDEX = index
