extends BaseCharacter
class_name Hider

var is_focusing_prop: bool = false
var focused_prop: StaticBody3D = null
var is_short: bool = false
var is_ability_available: bool = true

var is_ghost: bool = false

var scale_factor = 1
var camera_long_distance = 3

@export var raycast: RayCast3D
@export var ability_timer: Timer
@export var ability_cooldown_timer: Timer

@export var hider_mesh: MeshInstance3D
@export var hider_collision: CollisionShape3D

@export var hider_ui: Control
@export var interact_ui: Control
@export var ability_progress_bar: TextureProgressBar


func _on_bullet_colliding():
	if is_ghost == false:
		is_ghost = true
		transform_into_ghost()
	else :
		UpdateNumberHider()
		queue_free()
	# TODO: Kill the player or smth


func _ready():
	super()
	is_ghost = false
	hider_ui.show()


func _input(event):
	super(event)
	
	if is_focusing_prop and event is InputEventKey and event.is_action_pressed("interact") and is_ghost == false:
		transform_into_prop()
		disable_power(true)
	
	if event is InputEventKey and event.is_action("shortening") and not is_short and is_ability_available and is_ghost == false:
		activate_power()


func _process(_delta):
	super(_delta)
	
	if raycast.is_colliding() and is_ghost == false:
		var collider = raycast.get_collider()
		if collider is StaticBody3D and collider.has_meta("can_transform"):
			interact_ui.visible = true
			is_focusing_prop = true
			focused_prop = collider
	else:
		focused_prop = null
		is_focusing_prop = false
		interact_ui.visible = false


func apply_mouse_movement(event: InputEvent):
	if event is InputEventMouseMotion:
		var x_rotation = deg_to_rad(event.relative.x * Globals.HORIZONTAL_SENSIBILITY_VALUE)
		if Input.is_action_pressed("hider_rotate"):
			rig.rotate_y(-x_rotation)
		else:
			rotate_y(-x_rotation)
			rig.rotate_y(x_rotation)
			camera_mount.rotate_x((deg_to_rad(-event.relative.y * Globals.VERTICAL_SENSIBILITY_VALUE)))
			var camera_rotation = camera_mount.rotation_degrees
			camera_rotation.x = clamp(camera_rotation.x, -30, 30)
			camera_mount.rotation_degrees = camera_rotation


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
	
	propagate_prop_change.rpc(prop_change_payload)


func start_ability_timeout_progress():
	if not is_multiplayer_authority(): return
	var tween = get_tree().create_tween()
	tween.tween_property(ability_progress_bar, "value", 0, ability_timer.wait_time)


func start_ability_cooldown_progress():
	if not is_multiplayer_authority(): return
	var tween = get_tree().create_tween()
	tween.tween_property(ability_progress_bar, "value", 100, ability_cooldown_timer.wait_time)


func activate_power():
	if not is_multiplayer_authority(): return
	start_ability_timeout_progress()
	
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
	start_ability_cooldown_progress()
	is_short = false
	speed_factor = 1
	camera.position.y -= 3
	camera.position.z -= 3
	if just_transformed: return
	scale *= 2
	# center origin, so clipping when scaling back, need to translate half size
	position.y += hider_mesh.get_aabb().size.y / 3


func _on_ability_timer_timeout():
	disable_power()


func _on_ability_cooldown_timeout():
	is_ability_available = true


func transform_into_ghost():
	$Visuals/Mesh.hide()
	$Visuals/MESH_Ghost.show()
	$GhostWaitTime.start()


func _on_ghost_wait_time_timeout():
	is_ghost = false
	$Visuals/Mesh.show()
	$Visuals/MESH_Ghost.hide()


func UpdateNumberHider():
	_on_UpdateNumberHiderOnline.rpc()


@rpc("call_local")
func _on_UpdateNumberHiderOnline():
	Globals.NBRPROP -= 1
