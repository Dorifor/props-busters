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
