extends Area2D

var speed := randf_range(10, 300)
@onready var top_y := 300.0
@onready var bottom_y := 100.0
@onready var load_y_position = randf_range(500, -800)

func _process(delta: float) -> void:
	position.x += speed * delta
	if position.x > 3500:
		respawn()

func respawn() -> void:
	position.y = randf_range(-100, 700)
	position.x = randf_range(-2000, 20)
	speed_increase_loop()

func _ready():
	position.x = -1800
	position.y = load_y_position
	add_to_group("boost")
	connect("body_entered", Callable(self, "_on_hit"))

func _on_hit(body: Node2D) -> void:
	if body.name == "Bird":
		# upgrade gravity with gravity boost
		print("Horse and Bird collision")
		
func speed_increase_loop() -> void:
	print("current speed", speed)
	if speed >= 1500:
		return
	speed += 10
