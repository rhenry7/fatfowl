extends "res://cloud_base.gd"

var speed := randf_range(100, 500)
var _hit_count := 0

func on_hit() -> int:
	_hit_count += 1
	if _hit_count < 3:
		return 0
	_hit_count = 0
	var kill_pos := global_position
	var bird = get_tree().current_scene.get_node_or_null("Pausable/Bird")
	if bird and bird.has_method("add_kill"):
		bird.add_kill()
	ScorePopup.spawn(kill_pos, 300)
	visible = false
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	set_process(false)
	for child in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", true)
	call_deferred("queue_free")
	return 300

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
	if position.x < -2500:
		respawn()

func respawn() -> void:
	_hit_count = 0
	position.y = screen_y()
	position.x = randf_range(100, 2000)
	speed_increase_loop()

func _ready():
	position.x = 800
	position.y = -1200
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
	if speed >= 2500:
		speed = 1500
	speed += randf_range(150, 1000)
