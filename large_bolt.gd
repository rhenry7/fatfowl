extends CharacterBody2D
@onready var bolt = get_tree().current_scene.get_node("Pausable/LargeBolt")

func _ready() -> void:
	respawn()

func respawn() -> void:
	modulate.a = 0.0
	while true:
		# Wait 15 seconds before starting
		await get_tree().create_timer(15, false, true).timeout
		
		if not get_tree().paused:
			# Slide hand into frame
			position.x = randf_range(-1500, 400)
			var tween = create_tween()
			tween.tween_property(self, "modulate:a", 1, 5.0).from(0.0)
			#var final_pos: Vector2 = Vector2(randf_range(-1500, 400), -200)
			#tween.tween_property(bolt, "position", final_pos, 4.0)
			
			# Wait for tween to finish
			#await tween.finished
			# Stay on screen for 15 seconds
			#await get_tree().create_timer(3, false, true).timeout
			
			# Slide hand out of frame
 			#tween.tween_property(self, "modulate:a", 0.1, 5.0).from(1.0)
			var tween_out = create_tween()
			tween_out.tween_property(self, "modulate:a", 0, 5.0).from(1.0)
			
			# Wait for exit animation to finish
			await tween_out.finished
