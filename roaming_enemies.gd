extends Node

@onready var enemies: Array = [$Cyclops, $Harpy]
var current_enemy_index := 0
var display_duration := 30.0
var enemy_buffer := 20.0
var initial_delay := 5.0

func _ready() -> void:
	for e in enemies:
		e.process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(initial_delay).timeout
	_cycle_enemies()

func _cycle_enemies() -> void:
	while true:
		for e in enemies:
			e.process_mode = Node.PROCESS_MODE_DISABLED
			e.deactivate()

		var current_enemy = enemies[current_enemy_index]
		current_enemy.process_mode = Node.PROCESS_MODE_INHERIT
		current_enemy.activate()

		await get_tree().create_timer(display_duration).timeout

		current_enemy.deactivate()
		current_enemy.process_mode = Node.PROCESS_MODE_DISABLED

		await get_tree().create_timer(enemy_buffer).timeout
		current_enemy_index = (current_enemy_index + 1) % enemies.size()
