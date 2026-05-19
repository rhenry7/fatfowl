extends CloudBase

@export_enum("angry", "happy", "sad") var enemy_type := "angry"
@export var min_speed := 10.0
@export var max_speed := 2000.0
@export var spawn_x_min := 1000.0
@export var spawn_x_max := 3200.0
@export var despawn_x := -2500.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var speed := 0.0

func _ready() -> void:
	add_to_group("hazard")
	body_entered.connect(_on_body_entered)
	cache_sprite_y_bounds()
	_apply_spawn_settings()

func configure(config: Dictionary) -> void:
	enemy_type = str(config.get("enemy_type", enemy_type))
	min_speed = float(config.get("min_speed", min_speed))
	max_speed = float(config.get("max_speed", max_speed))
	spawn_x_min = float(config.get("spawn_x_min", spawn_x_min))
	spawn_x_max = float(config.get("spawn_x_max", spawn_x_max))
	despawn_x = float(config.get("despawn_x", despawn_x))
	_apply_spawn_settings()

func _apply_spawn_settings() -> void:
	if not is_inside_tree():
		return
	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(enemy_type):
		animated_sprite.play(enemy_type)
	speed_increase_loop()
	position.x = randf_range(spawn_x_min, spawn_x_max)
	position.y = screen_y()
	visible = true
	monitoring = true
	monitorable = true
	set_process(true)
	set_physics_process(false)

	for child in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", false)

func _process(delta: float) -> void:
	position.x -= speed * delta
	if position.x < despawn_x:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.name != "Bird":
		return

	var zapped = get_tree().current_scene.get_node("Pausable/Audio/Zapped")
	zapped.play()
	body.take_damage()
	_disable_and_remove()

func on_hit() -> void:
	_disable_and_remove()

func _disable_and_remove() -> void:
	visible = false
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	set_process(false)
	for child in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", true)
	call_deferred("queue_free")

func speed_increase_loop() -> void:
	print("current speed", speed)
	if speed >= 5000:
		speed = 1000
	speed += randf_range(100, 500)
