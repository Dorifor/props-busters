extends Control

@export var online_panel: Control
@export var settings_panel: Control


func _on_play_pressed():
	hide()
	online_panel.show()


func _on_option_pressed():
	settings_panel.show()


func _on_quit_pressed():
	get_tree().quit()
