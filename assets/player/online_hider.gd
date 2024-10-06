extends Hider
class_name OnlineHider

var player_list: PlayerListMenu

func _ready() -> void:
	if not is_multiplayer_authority(): return
	super()

func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	super(event)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	super(delta)

func apply_mouse_movement(event):
	if player_list.visible: return
	super(event)

func transform_into_prop():
	super()
	var focused_mesh: MeshInstance3D = focused_prop.get_node("Mesh")
	var focused_collision: CollisionShape3D = focused_prop.get_node("Collision")
	
	var prop_change_payload = {
		"mesh": {
			"path": focused_mesh.mesh.resource_path,
			"y": focused_mesh.position.y
		},
		"collision": {
			"path": focused_collision.shape.resource_path,
			"y": focused_collision.position.y
		}
	}
	
	propagate_prop_change.rpc(prop_change_payload)

func disable_power(just_transformed: bool = false):
	if not is_multiplayer_authority(): return
	super(just_transformed)


@rpc("call_local")
func propagate_prop_change(prop_change_dict):
#	if multiplayer.get_unique_id() == multiplayer.get_remote_sender_id():
#		return
	
	var mesh = load(prop_change_dict.mesh.path)
	var shape = load(prop_change_dict.collision.path)
	
	hider_mesh.mesh = mesh
	hider_mesh.position.y = prop_change_dict.mesh.y
	hider_collision.shape = shape
	hider_collision.position.y = prop_change_dict.collision.y
