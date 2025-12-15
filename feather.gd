# Falling health pickup that continuously loops on screen
extends Area2D

# === Export Variables (adjustable in Inspector) ===
@export var health_amount: int = 20  # Amount of health/hearts to give player
@export var fall_speed: float = 800.0  # Pixels per second the feather falls
@export var bottom_limit: float = 1400.0  # Y position where feather respawns if missed
@onready var animated_sprite = $FallingFeather  # Reference to the animated sprite
@onready var collision = $CollisionShape2D

func _ready():
	# Set initial starting position
	position.x = 2000
	position.y = -3000
	
	# Connect the collision signal to detect when player touches feather
	body_entered.connect(_on_body_entered)
	
	# Start playing the falling animation
	if animated_sprite:
		animated_sprite.play("falling")

func _process(delta: float) -> void:
	# Move feather downward each frame
	position.y += fall_speed * delta
	# Check if feather has fallen past the bottom of the screen
	if position.y > bottom_limit:
		respawn()

func respawn() -> void:
	await get_tree().create_timer(2).timeout
	animated_sprite.visible = true
	# Reset feather to top of screen
	position.y = -2000
	position.x = randf_range(400, 2500)
	# Randomize horizontal position for variety

func _on_body_entered(body):
	# Check if the object that collided is the player
	# call_deferred(collision).disabled = true
	if body.is_in_group("player"):
		# Check if player has a heal method
		if body.has_method("heal"):
			# Give player 1 heart (change to health_amount if you want to use the export variable)
			body.heal(1)
			get_tree().current_scene.get_node("Pausable/Bloop").play()
			animated_sprite.visible = false
		# Respawn feather at top immediately after collection
