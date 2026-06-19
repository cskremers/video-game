extends Node2D

@onready var seed_label: Label = $HUD/Panel/VBox/SeedLabel
@onready var back_button: Button = $HUD/BackButton
@onready var player_spawner: Node2D = $PlayerSpawner
@onready var orb: Area2D = $InteractableOrb


func _ready() -> void:
	seed_label.text = "Run seed: %d" % GameState.run_seed
	back_button.pressed.connect(_on_back_pressed)

	if not NetworkManager.is_online:
		_spawn_offline_player()

	orb.activated.connect(_on_orb_activated)


func _spawn_offline_player() -> void:
	var player_scene: PackedScene = preload("res://scenes/game/player.tscn")
	var player: CharacterBody2D = player_scene.instantiate()
	player.name = "1"
	player.position = Vector2(640, 480)
	player_spawner.add_child(player)


func _on_orb_activated(total: int) -> void:
	seed_label.text = "Run seed: %d · Orb x%d" % [GameState.run_seed, total]


func _on_back_pressed() -> void:
	if NetworkManager.is_online:
		NetworkManager.disconnect_session()
	SaveManager.save_game({"total_runs": SaveManager.load_game().get("total_runs", 0) + 1})
	GameState.return_to_menu()
