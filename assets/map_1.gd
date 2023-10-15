extends Node3D

signal server_disconnected

@export var hunter_scene: PackedScene
@export var hider_scene: PackedScene
@export var spawn_path_follow: PathFollow3D
@onready var main_menu_scene = "res://assets/ui/main menu/main_menu.tscn"
@export var multiplayer_spawner: MultiplayerSpawner

func _ready():
	multiplayer.server_disconnected.connect(_on_server_disconnected)

	if not is_multiplayer_authority():
		return

	print("MAP 1: ", multiplayer.get_unique_id())
	await get_tree().process_frame 

	var rng = RandomNumberGenerator.new()
	var player_keys = []
	for player in Globals.PLAYER_DATA.keys():
		player_keys.append(player)

	var player_index = rng.randi_range(0, player_keys.size() - 1)
	var selected_player = player_keys[player_index]

	for player in player_keys:
		if player == selected_player:
			add_player(player)
		else:
			add_prop_player(player) 

func add_player(peer_id):
	if not is_multiplayer_authority(): return
	multiplayer_spawner.spawn({ "peer_id": peer_id, "player_type": Constants.PlayerType.HUNTER_TYPE })


func add_prop_player(peer_id):
	if not is_multiplayer_authority(): return
	multiplayer_spawner.spawn({ "peer_id": peer_id, "player_type": Constants.PlayerType.HIDER_TYPE })


func _on_server_disconnected():
	print("pu server")
	multiplayer.multiplayer_peer = null
	Globals.PLAYER_DATA.clear()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file(main_menu_scene)
