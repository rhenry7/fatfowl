extends Node2D

const CLOUD_SCENE = preload("res://cloud_enemies.tscn")
const ADVANCED_CLOUD = preload("res://advanced_clouds.tscn")
const CLOUD_TYPES := [
	{
		"enemy_type": "angry",
		"min_speed": 60.0,
		"max_speed": 1000.0,
		"weight": 4.0,
	},
	{
		"enemy_type": "happy",
		"min_speed": 180.0,
		"max_speed": 1500.0,
		"weight": 4.0,
	},
	{
		"enemy_type": "sad",
		"min_speed": 180.0,
		"max_speed": 820.0,
		"weight": 4.0,
	},
	{
		"enemy_type": "flex",
		"min_speed": 180.0,
		"max_speed": 300.0,
		"weight": 6.0,
	},
	{
		"enemy_type": "spear",
		"min_speed": 180.0,
		"max_speed": 300.0,
		"weight": 4.0,
	},
	{
		"enemy_type": "stab",
		"min_speed": 180.0,
		"max_speed": 500.0,
		"weight": 5.0,
	},
	{
		"enemy_type": "horse",
		"min_speed": 180.0,
		"max_speed": 500.0,
		"weight": 8.0,
	},
]

@export var max_active_enemies := 5
@export var min_enemies_per_wave := 1
@export var max_enemies_per_wave := 3
@export var spawn_delay_min := 5.0
@export var spawn_delay_max := 10.0
@export var intra_wave_delay := 0.35
@export var spawn_x_min := 2500.0
@export var spawn_x_max := 3200.0
@export var despawn_x := -1400.0

var _rng := RandomNumberGenerator.new()

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

		var open_slots = max_active_enemies - _active_enemy_count()
		if open_slots > 0:
			var wave_size = min(open_slots, _rng.randi_range(min_enemies_per_wave, max_enemies_per_wave))
			for i in range(wave_size):
				_spawn_enemy()
				if i < wave_size - 1:
					await get_tree().create_timer(intra_wave_delay, false).timeout

		var delay = _rng.randf_range(spawn_delay_min, spawn_delay_max)
		await get_tree().create_timer(delay, false).timeout

const ADVANCED_TYPES := ["horse"]

func _spawn_enemy() -> void:
	var config = _pick_enemy_type()
	config["spawn_x_min"] = spawn_x_min
	config["spawn_x_max"] = spawn_x_max
	config["despawn_x"] = despawn_x

	var scene = ADVANCED_CLOUD if config["enemy_type"] in ADVANCED_TYPES else CLOUD_SCENE
	var enemy = scene.instantiate()
	add_child(enemy)

	if enemy.has_method("configure"):
		enemy.configure(config)

func _active_enemy_count() -> int:
	var count := 0
	for child in get_children():
		if not child.is_queued_for_deletion():
			count += 1
	return count

func _pick_enemy_type() -> Dictionary:
	var total_weight := 0.0
	
	for config in CLOUD_TYPES:
		total_weight += float(config.get("weight", 1.0))

	var roll := _rng.randf() * total_weight
	for config in CLOUD_TYPES:
		roll -= float(config.get("weight", 1.0))
		if roll <= 0.0:
			return config.duplicate()

	return CLOUD_TYPES.back().duplicate()
	
