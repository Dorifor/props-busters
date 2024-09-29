extends Node

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const PORT = 7000
var DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 20

@export var base_menu: Control
@export var menu_panel: Control
@export var lobby_panel: Control
@export var ip_address_input: LineEdit
@export var username_input: LineEdit
@export var player_list: ItemList
@export var start_game_button: Button
@export var alert_box: Control
@export var alert_message: Label

@export var main_menu_scene: PackedScene
@export var main_scene: PackedScene

var players = {}

var player_info = {"name": "Default"}

var players_loaded = 0

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	username_input.text = str(randi())


func _on_join_button_pressed(address = "localhost") -> void:
	if username_input.text == "":
		return
	
	player_info = {"name": username_input.text}
	menu_panel.hide()
	lobby_panel.show()
	start_game_button.hide()
	DEFAULT_SERVER_IP = ip_address_input.text
	address = DEFAULT_SERVER_IP
	
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	
	if error != OK:
		print("Error during connection: %s" % error)
		return
	
	multiplayer.multiplayer_peer = peer
	
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 4.0
	timer.one_shot = true
	timer.start()

	await timer.timeout
	
	if multiplayer.get_multiplayer_peer() != null and multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		print("Error: Failed to join within 4 seconds.")
		menu_panel.show()
		lobby_panel.hide()
		start_game_button.show()
		return
	
	print("Successfully connected to the server.")


func _on_host_button_pressed():
	if username_input.text == "": return
	
	player_info = {"name": username_input.text}
	menu_panel.hide()
	lobby_panel.show()
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	
	if error:
		return error
	
	multiplayer.multiplayer_peer = peer
	players[1] = player_info
	player_connected.emit(1, player_info)


func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null


# When the server decides to start the game from a UI scene,
# do Lobby.load_game.rpc(filepath)
@rpc("call_local", "reliable")
func load_game(game_scene_path):
	get_tree().change_scene_to_file(game_scene_path)


@rpc("any_peer", "call_local", "reliable")
func update_list():
	player_list.clear()
	for player in players.values():
		player_list.add_item(player["name"], null, false)


# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == players.size():
			$/root/Game.start_game()
			players_loaded = 0


func _process(_delta):
	update_list()


func _on_player_connected(id):
	_register_player.rpc_id(id, player_info)


@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)
	update_list()


func _on_player_disconnected(id):
	players.erase(id)
#	player_disconnected.emit(id)


func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)


func _on_connected_fail():
	multiplayer.multiplayer_peer = null
	alert_box.show()
	alert_message.text = "Hôte non trouvé"


func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	get_tree().change_scene_to_packed(main_menu_scene)


func _on_start_game_pressed():
		rpc("start_game")  # Appel de la RPC start_game sur les clients
		start_game()  # Appel de la RPC start_game sur le serveur


@rpc("any_peer", "call_remote", "reliable")
func start_game():
	Globals.PLAYER_DATA = players
	Globals.ID_CURRENTPLAYER = multiplayer.get_unique_id()
	get_tree().change_scene_to_packed(main_scene)


func _on_validation_button_pressed():
	alert_box.hide()
	multiplayer.multiplayer_peer = null
	players.clear()
	get_tree().change_scene_to_packed(main_menu_scene)


func _on_back_button_pressed() -> void:
	player_list.clear()
	players = {}
	Globals.ID_CURRENTPLAYER = 0
	for item in range(player_list.item_count):
		print(player_list.get_item_at_position(Vector2(0, item)))
		player_list.remove_item(item)
	var multi_peer = multiplayer.multiplayer_peer
	var peer_list = multiplayer.get_peers()
	for peer in peer_list:
		multi_peer.disconnect_peer(peer)
	if multi_peer: multi_peer.close()
	multiplayer.multiplayer_peer = null
	start_game_button.show()
	base_menu.show()
	menu_panel.show()
	lobby_panel.hide()
	self.visible = false
