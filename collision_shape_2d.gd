extends CharacterBody2D

var speed := 150.0   # pixels per second
var left_limit := -200.0        # off-screen threshold on the left
var right_spawn_x := 1200.0     # spawn position on the right
var top_y := 50.0               # vertical spawn bounds
var bottom_y := 550.0

func respawn() -> void:
	# Pick a random vertical position
	var random_y := randf_range(top_y, bottom_y)
	position = Vector2(right_spawn_x, random_y)

func _process(delta: float) -> void:
	# Step 1: Move left continuously
	position.x -= speed * delta
	velocity = Vector2(100,0)
	move_and_slide()
	
	# Step 2: When enemy goes off-screen left → respawn
	if position.x < left_limit:
		respawn()
