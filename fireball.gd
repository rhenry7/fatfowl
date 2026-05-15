extends Area2D

@export var speed = 600
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	sprite.play("fire")
	area_entered.connect(_on_area_entered)

func _physics_process(delta):
	position += transform.x * speed * delta

func _on_area_entered(area: Area2D) -> void:
	if not area.has_method("on_hit") and not area.has_node("VulnerableArea"):
		return

	if area.has_method("on_hit"):
		area.on_hit()
	else:
		area.queue_free()

	var bird = get_tree().current_scene.get_node("Pausable/Bird")
	if bird.has_method("addCoin"):
		bird.addCoin(100)

	_free_projectile()

func _free_projectile() -> void:
	var projectile_root := get_parent()
	if projectile_root and projectile_root != self:
		projectile_root.queue_free()
	else:
		queue_free()
