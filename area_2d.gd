extends Area2D

@export var speed := 1250.0
@export var right_spawn_x := 500.0
@export var top_y := -400.0
@export var bottom_y := 1200.0

func _process(delta: float) -> void:
	position.x -= speed * delta

	if position.x < -2500:
		respawn()

func respawn() -> void:
	position.y = randf_range(top_y, bottom_y)
	position.x = right_spawn_x

func _ready():
	add_to_group("hazard")
	connect("body_entered", Callable(self, "_on_hit"))

func _on_hit(body: Node2D) -> void:
	if body.name == "Bird":
		body.take_damage()
		print("cloud and bird meet")
