extends Area2D

@export var fall_speed: float = 700.0
@export var bottom_limit: float = 2000.0
@export var respawn_wait: float = 30.0

# Adjust these weights in the Inspector to tune drop rates (higher = more common)
@export var weight_fire: float = 25.0
@export var weight_life_max: float = 25.0
@export var weight_flight_power: float = 25.0
@export var weight_fire_cooldown: float = 25.0

var _current_type: String = "fire_rate"
var _respawning: bool = false

func _ready() -> void:
	add_to_group("torch")
	position.x = randf_range(400, 1800)
	position.y = -1000
	body_entered.connect(_on_body_entered)
	_pick_type()

func _pick_type() -> void:
	var options: Array = [
		["fire_rate",    weight_fire],
		["life_limit",   weight_life_max],
		["flight_power", weight_flight_power],
		["fire_cooldown", weight_fire_cooldown],
	]
	var total := 0.0
	for o in options:
		total += float(o[1])
	var roll := randf() * total
	var cumulative := 0.0
	for o in options:
		cumulative += float(o[1])
		if roll < cumulative:
			_current_type = str(o[0])
			break
	var sprite := $AnimatedSprite2D
	if sprite.sprite_frames.has_animation(_current_type):
		sprite.play(_current_type)

func _viewport_bounds() -> Rect2:
	var inv := get_canvas_transform().affine_inverse()
	var vp := get_viewport_rect()
	return Rect2(inv * vp.position, inv * (vp.position + vp.size) - inv * vp.position)

func _process(delta: float) -> void:
	if _respawning:
		return
	position.y += fall_speed * delta
	if position.y > bottom_limit:
		_respawning = true
		_respawn()

func _respawn() -> void:
	position.y = -5000
	await get_tree().create_timer(respawn_wait, false).timeout
	var bounds := _viewport_bounds()
	position.x = randf_range(bounds.position.x + 400, bounds.position.x + bounds.size.x - 200)
	position.y = -1000
	_pick_type()
	_respawning = false

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player") or _respawning:
		return
	_apply_effect(body)
	get_tree().current_scene.get_node("Pausable/Audio/Bloop").play()
	_respawning = true
	_respawn()

func _apply_effect(body: Node) -> void:
	match _current_type:
		"fire_rate":
			if body.has_method("add_fire_heat_max"):
				body.add_fire_heat_max(50.0)
		"life_limit":
			if body.has_method("add_max_hearts"):
				body.add_max_hearts()
		"flight_power":
			if body.has_method("add_flap_strength"):
				body.add_flap_strength(100.0)
		"fire_cooldown":
			if body.has_method("decrease_fire_cooldown"):
				body.decrease_fire_cooldown(5.0)
