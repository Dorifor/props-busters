extends Control

@onready var playerlist = $playerlist

signal player_disconnected(peer_id)

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	update_list()

func update_list():
	playerlist.clear()
	

	
	for player in Globals.PLAYER_DATA:
		var playername = Globals.PLAYER_DATA[player]["name"]
		if player != 1:
			playerlist.add_item(playername, null, false)# Replace with function body.
		else:
			playerlist.add_item(playername + "👑" , null, false)# Replace with function body.

func _on_player_disconnected(id):
	Globals.PLAYER_DATA.erase(id)
	update_list()
