extends Control

@export var music_player: AudioStreamPlayer
@export var screen_resolution_options: OptionButton
@export var fullscreen_toggle: CheckButton
@export var shader: Control

func _on_button_pressed() -> void:
	hide()


func _on_volume_slider_value_changed(value: float) -> void:
	Globals.VOLUME_VALUE = value
	music_player.volume_db = value


func _on_fullscreen_check_button_toggled(button_pressed: bool) -> void:
	var new_mode = Window.MODE_FULLSCREEN if button_pressed else Window.MODE_WINDOWED
	get_window().mode = new_mode


func _on_shader_check_button_toggled(button_pressed: bool) -> void:
	shader.visible = button_pressed


func _on_screen_resolution_options_item_selected(index: int) -> void:
	var selected_resolution: String = screen_resolution_options.get_item_text(index)
	var parsed_resolution = selected_resolution.split("x")
	var new_window_size = Vector2i(int(parsed_resolution[0]), int(parsed_resolution[1]))
	get_window().mode = Window.MODE_WINDOWED
	get_window().size = new_window_size
	fullscreen_toggle.button_pressed = false
