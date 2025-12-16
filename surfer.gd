extends Area2D

@onready var speed := 700
@onready var right_spawn_x := 200.0
@onready var top_y := 200.0
@onready var bottom_y := 900.0

func _process(delta: float) -> void:
	position.x -= speed * delta
	if position.x < -5000:
		respawn()

func respawn() -> void:
	position.y = randf_range(-500, 3000)
	position.x = 4000 
	# speed_increase_loop()

func _ready():
	position.x = 4000
	add_to_group("hazard")
	connect("body_entered", Callable(self, "_on_hit"))

func _on_hit(body: Node2D) -> void:
	if body.name == "Bird":
		var zapped = get_tree().current_scene.get_node("Pausable/Zapped")
		zapped.play()
		body.take_damage()
		
func speed_increase_loop() -> void:
	speed += 50
