extends BaseCharacterFPS
class_name Hunter

@export var bullet_scene: PackedScene
@export var bullet_spawn_marker: Marker3D 
@export var animation_tree: AnimationTree
@export var animation_player: AnimationPlayer
@export var crosshair: Control

func _ready():
	super()
	if not is_multiplayer_authority(): return
	animation_tree.active = true


func _input(event):
	super._input(event)
	if not is_multiplayer_authority(): return


func _process(delta):
	super(delta)
	
	if not is_multiplayer_authority(): return
	if Globals.IS_GAME_PAUSED: return
	
	if(velocity == Vector3.ZERO):
		idle_animation_parameters.rpc()
	else:
		if Input.is_action_pressed("run"):
			update_animation_parameters.rpc()
		else :
			walk_animation_parameters.rpc()


@rpc("call_local")
func shoot():
	var bullet: Node3D = bullet_scene.instantiate()
	
	get_parent().add_child(bullet)
	
	bullet.transform.origin = bullet_spawn_marker.global_transform.origin
	bullet.global_transform.basis = get_cam_rot()


func get_cam_rot():
	return camera.global_transform.basis


func _unhandled_input(_event):
	if not is_multiplayer_authority(): return


@rpc("call_local")
func update_animation_parameters():
	animation_player.play("PlayerAnimation/A_Run")


@rpc("call_local")
func idle_animation_parameters():
	animation_player.play("PlayerAnimation/A_Idle")


@rpc("call_local")	
func walk_animation_parameters():
	animation_player.play("PlayerAnimation/A_Walk")
