extends BaseCharacter
class_name Hunter

@export var bullet_scene: PackedScene
@export var bullet_spawn_marker: Marker3D 
@export var animation_tree: AnimationTree
@export var animation_player: AnimationPlayer
@export var crosshair: Control

@export var raycast: RayCast3D

@export var interact_label: Label
@export var life_point_label: Label

var lifepoint: int = 10

var can_interact = false

func _ready():
	super()
	
	animation_tree.active = true
	crosshair.visible = true

func _input(event):
	super(event)
	
	if event is InputEventKey and event.is_action_pressed("interact") and can_interact == true:
		var collider = raycast.get_collider()
		if collider and collider.is_class("CharacterBody3D"):
			print("The raycast hit a CharacterBody3D!")
		else:
			update_life_point()

func update_life_point():
	lifepoint = lifepoint - 1;
	update_life_point_text()

func update_life_point_text():
	life_point_label.text = "lifepoint : " + str(lifepoint)

func _process(delta):
	super(delta)
	
	if raycast.is_colliding() == true:
		interact_label.visible = true
		can_interact = true
		
	else:
		interact_label.visible = false
		can_interact = false
		
	if Globals.IS_GAME_PAUSED: return


func shoot():
	var bullet: Node3D = bullet_scene.instantiate()
	
	get_parent().add_child(bullet)
	
	bullet.transform.origin = bullet_spawn_marker.global_transform.origin
	bullet.global_transform.basis = get_cam_rot()


func get_cam_rot():
	return camera.global_transform.basis


func _unhandled_input(_event):
	if not is_multiplayer_authority(): return
