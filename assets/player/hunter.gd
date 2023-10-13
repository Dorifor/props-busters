extends BaseCharacter
class_name Hunter

@export var bullet_scene: PackedScene
@export var bullet_spawn_marker: Marker3D 
@export var animation_tree: AnimationTree
@export var animation_player: AnimationPlayer


func _ready():
	super()
	if not is_multiplayer_authority(): return
	print("HUNTER READY")
	animation_tree.active = true


func _process(delta):
	super(delta)
	if not is_multiplayer_authority(): return
	
	if(velocity == Vector3.ZERO):
		idle_animation_parameters.rpc()
	else:
		if Input.is_action_pressed("run"):
			update_animation_parameters.rpc()
		else :
			walk_animation_parameters.rpc()
			
	if Input.is_action_just_pressed("attack"):
		shoot()


func shoot():
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.position = bullet_spawn_marker.global_position
	bullet.transform.basis = bullet_spawn_marker.global_transform.basis
	get_parent().add_child(bullet)


func _unhandled_input(event):
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
