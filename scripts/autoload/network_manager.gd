extends Node
## Host-authoritative multiplayer: Steam lobby + ENet transport.

signal connection_succeeded
signal connection_failed
signal peer_connected(peer_id: int)
signal peer_disconnected(peer_id: int)
signal session_ended(reason: String)

const DEFAULT_PORT := 7777
const MAX_PLAYERS := 8

enum Role { NONE, HOST, CLIENT }

var role: Role = Role.NONE
var is_online: bool = false
var host_peer_id: int = 1

var _peer: ENetMultiplayerPeer = null


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

	SteamService.lobby_created.connect(_on_steam_lobby_created)
	SteamService.lobby_joined.connect(_on_steam_lobby_joined)


func host_game(port: int = DEFAULT_PORT, max_clients: int = MAX_PLAYERS - 1) -> Error:
	return _start_host(port, max_clients)


func join_game(address: String = "127.0.0.1", port: int = DEFAULT_PORT) -> Error:
	return _start_client(address, port)


func create_steam_lobby(max_members: int = MAX_PLAYERS, public: bool = false) -> void:
	SteamService.create_lobby(max_members, public)


func join_steam_lobby(lobby_id: int) -> void:
	SteamService.join_lobby(lobby_id)


func disconnect_session() -> void:
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	_peer = null
	role = Role.NONE
	is_online = false
	SteamService.leave_lobby()


func get_display_name(peer_id: int) -> String:
	if peer_id == multiplayer.get_unique_id():
		return SteamService.get_persona_name() if SteamService.is_initialized else "You"
	return "Player %d" % peer_id


func _start_host(port: int, max_clients: int) -> Error:
	disconnect_session()
	_peer = ENetMultiplayerPeer.new()
	var err := _peer.create_server(port, max_clients)
	if err != OK:
		push_error("NetworkManager: host failed (%d)" % err)
		return err
	multiplayer.multiplayer_peer = _peer
	role = Role.HOST
	is_online = true
	host_peer_id = multiplayer.get_unique_id()
	connection_succeeded.emit()
	return OK


func _start_client(address: String, port: int) -> Error:
	disconnect_session()
	_peer = ENetMultiplayerPeer.new()
	var err := _peer.create_client(address, port)
	if err != OK:
		push_error("NetworkManager: client connect failed (%d)" % err)
		return err
	multiplayer.multiplayer_peer = _peer
	role = Role.CLIENT
	is_online = true
	return OK


func _on_steam_lobby_created(lobby_id: int) -> void:
	if lobby_id == 0:
		# Dev mode without Steam — host on LAN
		host_game()
		return
	var err := host_game()
	if err != OK:
		session_ended.emit("Failed to start host")
		return
	SteamService.set_lobby_data(lobby_id, "host_port", str(DEFAULT_PORT))


func _on_steam_lobby_joined(lobby_id: int) -> void:
	if lobby_id == 0 or not SteamService.is_initialized:
		join_game("127.0.0.1")
		return

	var owner_id := SteamService.get_lobby_owner_id()
	if owner_id == SteamService.local_steam_id:
		return

	var port_str := SteamService.get_lobby_data(lobby_id, "host_port")
	if port_str.is_valid_int():
		join_game("127.0.0.1", int(port_str))
	else:
		join_game("127.0.0.1")


func _on_peer_connected(id: int) -> void:
	peer_connected.emit(id)


func _on_peer_disconnected(id: int) -> void:
	peer_disconnected.emit(id)
	if multiplayer.is_server() and multiplayer.get_peers().is_empty():
		pass


func _on_connected_to_server() -> void:
	connection_succeeded.emit()


func _on_connection_failed() -> void:
	role = Role.NONE
	is_online = false
	connection_failed.emit()


func _on_server_disconnected() -> void:
	role = Role.NONE
	is_online = false
	session_ended.emit("Host disconnected")
