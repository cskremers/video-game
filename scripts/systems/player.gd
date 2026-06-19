extends CharacterBody2D
## Co-op player: host-authoritative movement + interact RPC demo.

const MOVE_SPEED := 220.0

@export var player_color: Color = Color(0.35, 0.65, 1.0)

@onready var sprite: Polygon2D = $Visual/SpriteBody
@onready var label: Label = $Visual/NameLabel
@onready var interact_area: Area2D = $InteractArea

var peer_id: int = 0
var interact_count: int = 0


func _ready() -> void:
	peer_id = name.to_int() if name.is_valid_int() else multiplayer.get_unique_id()
	sprite.color = player_color
	label.text = NetworkManager.get_display_name(peer_id)
	set_multiplayer_authority(peer_id)
	if not is_multiplayer_authority():
		set_process_input(false)


func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return

	var direction := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	if direction.length_squared() > 1.0:
		direction = direction.normalized()
	velocity = direction * MOVE_SPEED
	move_and_slide()

	if Input.is_action_just_pressed("interact"):
		if multiplayer.has_multiplayer_peer():
			_request_interact.rpc_id(1)
		else:
			_perform_interact_local()


func _perform_interact_local() -> void:
	interact_count += 1
	label.text = "%s [%d]" % [NetworkManager.get_display_name(peer_id), interact_count]
	sprite.scale = Vector2.ONE * 1.15
	var tween := create_tween()
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.15)
	var orb := get_tree().get_first_node_in_group("interactable")
	if orb:
		try_interact_with_orb(orb)


func try_interact_with_orb(orb: Node) -> void:
	if orb.has_method("register_interaction"):
		orb.register_interaction(peer_id)


@rpc("any_peer", "call_local", "reliable")
func _request_interact() -> void:
	if not multiplayer.is_server():
		return
	_perform_interact.rpc()
	var orb := get_tree().get_first_node_in_group("interactable")
	if orb:
		try_interact_with_orb(orb)


@rpc("authority", "call_local", "reliable")
func _perform_interact() -> void:
	interact_count += 1
	label.text = "%s [%d]" % [NetworkManager.get_display_name(peer_id), interact_count]
	sprite.scale = Vector2.ONE * 1.15
	var tween := create_tween()
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.15)


@rpc("authority", "call_local", "unreliable")
func sync_transform(pos: Vector2, vel: Vector2) -> void:
	if is_multiplayer_authority():
		return
	global_position = pos
	velocity = vel


func _process(_delta: float) -> void:
	if is_multiplayer_authority() and multiplayer.has_multiplayer_peer():
		sync_transform.rpc(global_position, velocity)
