extends Area2D

var speed := randf_range(100, 500)

func deactivate():
	visible = false
	set_physics_process(false)
	set_process(false)
	speed = 0.0


	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = true


func _screen_y() -> float:
	var inv = get_canvas_transform().affine_inverse()
	var vp = get_viewport_rect()
	var y_min = (inv * vp.position).y + 50.0
	var y_max = (inv * (vp.position + vp.size)).y - 50.0
	return randf_range(y_min, y_max)

func activate():
	position.x = 500
	position.y = _screen_y()
	visible = true
	set_physics_process(true)
	set_process(true)

	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = false

func _process(delta: float) -> void:
	position.x -= speed * delta
	if position.x < -3500:
		respawn()

func respawn() -> void:
	position.y = _screen_y()
	position.x = randf_range(100, 2000)
	speed_increase_loop()

func _ready():
	position.x = 2000
	position.y = _screen_y()
	add_to_group("hazard")
	connect("body_entered", Callable(self, "_on_hit"))

func _on_hit(body: Node2D) -> void:
	if body.name == "Bird":
		var zapped = get_tree().current_scene.get_node("Pausable/Audio/Zapped")
		zapped.play()
		body.take_damage()
		
func speed_increase_loop() -> void:
	print("current speed", speed)
	if speed >= 1000:
		speed = 700
	speed += randf_range(150, 300)
