extends Area2D

@export var fade_in_duration := 2.0
@export var active_duration := 0.5
@export var fade_out_duration := 1.0
@export var post_delay := 0.5

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("hazard")
	body_entered.connect(_on_hit)
	modulate.a = 0.0
	if animated_sprite:
		animated_sprite.play("default")
	_set_collision_enabled(false)
	call_deferred("_run_sequence")

func configure(config: Dictionary) -> void:
	fade_in_duration = float(config.get("fade_in_duration", fade_in_duration))
	active_duration = float(config.get("active_duration", active_duration))
	fade_out_duration = float(config.get("fade_out_duration", fade_out_duration))
	post_delay = float(config.get("post_delay", post_delay))

func _run_sequence() -> void:
	if not is_inside_tree():
		return

	get_tree().current_scene.get_node("Pausable/Audio/Thunder").play()

	var tween_in = create_tween()
	tween_in.tween_property(self, "modulate:a", 1.0, fade_in_duration).from(0.0)
	await tween_in.finished

	_set_collision_enabled(true)
	await get_tree().create_timer(active_duration, false, true).timeout

	_set_collision_enabled(false)
	var tween_out = create_tween()
	tween_out.tween_property(self, "modulate:a", 0.0, fade_out_duration).from(1.0)
	await tween_out.finished
	await get_tree().create_timer(post_delay, false, true).timeout

	call_deferred("queue_free")

func _on_hit(body: Node2D) -> void:
	if body.name != "Bird":
		return

	var zapped = get_tree().current_scene.get_node("Pausable/Audio/Zapped")
	zapped.play()
	get_tree().current_scene.get_node("Pausable/Audio/FearThePower").play()
	body.take_damage()
	get_tree().current_scene.get_node("Pausable/Audio/ZeusLaugh").play()
	_set_collision_enabled(false)

func _set_collision_enabled(enabled: bool) -> void:
	monitoring = enabled
	monitorable = enabled
	for child in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", not enabled)
