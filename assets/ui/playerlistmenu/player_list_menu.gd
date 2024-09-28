class_name PlayerListMenu
extends Control

@export var player_list: ItemList
@export var instructions_label: Label
@export var kick_confirmation_popup: Panel
@export var kick_confirmation_label: Label

signal player_disconnected(peer_id)

var selected_player_peer_id: int = -1

@export var kick_label_template_string: String = "Kick {player_name} ?"

func _ready() -> void:
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	print(Globals.PLAYER_DATA)
	if not Globals.DEBUG_MODE: update_list()
	if not is_multiplayer_authority(): return
	instructions_label.visible = multiplayer.is_server()


func update_list() -> void:
	player_list.clear()
	
	for player in Globals.PLAYER_DATA:
		var playername = Globals.PLAYER_DATA[player]["name"]
		if player != 1:
			player_list.add_item(playername, null, false)
		else:
			player_list.add_item(playername + " 👑" , null, false)


func _on_player_disconnected(id) -> void:
	Globals.PLAYER_DATA.erase(id)
	update_list()


func _on_player_list_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	if !multiplayer.is_server(): return
	var selected_player_name = player_list.get_item_text(index).replace(" 👑", "")
	selected_player_peer_id = get_player_peer_id_from_name(selected_player_name)
	replace_kick_player_name(selected_player_name)
	kick_confirmation_popup.show()


func get_player_peer_id_from_name(player_name: String) -> int:
	for player in Globals.PLAYER_DATA:
		if Globals.PLAYER_DATA[player].name == player_name:
			return player
	return -1


func replace_kick_player_name(player_name: String) -> void:
	if len(player_name) > 15:
		player_name = player_name.substr(0, 15) + "..."
	kick_confirmation_label.text = kick_label_template_string.replace("{player_name}", player_name)


func _on_kick_yes_button_pressed() -> void:
	kick_confirmation_popup.hide()
	multiplayer.multiplayer_peer.disconnect_peer(selected_player_peer_id)


func _on_kick_no_button_pressed() -> void:
	kick_confirmation_popup.hide()
