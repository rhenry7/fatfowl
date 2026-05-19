extends Area2D

const SPEED := 500.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	sprite.play("default")
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position.x -= SPEED * delta
	if global_position.x < -2500.0:
		get_parent().queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Bird":
		body.take_damage()
		get_parent().queue_free()
