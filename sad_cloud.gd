extends "res://cloud_base.gd"

var speed := randf_range(100, 150)

func deactivate():
	visible = false
	set_physics_process(false)
	set_process(false)
	speed = 0.0

	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = true

func activate():
	position.x = 500
	position.y = screen_y()
	visible = true
	set_physics_process(true)
	set_process(true)

	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = false

func _process(delta: float) -> void:
	position.x -= speed * delta
	if position.x < -3000:
		respawn()

func respawn() -> void:
	position.y = screen_y()
	position.x = randf_range(100, 2000)
	speed_increase_loop()

func _ready():
	position.x = 700
	position.y = -1000
	add_to_group("hazard")
	connect("body_entered", Callable(self, "_on_hit"))
	cache_sprite_y_bounds()

func _on_hit(body: Node2D) -> void:
	if body.name == "Bird":
		var zapped = get_tree().current_scene.get_node("Pausable/Audio/Zapped")
		zapped.play()
		body.take_damage()
		
func speed_increase_loop() -> void:
	print("current speed", speed)
	if speed >= 1500:
		speed = 300
	speed += randf_range(50, 100)
