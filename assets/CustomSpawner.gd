extends MultiplayerSpawner

@export var player: PackedScene

func _init() -> void:
	pass
#	spawn_function = _spawn_custom

func _spawn_custom(data: Variant) -> Node:
#  var scene: Player = player.instantiate() as Player
#  scene.peer_id = data.peer_id
#  scene.initial_transform = data.initial_transform
#  # Lots of other helpful init things you can do here: e.g.
#  scene.is_master = multiplayer.get_unique_id() == data.peer_id
#  scene.get_node('PlayerNetworking').set_multiplayer_authority(data.peer_id)
#
#  return scene
