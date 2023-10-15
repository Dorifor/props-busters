extends BaseCharacter
class_name Hider

var is_focusing_prop: bool = false
var focused_prop: StaticBody3D = null
var is_short: bool = false
var is_ability_available: bool = true

var scale_factor = 1
var camera_long_distance = 3

@export var raycast: RayCast3D
@export var ability_timer: Timer
@export var ability_cooldown_timer: Timer

@export var hider_mesh: MeshInstance3D
@export var hider_collision: CollisionShape3D

@export var interact_ui: Control


func _on_bullet_colliding():
	print("OUCH")
	# TODO: Kill the player or smth


func _ready():
	super()
	if not is_multiplayer_authority(): return
	interact_ui = get_tree().get_root().get_node("Main Scene/Interact")
#	position = base_position
	print("position: ", multiplayer.get_unique_id(), " ", position)


func _input(event):
	super(event)
	if not is_multiplayer_authority(): return
	
	if is_focusing_prop and event is InputEventKey and event.is_action_pressed("interact"):
		transform_into_prop()
		disable_power(true)
	
	if event is InputEventKey and event.is_action("shortening") and not is_short and is_ability_available:
		activate_power()


func _process(_delta):
	super(_delta)
	if not is_multiplayer_authority(): return
	
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider is StaticBody3D:
			interact_ui.visible = true
			is_focusing_prop = true
			focused_prop = collider
	else:
		focused_prop = null
		is_focusing_prop = false
		interact_ui.visible = false


@rpc("call_local")
func propage_prop_change(prop_change_dict):
#	if multiplayer.get_unique_id() == multiplayer.get_remote_sender_id():
#		return
	
	var mesh = load(prop_change_dict.mesh.path)
	var shape = load(prop_change_dict.collision.path)
	
	hider_mesh.mesh = mesh
	hider_mesh.position.y = prop_change_dict.mesh.y
	hider_collision.shape = shape
	hider_collision.position.y = prop_change_dict.collision.y


func transform_into_prop():
	if not is_multiplayer_authority(): return
	
	var focused_mesh: MeshInstance3D = focused_prop.get_node("Mesh")
	var focused_collision: CollisionShape3D = focused_prop.get_node("Collision")
#	hider_mesh.mesh = focused_mesh.mesh
#	hider_mesh.position.y = focused_mesh.position.y
#	hider_collision.shape = focused_collision.shape
#	hider_collision.position.y = focused_collision.position.y
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
	
	propage_prop_change.rpc(prop_change_payload)


func activate_power():
	if not is_multiplayer_authority(): return
	
	is_short = true
	scale /= 2
	speed_factor = 3
	camera.position.y += 3
	camera.position.z += 3
	is_ability_available = false
	ability_timer.start()


func disable_power(just_transformed: bool = false):
	if not is_multiplayer_authority(): return
	
	if not is_short: return
	ability_timer.stop()
	ability_cooldown_timer.start()
	is_short = false
	speed_factor = 1
	camera.position.y -= 3
	camera.position.z -= 3
	if just_transformed: return
	scale *= 2


func _on_ability_timer_timeout():
	disable_power()


func _on_ability_cooldown_timeout():
	is_ability_available = true
