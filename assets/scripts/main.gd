extends Node3D
#
#@onready var main_menu = $CanvasLayer/MainMenu
#@onready var adress_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AdressEntry
#
#const hunter_scene = preload("res://assets/player/hunter.tscn")
#const PORT = 6969
#var enet_peer = ENetMultiplayerPeer.new()
#
#func _on_host_button_pressed():
#	main_menu.hide
#	enet_peer.create_server(PORT)
#	multiplayer.multiplayer_peer = enet_peer
#	add_player(multiplayer.get_unique_id())
#
#func _on_join_button_pressed():
#	pass # Replace with function body.
#
#func add_player(peer_id):
#	var hunter = hunter_scene.instantiate()
#	hunter.name = str(peer_id)
#	add_child(hunter)
#
