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
	
	interact_ui.visible = raycast.is_colliding()
	is_focusing_prop = raycast.is_colliding()
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		focused_prop = collider


func transform_into_prop():
	if not is_multiplayer_authority(): return
	
	var focused_mesh: MeshInstance3D = focused_prop.get_node("Mesh")
	var focused_collision: CollisionShape3D = focused_prop.get_node("Collision")
	hider_mesh.mesh = focused_mesh.mesh
	hider_mesh.position.y = focused_mesh.position.y
	hider_collision.shape = focused_collision.shape
	hider_collision.position.y = focused_collision.position.y
	scale = focused_prop.scale
	position.y = focused_prop.position.y


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
