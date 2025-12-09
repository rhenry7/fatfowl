extends CharacterBody2D
@onready var hand = get_tree().current_scene.get_node("Pausable/ZeusHand")
var max_left = -900
var max_right = 500


func _process(delta: float) -> void:
	pass

func _ready():
	# Start the hand off-screen (e.g., to the left)	
	position = Vector2(-200, 2000)
	respawn()
	add_to_group("hazard")
	connect("body_entered", Callable(self, "_on_hit"))
	#call_deferred("_delayed_slide")  # avoids ready-timing issues
	
func _on_hit(body: Node2D) -> void:
	if body.name == "Bird":
		body.take_damage()
		
func respawn() -> void:
	while true:
		await get_tree().create_timer(10, false, true).timeout
		if not get_tree().paused:
			var final_pos: Vector2 = Vector2(randf_range(-1500, 500), -200)
			# Tween it to the final position
			var tween = create_tween()
			tween.tween_property(hand, "position", final_pos, 4.0)
	


#func _delayed_slide():
	#await get_tree().create_timer(5).timeout   # 🔥 wait 20 seconds
#
	#var tween = get_tree().create_tween()
	#tween.tween_property(
		#hand,
		#"position",
		#end_pos,
		#1.2                                # duration of slide
	#).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	 
