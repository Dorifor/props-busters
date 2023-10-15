extends Control

@onready var playerlist = $playerlist

signal player_disconnected(peer_id)

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	
	Updatelist()

func Updatelist():
	for player in Globals.PLAYER_DATA.values():
		playerlist.add_item(player["name"], null, false)# Replace with function body.

func _on_player_disconnected(id):
	print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAa")
	print(Globals.PLAYER_DATA)
	Updatelist()
