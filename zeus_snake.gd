extends Area2D

const FIREBALL_SCENE := preload("res://snake_fireball.tscn")

@export var amplitude: float = -5.0 # how far back the snake goes to the right off the screen
@export var frequency: float = 2.0 # how far to the right

@onready var sprite = $AnimatedSprite2D

func deactivate():
	visible = false
	set_physics_process(false)
	set_process(false)
	collision_layer = 0
	collision_mask = 0
	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = true

func activate():
	visible = true
	set_physics_process(true)
	set_process(true)
	collision_layer = 1  # Or whatever your original layer was
	collision_mask = 1   # Or whatever your original mask was
	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	visible = false
	sprite.play("default")
	body_entered.connect(_on_body_entered)
	_run_attack_loop()

func _process(delta: float) -> void:
	position.x = position.x + sin(Time.get_ticks_msec() / 1000.0 * frequency) * amplitude

func _run_attack_loop() -> void:
	while true:
		await get_tree().create_timer(2.0, false).timeout
		if not visible:
			continue
		sprite.play("attack")
		await get_tree().create_timer(0.5, false).timeout
		# _fire()
		await sprite.animation_finished
		sprite.play("default")

func _fire() -> void:
	if visible:
		var fireball = FIREBALL_SCENE.instantiate()
		get_parent().add_child(fireball)
		# Offset counters the Area2D + sprite internal positions in snake_fireball.tscn
		# so the fireball visually appears at the snake's mouth
		fireball.global_position = sprite.global_position - Vector2(1298, 396)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Bird":
		body.take_damage()
