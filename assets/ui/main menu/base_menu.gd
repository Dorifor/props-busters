extends Control

@export var online_panel: Control


func _on_play_pressed():
	hide()
	online_panel.show()


func _on_option_pressed():
	pass # Replace with function body.


func _on_quit_pressed():
	get_tree().quit()
