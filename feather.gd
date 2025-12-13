# Falling health pickup that continuously loops on screen
extends Area2D

# === Export Variables (adjustable in Inspector) ===
@export var health_amount: int = 20  # Amount of health/hearts to give player
@export var fall_speed: float = 800.0  # Pixels per second the feather falls
@export var respawn_height: float = -150.0  # Y position above screen to respawn at
@export var bottom_limit: float = 900.0  # Y position where feather respawns if missed
@onready var animated_sprite = $FallingFeather  # Reference to the animated sprite
@onready var collision = $CollisionShape2D

func _ready():
	# Set initial starting position
	position.x = 200
	position.y = -2500
	
	# Connect the collision signal to detect when player touches feather
	body_entered.connect(_on_body_entered)
	
	# Start playing the falling animation
	if animated_sprite:
		animated_sprite.play("falling")

func _process(delta: float) -> void:
	# Move feather downward each frame
	position.y += fall_speed * delta
	
	# Check if feather has fallen past the bottom of the screen
	# If so, respawn it at the top (player missed it)
	if position.y > bottom_limit:
		respawn()

func respawn() -> void:
	await get_tree().create_timer(3).timeout
	# Reset feather to top of screen
	position.y = -1700
	# Randomize horizontal position for variety
	position.x = randf_range(800, 2500)

func _on_body_entered(body):
	# Check if the object that collided is the player
	# call_deferred(collision).disabled = true
	if body.is_in_group("player"):
		# Check if player has a heal method
		if body.has_method("heal"):
			# Give player 1 heart (change to health_amount if you want to use the export variable)
			body.heal(1)
		# Respawn feather at top immediately after collection
		respawn()
