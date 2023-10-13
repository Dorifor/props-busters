extends Node3D

signal server_disconnected

const Player = preload("res://assets/player/hunter.tscn")
const PropsPlayer = preload("res://assets/player/hider/hider.tscn")


func _ready():
	if not is_multiplayer_authority(): return
	
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	await get_tree().process_frame
	add_player(1)
	for player in Globals.PLAYER_DATA.keys():
		if (player != 1):
			add_prop_player(player)


func add_player(peer_id):
	if not is_multiplayer_authority(): return
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)


func add_prop_player(peer_id):
	if not is_multiplayer_authority(): return
	var player = PropsPlayer.instantiate()
	player.name = str(peer_id)
	add_child(player)
	
	
func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	Globals.PLAYER_DATA.clear()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://assets/ui/main_menu/main_menu.tscn")
