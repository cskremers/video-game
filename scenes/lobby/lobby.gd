extends Control

@onready var status_label: Label = $Panel/VBox/StatusLabel
@onready var member_list: ItemList = $Panel/VBox/MemberList
@onready var create_button: Button = $Panel/VBox/Buttons/CreateLobbyButton
@onready var start_button: Button = $Panel/VBox/Buttons/StartButton
@onready var back_button: Button = $Panel/VBox/Buttons/BackButton


func _ready() -> void:
	GameState.set_phase(GameState.SessionPhase.LOBBY)
	create_button.pressed.connect(_on_create_pressed)
	start_button.pressed.connect(_on_start_pressed)
	back_button.pressed.connect(_on_back_pressed)

	NetworkManager.connection_succeeded.connect(_on_connection_succeeded)
	NetworkManager.connection_failed.connect(_on_connection_failed)
	NetworkManager.peer_connected.connect(_refresh_members)
	NetworkManager.peer_disconnected.connect(_refresh_members)
	NetworkManager.session_ended.connect(_on_session_ended)

	SteamService.lobby_created.connect(_on_lobby_created)
	SteamService.lobby_joined.connect(_on_lobby_joined)
	SteamService.lobby_member_joined.connect(func(_id): _refresh_members())
	SteamService.lobby_member_left.connect(func(_id): _refresh_members())

	_refresh_members()
	_update_status("Create or join a lobby to begin.")


func _on_create_pressed() -> void:
	_update_status("Creating lobby...")
	NetworkManager.create_steam_lobby(GameState.max_players, false)


func _on_lobby_created(lobby_id: int) -> void:
	if lobby_id == 0:
		_update_status("Dev lobby (LAN host on port %d)" % NetworkManager.DEFAULT_PORT)
	else:
		_update_status("Steam lobby %d created" % lobby_id)
	start_button.disabled = not multiplayer.is_server()
	_refresh_members()


func _on_lobby_joined(lobby_id: int) -> void:
	_update_status("Joined lobby %d" % lobby_id)
	start_button.disabled = not multiplayer.is_server()
	_refresh_members()


func _on_connection_succeeded() -> void:
	_update_status("Connected to session")
	start_button.disabled = not multiplayer.is_server()
	_refresh_members()


func _on_connection_failed() -> void:
	_update_status("Connection failed")
	start_button.disabled = true


func _on_session_ended(reason: String) -> void:
	_update_status(reason)
	start_button.disabled = true


func _on_start_pressed() -> void:
	if not multiplayer.is_server():
		return
	_start_run.rpc()


@rpc("authority", "call_local", "reliable")
func _start_run() -> void:
	GameState.start_run()
	SceneRouter.go_to_game()


func _on_back_pressed() -> void:
	NetworkManager.disconnect_session()
	GameState.return_to_menu()


func _refresh_members(_peer_id: int = -1) -> void:
	member_list.clear()
	if SteamService.current_lobby_id != 0 and SteamService.is_initialized:
		for steam_id in SteamService.get_lobby_member_ids():
			member_list.add_item(SteamService.get_persona_name(steam_id))
	elif NetworkManager.is_online:
		member_list.add_item(NetworkManager.get_display_name(multiplayer.get_unique_id()))
		for peer_id in multiplayer.get_peers():
			member_list.add_item(NetworkManager.get_display_name(peer_id))
	else:
		member_list.add_item("No members yet")


func _update_status(text: String) -> void:
	status_label.text = text
