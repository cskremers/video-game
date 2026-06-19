extends Node
## Steamworks wrapper. Uses GodotSteam when the addon is installed; otherwise dev mode.

signal steam_ready
signal steam_failed(reason: String)
signal lobby_created(lobby_id: int)
signal lobby_joined(lobby_id: int)
signal lobby_member_joined(steam_id: int)
signal lobby_member_left(steam_id: int)
signal lobby_list_updated(lobbies: Array)

const DEV_APP_ID := 480
const LOBBY_TYPE_FRIENDS := 1
const LOBBY_TYPE_PUBLIC := 2

var is_available: bool = false
var is_initialized: bool = false
var app_id: int = DEV_APP_ID
var local_steam_id: int = 0
var current_lobby_id: int = 0

var _steam: Variant = null
var _use_steam: bool = false


func _init() -> void:
	_detect_steam()


func _ready() -> void:
	if _use_steam:
		_connect_steam_signals()
	_initialize_steam()


func _process(_delta: float) -> void:
	if _use_steam and is_initialized:
		_steam.run_callbacks()


func _detect_steam() -> void:
	_use_steam = Engine.has_singleton("Steam")
	if _use_steam:
		_steam = Engine.get_singleton("Steam")
	is_available = _use_steam


func _initialize_steam() -> void:
	if not _use_steam:
		is_initialized = false
		steam_failed.emit("GodotSteam not installed — using LAN/dev networking.")
		return

	var init_result: Dictionary = _steam.steamInitEx(true, app_id)
	var status: int = int(init_result.get("status", 0))
	if status != 1:
		is_initialized = false
		var reason: String = str(init_result.get("verbal", "Steam init failed"))
		steam_failed.emit(reason)
		return

	is_initialized = true
	local_steam_id = int(_steam.getSteamID())
	steam_ready.emit()


func _connect_steam_signals() -> void:
	if not _steam.has_signal("lobby_created"):
		return
	_steam.lobby_created.connect(_on_steam_lobby_created)
	_steam.lobby_joined.connect(_on_steam_lobby_joined)
	_steam.lobby_match_list.connect(_on_steam_lobby_match_list)
	if _steam.has_signal("lobby_chat_update"):
		_steam.lobby_chat_update.connect(_on_steam_lobby_chat_update)


func create_lobby(max_members: int = 8, public: bool = false) -> void:
	if not is_initialized:
		lobby_created.emit(0)
		return
	var lobby_type := LOBBY_TYPE_PUBLIC if public else LOBBY_TYPE_FRIENDS
	_steam.createLobby(lobby_type, max_members)


func join_lobby(lobby_id: int) -> void:
	if not is_initialized:
		lobby_joined.emit(lobby_id)
		return
	_steam.joinLobby(lobby_id)


func leave_lobby() -> void:
	if is_initialized and current_lobby_id != 0:
		_steam.leaveLobby(current_lobby_id)
	current_lobby_id = 0


func request_lobby_list() -> void:
	if not is_initialized:
		lobby_list_updated.emit([])
		return
	_steam.addRequestLobbyListDistanceFilter(_steam.LOBBY_DISTANCE_FILTER_DEFAULT)
	_steam.requestLobbyList()


func get_lobby_member_count() -> int:
	if not is_initialized or current_lobby_id == 0:
		return 0
	return int(_steam.getNumLobbyMembers(current_lobby_id))


func get_lobby_member_ids() -> Array[int]:
	var ids: Array[int] = []
	if not is_initialized or current_lobby_id == 0:
		return ids
	var count := get_lobby_member_count()
	for i in count:
		ids.append(int(_steam.getLobbyMemberByIndex(current_lobby_id, i)))
	return ids


func get_lobby_owner_id() -> int:
	if not is_initialized or current_lobby_id == 0:
		return 0
	return int(_steam.getLobbyOwner(current_lobby_id))


func get_persona_name(steam_id: int = 0) -> String:
	if not is_initialized:
		return "Player"
	var id := steam_id if steam_id != 0 else local_steam_id
	return str(_steam.getFriendPersonaName(id))


func get_lobby_data(lobby_id: int, key: String) -> String:
	if not is_initialized:
		return ""
	return str(_steam.getLobbyData(lobby_id, key))


func set_lobby_data(lobby_id: int, key: String, value: String) -> void:
	if is_initialized and lobby_id != 0:
		_steam.setLobbyData(lobby_id, key, value)


func _on_steam_lobby_created(result: int, lobby_id: int) -> void:
	if result != 1:
		push_warning("SteamService: lobby create failed (%d)" % result)
		return
	current_lobby_id = lobby_id
	_steam.setLobbyJoinable(lobby_id, true)
	_steam.setLobbyData(lobby_id, "game", "video-game")
	lobby_created.emit(lobby_id)


func _on_steam_lobby_joined(lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response != 1:
		push_warning("SteamService: lobby join failed (%d)" % response)
		return
	current_lobby_id = lobby_id
	lobby_joined.emit(lobby_id)


func _on_steam_lobby_match_list(lobbies: int) -> void:
	var results: Array = []
	for i in lobbies:
		results.append(int(_steam.getLobbyByIndex(i)))
	lobby_list_updated.emit(results)


func _on_steam_lobby_chat_update(lobby_id: int, changed_id: int, _making_change_id: int, chat_state: int) -> void:
	if lobby_id != current_lobby_id:
		return
	if chat_state & 1:
		lobby_member_joined.emit(changed_id)
	elif chat_state & 4 or chat_state & 2:
		lobby_member_left.emit(changed_id)
