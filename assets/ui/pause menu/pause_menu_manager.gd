extends SettingsBase


func _on_horizontal_slider_value_changed(value):
	Globals.HORIZONTAL_SENSIBILITY_VALUE = value


func _on_vertical_slider_value_changed(value):
	Globals.VERTICAL_SENSIBILITY_VALUE = value


func _on_return_button_pressed():
	visible = false
	Globals.IS_GAME_PAUSED = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_quit_button_pressed():
	get_tree().quit()
