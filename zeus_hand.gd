extends CharacterBody2D
@onready var hand = get_tree().current_scene.get_node("Pausable/ZeusHand")
var max_left = -1000
var max_right = 600

func _process(delta: float) -> void:
	pass

func _ready():
	# Start the hand off-screen (e.g., to the left)	
	position = Vector2(-200, 2000)
	respawn()
	add_to_group("hazard")
	connect("body_entered", Callable(self, "_on_hit"))
	
func _on_hit(body: Node2D) -> void:
	if body.name == "Bird":
		body.take_damage()
		
func respawn() -> void:
	while true:
		# Wait 15 seconds before starting
		await get_tree().create_timer(15, false, true).timeout
		
		if not get_tree().paused:
			# Slide hand into frame
			var final_pos: Vector2 = Vector2(randf_range(-1500, 400), -200)
			var tween = create_tween()
			tween.tween_property(hand, "position", final_pos, 4.0)
			
			# Wait for tween to finish
			await tween.finished
			
			# Stay on screen for 15 seconds
			await get_tree().create_timer(3, false, true).timeout
			
			# Slide hand out of frame
			var off_screen_pos: Vector2 = Vector2(randf_range(1500, 400), 2000)  # or wherever "out of frame" is
			var tween_out = create_tween()
			tween_out.tween_property(hand, "position", off_screen_pos, 4.0)
			
			# Wait for exit animation to finish
			await tween_out.finished

	 
