extends Area2D

@export var fall_speed: float = 700.0
@export var bottom_limit: float = 2000.0
@export var fire_heat_boost: float = 50.0
@export var respawn_wait: float = 30.0

var _respawning := false

func _ready() -> void:
	add_to_group("torch")
	position.x = randf_range(400, 1800)
	position.y = -1000
	body_entered.connect(_on_body_entered)
	$AnimatedSprite2D.play("default")

func _viewport_bounds() -> Rect2:
	var inv = get_canvas_transform().affine_inverse()
	var vp = get_viewport_rect()
	var top_left = inv * vp.position
	var bottom_right = inv * (vp.position + vp.size)
	return Rect2(top_left, bottom_right - top_left)

func _process(delta: float) -> void:
	position.y += fall_speed * delta
	if position.y > bottom_limit and not _respawning:
		_respawn()

func _respawn() -> void:
	_respawning = true
	position.y = -5000
	await get_tree().create_timer(respawn_wait, false).timeout
	var bounds = _viewport_bounds()
	position.x = randf_range(bounds.position.x + 400, bounds.position.x + bounds.size.x - 200)
	position.y = -1000
	_respawning = false

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if body.has_method("add_fire_heat_max"):
		body.add_fire_heat_max(fire_heat_boost)
	get_tree().current_scene.get_node("Pausable/Audio/Bloop").play()
	if not _respawning:
		_respawn()
