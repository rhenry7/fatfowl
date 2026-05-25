extends Area2D

const SPEED := 300.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	sprite.play("default")
	body_entered.connect(_on_body_entered)
	_run_attack_loop()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Bird":
		print("Eyebeam hits Bird")
		body.take_damage()
 
func _run_attack_loop() -> void:
	while true:
		await get_tree().create_timer(2.0, false).timeout
		get_parent().queue_free()
