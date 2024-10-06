extends Hunter
class_name OnlineHunter

@export var cooldown_duration: float = 10.0
@export var wait_label: Label

var player_list: PlayerListMenu
var countdown_timer: Timer
var timer_seconds_left: int = 0
var can_play: bool = false

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())


func _ready() -> void:
	if not is_multiplayer_authority():
		return
	
	player_list = GlobalRessources.player_list_scene.instantiate()
	add_child(player_list)
	player_list.visible = false
	
	super()
	
	# Initialiser le Timer
	countdown_timer = Timer.new()
	countdown_timer.wait_time = 1.0
	countdown_timer.one_shot = false
	countdown_timer.timeout.connect(_on_countdown_tick)
	add_child(countdown_timer)
	
	# Commencer le décompte
	timer_seconds_left = int(cooldown_duration)
	wait_label.text = str(timer_seconds_left)
	countdown_timer.start()

# Fonction appelée à chaque tick du Timer
func _on_countdown_tick():
	timer_seconds_left -= 1
	wait_label.text = str(timer_seconds_left)
	
	if timer_seconds_left <= 0:
		countdown_timer.stop()
		crosshair.visible = false
		update_life_point_text()
		life_point_label.visible = true
		can_play = true


func _process(delta: float) -> void:
	if not is_multiplayer_authority() or !can_play: return
	super(delta)
	
	if(velocity == Vector3.ZERO):
		idle_animation_parameters.rpc()
	else:
		if Input.is_action_pressed("run"):
			update_animation_parameters.rpc()
		else :
			walk_animation_parameters.rpc()


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority() or !can_play: return
	super(delta)


func pause():
	if not is_multiplayer_authority() or !can_play: return
	super()


func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority() or !can_play: return
	super(event)
	
	if Input.is_action_just_pressed("tab"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		player_list.show()
	if Input.is_action_just_released("tab"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		player_list.hide()
		player_list.kick_confirmation_popup.hide()

func apply_mouse_movement(event: InputEvent):
	if player_list.visible:
		return
	
	super(event)


@rpc("call_local")
func update_animation_parameters():
	animation_player.play("PlayerAnimation/A_Run")


@rpc("call_local")
func idle_animation_parameters():
	animation_player.play("PlayerAnimation/A_Idle")


@rpc("call_local")	
func walk_animation_parameters():
	animation_player.play("PlayerAnimation/A_Walk")
