extends Node3D

signal server_disconnected

@export var hunter_scene: PackedScene
@export var hider_scene: PackedScene
@export var spawn_path_follow: PathFollow3D
@export var main_menu_scene: PackedScene
@export var multiplayer_spawner: MultiplayerSpawner

func _ready():
	if not is_multiplayer_authority(): return
	print("MAP 1: ", multiplayer.get_unique_id())
	
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	await get_tree().process_frame
#	add_prop_player(1)
	add_player(1)
	for player in Globals.PLAYER_DATA.keys():
		if (player != 1):
			add_prop_player(player)


func add_player(peer_id):
	if not is_multiplayer_authority(): return
	multiplayer_spawner.spawn({ "peer_id": peer_id, "player_type": Constants.PlayerType.HUNTER_TYPE })


func add_prop_player(peer_id):
	if not is_multiplayer_authority(): return
	multiplayer_spawner.spawn({ "peer_id": peer_id, "player_type": Constants.PlayerType.HIDER_TYPE })


func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	Globals.PLAYER_DATA.clear()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	print(main_menu_scene)
	get_tree().change_scene_to_packed(main_menu_scene)
