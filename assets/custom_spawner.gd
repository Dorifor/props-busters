extends MultiplayerSpawner

@export var hider_scene: PackedScene
@export var hunter_scene: PackedScene
@export var spawn_path_follow: PathFollow3D

func _init() -> void:
	spawn_function = _spawn_custom

func _spawn_custom(data: Variant) -> Node:
	randomize()
	spawn_path_follow.progress_ratio = randf()
	
	var player = null
	if data.player_type == Constants.PlayerType.HIDER_TYPE:
		player = hider_scene.instantiate() as Hider
	else:
		player = hunter_scene.instantiate() as Hunter
	player.name = str(data.peer_id)
	player.position = spawn_path_follow.position
	
	return player
