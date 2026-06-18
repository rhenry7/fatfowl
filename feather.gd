# Falling health pickup that continuously loops on screen
extends Area2D

# === Export Variables (adjustable in Inspector) ===
@export var fall_speed: float = 500.0  # Pixels per second the feather falls
@export var bottom_limit: float = 2000.0  # Y position where feather respawns if missed
@onready var animated_sprite = $Feather  # Reference to the animated sprite
@onready var collision = $CollisionShape2D
var _respawning := false

func _ready():
	# Set initial starting position
	position.x = 2000
	position.y = -3000
	
	# Connect the collision signal to detect when player touches feather
	body_entered.connect(_on_body_entered)
	
	# Start playing the falling animation
	if animated_sprite:
		animated_sprite.play("falling")

func _viewport_bounds() -> Rect2:
	var inv = get_canvas_transform().affine_inverse()
	var vp = get_viewport_rect()
	var top_left = inv * vp.position
	var bottom_right = inv * (vp.position + vp.size)
	return Rect2(top_left, bottom_right - top_left)

func _process(delta: float) -> void:
	if _respawning:
		return
	position.y += fall_speed * delta
	if position.y > bottom_limit:
		_respawning = true
		respawn()

func respawn() -> void:
	position.y = -5000
	await get_tree().create_timer(0, false).timeout
	var bounds = _viewport_bounds()
	position.x = randf_range(bounds.position.x, bounds.position.x + bounds.size.x)
	position.y = -2000
	_respawning = false

func _on_body_entered(body):
	# Check if the object that collided is the player
	# call_deferred(collision).disabled = true
	if body.is_in_group("player"):
		# Check if player has a heal method
		if body.has_method("heal"):
			body.heal(1)
			position.y = -3000
			position.x = randf_range(400, 2000)
			get_tree().current_scene.get_node("Pausable/Audio/Bloop").play()

		# Respawn feather at top immediately after collection
