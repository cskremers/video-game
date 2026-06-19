extends Control

@onready var host_button: Button = $VBox/HostButton
@onready var join_button: Button = $VBox/JoinButton
@onready var offline_button: Button = $VBox/OfflineButton
@onready var steam_status: Label = $VBox/SteamStatus
@onready var version_label: Label = $VBox/VersionLabel


func _ready() -> void:
	version_label.text = "v%s" % CrashReporter.build_version
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)
	offline_button.pressed.connect(_on_offline_pressed)

	SteamService.steam_ready.connect(_on_steam_ready)
	SteamService.steam_failed.connect(_on_steam_failed)
	_update_steam_status()


func _update_steam_status() -> void:
	if SteamService.is_initialized:
		steam_status.text = "Steam: connected (%s)" % SteamService.get_persona_name()
	elif SteamService.is_available:
		steam_status.text = "Steam: addon present, initializing..."
	else:
		steam_status.text = "Steam: dev mode (LAN). Install GodotSteam addon for lobbies."


func _on_steam_ready() -> void:
	_update_steam_status()


func _on_steam_failed(reason: String) -> void:
	steam_status.text = "Steam: %s" % reason


func _on_host_pressed() -> void:
	GameState.set_phase(GameState.SessionPhase.LOBBY)
	SceneRouter.go_to_lobby()


func _on_join_pressed() -> void:
	GameState.set_phase(GameState.SessionPhase.LOBBY)
	NetworkManager.join_game("127.0.0.1")
	SceneRouter.go_to_lobby()


func _on_offline_pressed() -> void:
	GameState.start_run()
	SceneRouter.go_to_game()
