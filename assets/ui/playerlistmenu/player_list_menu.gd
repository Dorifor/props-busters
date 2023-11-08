extends Control

@export var player_list: ItemList
@export var instructions_label: Label

signal player_disconnected(peer_id)


func _ready():
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	print(Globals.PLAYER_DATA)
	update_list()
	if not is_multiplayer_authority(): return
	instructions_label.visible = multiplayer.is_server()


func update_list():
	player_list.clear()
	
	for player in Globals.PLAYER_DATA:
		var playername = Globals.PLAYER_DATA[player]["name"]
		if player != 1:
			player_list.add_item(playername, null, false)
		else:
			player_list.add_item(playername + " 👑" , null, false)


func _on_player_disconnected(id):
	Globals.PLAYER_DATA.erase(id)
	update_list()


func _on_player_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if !multiplayer.is_server(): return
	var selected_player_name = player_list.get_item_text(index).replace(" 👑", "")
	var selected_player_peer_id = get_player_peer_id_from_name(selected_player_name)
	multiplayer.multiplayer_peer.disconnect_peer(selected_player_peer_id)


func get_player_peer_id_from_name(player_name: String) -> int:
	for player in Globals.PLAYER_DATA:
		if Globals.PLAYER_DATA[player].name == player_name:
			return player
	return -1
