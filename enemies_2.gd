extends Node
@onready var enemies = [
	$ZeusFist,
	$ZeusHurtBox,
	$LargeBolt,
]
var current_enemy_index := 0
var display_duration := 15.0   # seconds per enemy
var enemy_buffer := 15.0
var initial_delay := 10.0

func _ready():
	await get_tree().create_timer(initial_delay).timeout
	cycle_enemies()
	
func cycle_enemies() -> void:
	while true:
		# DEACTIVATE ALL first to ensure clean state
		for e in enemies:
			e.process_mode = Node.PROCESS_MODE_DISABLED
			e.deactivate()
			print("Going to deactivate", e)
		
		# get current enemy
		var current_enemy = enemies[current_enemy_index]
		print("now at current enemy", current_enemy)
		# Enable and show it
		current_enemy.process_mode = Node.PROCESS_MODE_INHERIT
		current_enemy.activate()
		print("enemy process mode", current_enemy.process_mode)
		# wait for its display time
		await get_tree().create_timer(display_duration).timeout
		# hide it afterwards
		current_enemy.deactivate()
		current_enemy.process_mode = Node.PROCESS_MODE_DISABLED
		print("enemy process mode", current_enemy.process_mode)
		await get_tree().create_timer(enemy_buffer).timeout
		# move to next enemy (cyclic)
		current_enemy_index = (current_enemy_index + 1) % enemies.size()
