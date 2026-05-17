extends "res://zeus_hurt_box.gd"
@onready var positionx = get_viewport().size.x * 0.17

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	position = Vector2(positionx, 300)
	add_to_group("hazard")
	add_to_group("ZeusHand")
	connect("body_entered", Callable(self, "_on_hit"))
	respawn()

func respawn() -> void:
	while true:
		# Wait 15 seconds before starting
		#await get_tree().create_timer(0, false, true).timeout
		if not get_tree().paused:
			# Slide hand into frame
			position.y = 2000
			var final_pos: Vector2 = Vector2(positionx, -400)
			var tween = create_tween()
			tween.tween_property(hand, "position", final_pos, 6.0)
			## Wait for tween to finish
			await tween.finished
			
			# Stay on screen time 
			await get_tree().create_timer(3, false, true).timeout
			
			# Slide hand out of frame
			var off_screen_pos: Vector2 = Vector2(positionx, 2000)  # or wherever "out of frame" is
			var tween_out = create_tween()
			tween_out.tween_property(hand, "position", off_screen_pos, 6.0)
			
			# Wait for exit animation to finish
			await tween_out.finished
		else:
			await get_tree().process_frame
