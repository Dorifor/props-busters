extends Node3D

signal server_disconnected

@export var hunter_scene: PackedScene
@export var hider_scene: PackedScene
@export var spawn_path_follow: PathFollow3D
@export var main_menu_scene: PackedScene
@export var spawn1: Marker3D
@export var spawn2: Marker3D

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
	var player = hunter_scene.instantiate()
	spawn_path_follow.progress_ratio = randf()
	player.position = spawn_path_follow.position
	player.name = str(peer_id)
	add_child(player)


func add_prop_player(peer_id):
	if not is_multiplayer_authority(): return
	randomize()
	var player = hider_scene.instantiate()
	# Là j'essaie de faire spawn sur le path à un endroit random
#	spawn_path_follow.progress_ratio = randf()
	player.name = str(peer_id)
	add_child(player)
	await get_tree().create_timer(3).timeout # j'ai tente avec un timer, ca change r
	player.position = spawn1.position


func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	Globals.PLAYER_DATA.clear()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_packed(main_menu_scene)
