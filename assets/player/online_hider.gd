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
	var focused_mesh: MeshInstance3D = focused_prop.get_node("Mesh")
	var focused_collision: CollisionShape3D = focused_prop.get_node("Collision")
	scale = focused_prop.scale
	position.y = focused_prop.position.y
	
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

func request_removal_from_game_manager():
	if not is_multiplayer_authority():
		rpc_id(1, "remove_hider", self.get_instance_id())  
	else:
		Game_Manager.remove_hider(self.get_instance_id())
