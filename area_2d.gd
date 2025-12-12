extends Area2D

@export var speed := 500.0
@export var right_spawn_x := 200.0
@export var top_y := 10.0
@export var bottom_y := 1000.0

func deactivate():
	visible = false
	set_physics_process(false)
	set_process(false)
	speed = 0.0

	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = true


func activate():
	visible = true
	set_physics_process(true)
	set_process(true)
	speed = 1000

	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = false

func _process(delta: float) -> void:
	position.x -= speed * delta
	if position.x < -2500:
		respawn()

func respawn() -> void:
	position.y = randf_range(top_y, bottom_y)
	position.x = 500

func _ready():
	speed_increase_loop()
	add_to_group("hazard")
	connect("body_entered", Callable(self, "_on_hit"))

func _on_hit(body: Node2D) -> void:
	if body.name == "Bird":
		var zapped = get_tree().current_scene.get_node("Pausable/Zapped")
		zapped.play()
		body.take_damage()
		
func speed_increase_loop() -> void:
	while true:
		await get_tree().create_timer(10, false, true).timeout
		speed += 250
