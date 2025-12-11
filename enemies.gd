extends Node
@onready var enemies = [
	$Cloud,
	$LargeBolt,
	$ZeusHurtBox,
]
var current_enemy_index := 0
var display_duration := 30.0   # seconds per enemy
var enemy_buffer := 3
var initial_delay := 5.0

func _ready():
	print(get_path())
	# Enemies are already disabled in editor, so their _ready() won't run
	# Wait before starting the cycle
	await get_tree().create_timer(2).timeout
	# start the cycle
	cycle_enemies()
	
func cycle_enemies() -> void:
	while true:
		# DEACTIVATE ALL first to ensure clean state
		for e in enemies:
			e.process_mode = Node.PROCESS_MODE_DISABLED
			e.deactivate()
		
		# get current enemy
		var current_enemy = enemies[current_enemy_index]
		# Enable and show it
		current_enemy.process_mode = Node.PROCESS_MODE_INHERIT
		current_enemy.activate()
		# wait for its display time
		await get_tree().create_timer(display_duration).timeout
		# hide it afterwards
		current_enemy.deactivate()
		current_enemy.process_mode = Node.PROCESS_MODE_DISABLED
		await get_tree().create_timer(enemy_buffer).timeout
		# move to next enemy (cyclic)
		current_enemy_index = (current_enemy_index + 1) % enemies.size()
