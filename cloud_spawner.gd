extends Node2D

const NORMAL_CLOUD_SCENE = preload("res://cloud_enemies.tscn")
const ADVANCED_CLOUD_SCENE = preload("res://advanced_clouds.tscn")
const NORMAL_CLOUD_TYPES := [
	{
		"enemy_type": "angry",
		"min_speed": 800.0,
		"max_speed": 1000.0,
		"weight": 5.0,
	},
	{
		"enemy_type": "happy",
		"min_speed": 700.0,
		"max_speed": 1500.0,
		"weight": 5.0,
	},
	{
		"enemy_type": "sad",
		"min_speed": 500.0,
		"max_speed": 820.0,
		"weight": 5.5,
	},
]
const ADVANCED_CLOUD_TYPES := [
	{
		"enemy_type": "flex",
		"min_speed": 100.0,
		"max_speed": 200.0,
		"weight": 3.0,
	},
	{
		"enemy_type": "spear",
		"min_speed": 180.0,
		"max_speed": 200.0,
		"weight": 2.0,
	},
	{
		"enemy_type": "stab",
		"min_speed": 180.0,
		"max_speed": 200.0,
		"weight": 2.0,
	},
	{
		"enemy_type": "horse",
		"min_speed": 180.0,
		"max_speed": 700.0,
		"weight": 1.0,
	},
]

@export var max_active_enemies := 7
@export var normal_min_enemies_per_wave := 2
@export var normal_max_enemies_per_wave := 5
@export var advanced_min_enemies_per_wave := 1
@export var advanced_max_enemies_per_wave := 1
@export var spawn_delay_min := 3.0
@export var spawn_delay_max := 5.0
@export var intra_wave_delay := 1.0
@export var spawn_x_min := 2500.0
@export var spawn_x_max := 3200.0
@export var despawn_x := -1400.0
@export var wave_speed_step := 40.0
@export var wave_speed_max_bonus := 600.0

var _rng := RandomNumberGenerator.new()
# Keeps later waves faster than earlier ones.
var _wave_speed_bonus := 0.0

func _ready() -> void:
	_rng.randomize()
	_clear_legacy_clouds()
	await get_tree().process_frame
	_spawn_loop()

func _clear_legacy_clouds() -> void:
	# The old scene had three hand-placed cloud variants as children.
	# The new structure spawns reusable cloud instances instead.
	for child in get_children():
		child.queue_free()

func _spawn_loop() -> void:
	while true:
		if get_tree().paused or not visible:
			await get_tree().process_frame
			max_active_enemies += 1
			continue

		# Run the two pools separately so each wave can have its own size and pacing.
		await _spawn_wave(
			NORMAL_CLOUD_SCENE,
			NORMAL_CLOUD_TYPES,
			normal_min_enemies_per_wave,
			normal_max_enemies_per_wave
		)
		await _spawn_wave(
			ADVANCED_CLOUD_SCENE,
			ADVANCED_CLOUD_TYPES,
			advanced_min_enemies_per_wave,
			advanced_max_enemies_per_wave
		)

		var delay: float = _rng.randf_range(spawn_delay_min, spawn_delay_max)
		await get_tree().create_timer(delay, false).timeout

func _spawn_wave(scene: PackedScene, enemy_types: Array, min_enemies: int, max_enemies: int) -> void:
	var open_slots: int = max_active_enemies - _active_enemy_count()
	if open_slots <= 0 or enemy_types.is_empty():
		return

	var wave_min: int = min(min_enemies, max_enemies)
	var wave_max: int = max(min_enemies, max_enemies)
	var wave_size: int = min(open_slots, _rng.randi_range(wave_min, wave_max))
	if wave_size <= 0:
		return

	var wave_speed_bonus: float = _next_wave_speed_bonus()
	for i in range(wave_size):
		_spawn_enemy(scene, enemy_types, wave_speed_bonus)
		if i < wave_size - 1:
			await get_tree().create_timer(intra_wave_delay, false).timeout

func _spawn_enemy(scene: PackedScene, enemy_types: Array, speed_bonus: float = 0.0) -> void:
	var config: Dictionary = _pick_enemy_type(enemy_types)
	config["spawn_x_min"] = spawn_x_min
	config["spawn_x_max"] = spawn_x_max
	config["despawn_x"] = despawn_x
	config["spawn_speed_bonus"] = speed_bonus

	var enemy: Node = scene.instantiate()
	add_child(enemy)

	if enemy.has_method("configure"):
		enemy.configure(config)

func _next_wave_speed_bonus() -> float:
	var current_bonus: float = _wave_speed_bonus
	_wave_speed_bonus = min(_wave_speed_bonus + wave_speed_step, wave_speed_max_bonus)
	return current_bonus

func _active_enemy_count() -> int:
	var count := 0
	for child in get_children():
		if not child.is_queued_for_deletion():
			count += 1
	return count

func _pick_enemy_type(enemy_types: Array) -> Dictionary:
	var total_weight := 0.0

	for config in enemy_types:
		total_weight += float(config.get("weight", 1.0))

	var roll := _rng.randf() * total_weight
	for config in enemy_types:
		roll -= float(config.get("weight", 1.0))
		if roll <= 0.0:
			return config.duplicate()

	return enemy_types.back().duplicate()
