extends Area2D
## Shared interactable orb — increments a counter on the host when any player interacts nearby.

signal activated(total: int)

@export var glow_color: Color = Color(0.4, 0.85, 1.0, 0.9)

var activation_count: int = 0

@onready var core: Polygon2D = $Core
@onready var label: Label = $Label


func _ready() -> void:
	add_to_group("interactable")
	label.text = "Interact (E)"
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	core.rotation += delta * 0.6


func register_interaction(from_peer_id: int) -> void:
	if multiplayer.has_multiplayer_peer() and not multiplayer.is_server():
		return
	activation_count += 1
	label.text = "Activated x%d" % activation_count
	activated.emit(activation_count)
	var pulse := create_tween()
	pulse.tween_property(core, "scale", Vector2.ONE * 1.25, 0.1)
	pulse.tween_property(core, "scale", Vector2.ONE, 0.2)
	print("Interactable activated by peer %d (total %d)" % [from_peer_id, activation_count])


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		label.modulate = Color(1.2, 1.2, 1.2)


func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		label.modulate = Color.WHITE
