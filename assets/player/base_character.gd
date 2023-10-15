extends CharacterBody3D
class_name BaseCharacter

@export var walking_speed = 2
@export var run_speed = 4
@export var jump_velocity = 2.3
@export var speed_factor = 1

@export var rig: Node3D
@export var camera_mount: Node3D
@export var camera: Camera3D

@export var pause_menu: Control

var lockRotate = false
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var base_position: Vector3

var playerlistload

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())


func _ready():
	if not is_multiplayer_authority(): return
	camera.current = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pause_menu = get_tree().get_root().get_node("Main Scene/Pause Menu")
	
	var playerlist = load("res://assets/ui/playerlistmenu/player_list_menu.tscn")
	playerlistload = playerlist.instantiate()
	add_child(playerlistload)
	playerlistload.visible = false


func _input(event):
	if not is_multiplayer_authority(): return
	if Globals.IS_GAME_PAUSED: return
	
	var horizontal_sens = Globals.HORIZONTAL_SENSIBILITY_VALUE
	var vertical_sens = Globals.VERTICAL_SENSIBILITY_VALUE 
	
	if Input.is_action_just_pressed("tab"):
		if playerlistload.visible == false:
			playerlistload.show()
		else:
			playerlistload.hide()
		
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * horizontal_sens))
		
		if !lockRotate:
			rig.rotate_y(deg_to_rad(event.relative.x * horizontal_sens))
		
		camera_mount.rotate_x((deg_to_rad(-event.relative.y * vertical_sens)))
		var camera_rotation = camera_mount.rotation_degrees
		camera_rotation.x = clamp(camera_rotation.x, -30, 30)
		camera_mount.rotation_degrees = camera_rotation
		
	if event is InputEventKey and event.is_action("pause"):
		pause()


func _process(_delta):
	if not is_multiplayer_authority():
		return

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	if Globals.IS_GAME_PAUSED: return
	
	var speed: float
	if Input.is_action_pressed("run"):
		speed = run_speed
	else:
		speed = walking_speed
	speed *= speed_factor
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
	
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		if !lockRotate:
			rig.look_at(position + -direction)
		else:
			rig.rotation = Vector3(0, 160, 0)
		
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		if lockRotate:
			rig.rotation = Vector3(0, 160, 0)

	move_and_slide()


func pause():
	if not is_multiplayer_authority(): return
	
	Globals.IS_GAME_PAUSED = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	pause_menu.visible = true


func _to_string() -> String:
	return "%s - %s" % [name, position]
