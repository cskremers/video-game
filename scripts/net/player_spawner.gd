extends Node2D
## Spawns networked players when peers connect. Host is authoritative.

const PLAYER_SCENE := preload("res://scenes/game/player.tscn")

const PLAYER_COLORS: Array[Color] = [
	Color(0.35, 0.65, 1.0),
	Color(1.0, 0.45, 0.45),
	Color(0.45, 0.95, 0.55),
	Color(0.95, 0.75, 0.25),
	Color(0.75, 0.45, 0.95),
	Color(0.45, 0.95, 0.95),
	Color(0.95, 0.55, 0.75),
	Color(0.85, 0.85, 0.85),
]


func _ready() -> void:
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.connect(_spawn_player)
	multiplayer.peer_disconnected.connect(_despawn_player)
	# Host spawns self
	call_deferred("_spawn_player", multiplayer.get_unique_id())
	for peer_id in multiplayer.get_peers():
		call_deferred("_spawn_player", peer_id)


func _spawn_player(id: int) -> void:
	if has_node(str(id)):
		return
	var player: CharacterBody2D = PLAYER_SCENE.instantiate()
	player.name = str(id)
	player.player_color = PLAYER_COLORS[id % PLAYER_COLORS.size()]
	player.position = Vector2(640, 360) + Vector2(randf_range(-80, 80), randf_range(-40, 40))
	add_child(player, true)


func _despawn_player(id: int) -> void:
	var node := get_node_or_null(str(id))
	if node:
		node.queue_free()
