# Falling health pickup that continuously loops on screen
extends Area2D

@export var fall_speed: float = 100.0
@onready var animated_sprite = $Feather
@onready var collision = $CollisionShape2D

func _ready():
	body_entered.connect(_on_body_entered)
	if animated_sprite:
		animated_sprite.play("falling")
	_place_above_screen()

func _process(delta: float) -> void:
	position.y += fall_speed * delta
	var bounds = _viewport_bounds()
	if position.y > bounds.position.y + bounds.size.y:
		respawn()

func respawn() -> void:
	await get_tree().create_timer(15).timeout
	_place_above_screen()

func _place_above_screen() -> void:
	var bounds = _viewport_bounds()
	# Land x strictly within the visible width
	position.x = randf_range(bounds.position.x, bounds.position.x + bounds.size.x)
	# Start just above the visible top so it falls into view
	position.y = bounds.position.y - 150.0

func _viewport_bounds() -> Rect2:
	var inv = get_canvas_transform().affine_inverse()
	var vp = get_viewport_rect()
	var top_left = inv * vp.position
	var bottom_right = inv * (vp.position + vp.size)
	return Rect2(top_left, bottom_right - top_left)

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("heal"):
			body.heal(1)
			get_tree().current_scene.get_node("Pausable/Audio/Bloop").play()
		respawn()
