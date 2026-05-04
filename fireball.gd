extends Area2D

@export var speed = 600
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	sprite.play("fire")
	area_entered.connect(_on_area_entered)

func _physics_process(delta):
	position += transform.x * speed * delta

func _on_area_entered(area: Area2D) -> void:
	if area.has_node("VulnerableArea"):
		if area.has_method("on_hit"):
			area.on_hit()
		else:
			area.queue_free()
		queue_free()
