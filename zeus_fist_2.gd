extends "res://zeus_fist.gd"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	position.x = get_viewport().size.x * 1
	position.y = 100
	add_to_group("hazard")
	add_to_group("ZeusHand")
	connect("body_entered", Callable(self, "_on_hit"))
	respawn()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func respawn() -> void:
	while true:
		# Wait 15 seconds before starting
		#await get_tree().create_timer(0, false, true).timeout
		if not get_tree().paused:
			# Slide hand into frame
			var height = get_viewport().size.y * 0.2
			var width = get_viewport().size.x * 1 
			var final_pos: Vector2 = Vector2(width, -800) 
			var tween = create_tween()
			tween.tween_property(hand, "position", final_pos, 0.8)
			## Wait for tween to finish
			await tween.finished
			 
			# Stay on screen time
			await get_tree().create_timer(2, false, true).timeout
			
			var off_screen_pos: Vector2 = Vector2(width, height * -0.6)  # or wherever "out of frame" is
			var tween_out = create_tween()
			tween_out.tween_property(hand, "position", off_screen_pos, 1.5)
			
			# Wait for exit animation to finish
			await tween_out.finished
		else:
			await get_tree().process_frame
