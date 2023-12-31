extends Node3D

signal server_disconnected

@export var hunter_scene: PackedScene
@export var hider_scene: PackedScene
@export var spawn_path_follow: PathFollow3D
@onready var main_menu_scene = "res://assets/ui/main menu/main_menu.tscn"
@export var multiplayer_spawner: MultiplayerSpawner

@export var player_nodes: Array[Node] = []

func mettreAJourVariablePartagee():
	_on_mettreAJourVariablePartagee.rpc()


@rpc("call_local")
func _on_mettreAJourVariablePartagee():
	Globals.NBRPROP += 1


func _ready():
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	if not is_multiplayer_authority():
		return
#	$Control.hide()
	await get_tree().process_frame 

	var rng = RandomNumberGenerator.new()
	var player_keys = []
	for player in Globals.PLAYER_DATA.keys():
		player_keys.append(player)

	var player_index = rng.randi_range(0, player_keys.size() - 1)
	var selected_player = player_keys[player_index]

	for player in player_keys:
		if player == selected_player:
			if Globals.FORCE_HIDER_SINGLE_PLAYER: 
				add_prop_player(player)
				continue
			add_player(player)
		else:
			add_prop_player(player)
			mettreAJourVariablePartagee()


func add_player(peer_id):
	if not is_multiplayer_authority(): return
	var new_player = multiplayer_spawner.spawn({ "peer_id": peer_id, "player_type": Constants.PlayerType.HUNTER_TYPE })
	player_nodes.append(new_player)


func add_prop_player(peer_id):
	if not is_multiplayer_authority(): return
	var new_player = multiplayer_spawner.spawn({ "peer_id": peer_id, "player_type": Constants.PlayerType.HIDER_TYPE })
	player_nodes.append(new_player)


func _on_player_disconnected(player_peer_id):
	if not is_multiplayer_authority(): return
	var disconnected_player_node: Node = player_nodes.filter(func(node): return node.name == str(player_peer_id))[0]
	disconnected_player_node.queue_free()


func _on_server_disconnected():
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	Globals.PLAYER_DATA.clear()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file(main_menu_scene)
	

func _process(delta):
#	if Globals.NBRPROP <= 0:
#		$Control.show()
	pass
