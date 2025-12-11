extends Node

@onready var enemies = [
	$ZeusHurtBox,
	$Cloud,
	$LargeBolt,
]

var current_enemy_index := 0
var display_duration := 60.0   # seconds per enemy

func _ready():
	print(get_path())
	# hide everything initially
	for e in enemies:
		e.deactivate()

	# start the cycle
	cycle_enemies()
	

func cycle_enemies() -> void:
	# loop forever
	while true:
		# get current enemy
		var current_enemy = enemies[current_enemy_index]

		# show it
		current_enemy.activate()
		# wait for its display time
		await get_tree().create_timer(display_duration).timeout
		# hide it afterwards
		current_enemy.deactivate()


		# move to next enemy (cyclic)
		current_enemy_index = (current_enemy_index + 1) % enemies.size()
