class_name CyclopsEnemy
extends CloudBase

@export var min_speed: float = 100.0
@export var max_speed: float = 200.0
@export var spawn_x_min: float = 2500.0
@export var spawn_x_max: float = 3200.0
@export var despawn_x: float = -2000.0
@export var respawn_delay: float = 60.0
@onready var animated_sprite: AnimatedSprite2D = $Sprite2D
@onready var random_delay = randf_range(0.0, 0.5);

var speed: float = 0.0
var _active: bool = false
var _respawning: bool = false
var _hit_count: int = 0
var _anim_index: int = 0

func _ready() -> void:
	add_to_group("hazard")
	body_entered.connect(_on_body_entered)
	animated_sprite.play("default")
	cache_sprite_y_bounds()
	visible = false
	monitoring = false
	monitorable = false
	set_process(true)

func activate() -> void:
	await get_tree().create_timer(random_delay).timeout
	if not is_inside_tree() or process_mode == Node.PROCESS_MODE_DISABLED:
		return

	_respawning = false
	_active = true
	_hit_count = 0
	visible = true
	monitoring = true
	monitorable = true
	position.x = randf_range(spawn_x_min, spawn_x_max)
	position.y = screen_y()
	speed = randf_range(min_speed, max_speed)
	var anim_names := animated_sprite.sprite_frames.get_animation_names()
	animated_sprite.play(anim_names[_anim_index % anim_names.size()])
	_anim_index += 1
	_set_collision_enabled(true)

func _process(delta: float) -> void:
	if not _active or _respawning or get_tree().paused or _game_finished():
		return

	position.x -= speed * delta
	if position.x < despawn_x:
		_begin_respawn()

func on_hit() -> int:
	_hit_count += 1
	if _hit_count >= 5:
		_hit_count = 0
		var kill_pos := global_position
		var bird = get_tree().current_scene.get_node_or_null("Pausable/Bird")
		if bird and bird.has_method("add_kill"):
			bird.add_kill()
		ScorePopup.spawn(kill_pos, 1000)
		_begin_respawn()
		return 1000
	return 0

func _on_body_entered(body: Node2D) -> void:
	if not _active or _respawning:
		return
	if body.name != "Bird":
		return

	var zapped: AudioStreamPlayer2D = get_tree().current_scene.get_node_or_null("Pausable/Audio/Zapped")
	if zapped != null:
		zapped.play()
	body.take_damage()


func _begin_respawn() -> void:
	if _respawning:
		return

	_active = false
	_respawning = true
	visible = false
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	_set_collision_enabled(false)
	await get_tree().create_timer(respawn_delay, false).timeout
	if not is_inside_tree() or _game_finished() or not _respawning:
		return

	_respawning = false
	activate()

func deactivate() -> void:
	_active = false
	_respawning = false
	_hit_count = 0
	visible = false
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	_set_collision_enabled(false)

func _set_collision_enabled(enabled: bool) -> void:
	for child in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", not enabled)

func _game_finished() -> bool:
	var game_over_card: TextureButton = get_tree().current_scene.get_node_or_null("Pausable/UI/GameOver")
	return game_over_card != null and game_over_card.visible
