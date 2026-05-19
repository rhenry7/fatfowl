extends Area2D

const FIREBALL_SCENE := preload("res://snake_fireball.tscn")

@export var amplitude: float = 4.0
@export var frequency: float = 2.0

@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	sprite.play("default")
	body_entered.connect(_on_body_entered)
	_run_attack_loop()

func _process(delta: float) -> void:
	position.x = position.x + sin(Time.get_ticks_msec() / 1000.0 * frequency) * amplitude

func _run_attack_loop() -> void:
	while true:
		await get_tree().create_timer(5.0, false).timeout
		sprite.play("attack")
		await get_tree().create_timer(1.0, false).timeout
		_fire()
		await sprite.animation_finished
		sprite.play("default")

func _fire() -> void:
	var fireball = FIREBALL_SCENE.instantiate()
	get_parent().add_child(fireball)
	# Offset counters the Area2D + sprite internal positions in snake_fireball.tscn
	# so the fireball visually appears at the snake's mouth
	fireball.global_position = sprite.global_position - Vector2(798, 496)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Bird":
		body.take_damage()
