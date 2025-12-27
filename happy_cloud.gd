extends Area2D

var speed := randf_range(500, 800)
@onready var right_spawn_x := 200.0
@onready var top_y := 300.0
@onready var bottom_y := 100.0

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
	position.y = randf_range(top_y, bottom_y)
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
	await get_tree().create_timer(5.0 , false, true).timeout
	position.y = randf_range(-100, 1000)
	position.x = randf_range(100, 2000)
	speed_increase_loop()

func _ready():
	position.x = 2000
	position.y = randf_range(400, 2000)
	add_to_group("hazard")
	connect("body_entered", Callable(self, "_on_hit"))

func _on_hit(body: Node2D) -> void:
	if body.name == "Bird":
		var zapped = get_tree().current_scene.get_node("Pausable/Audio/Zapped")
		zapped.play()
		body.take_damage()
		
func speed_increase_loop() -> void:
	print("current speed", speed)
	if speed >= 2000:
		speed = 500
	speed += 10
