extends CharacterBody2D
@onready var hand = get_tree().current_scene.get_node("Pausable/ZeusHand")

var final_pos: Vector2 = Vector2(200, -400)  # where it should end up on screen

func _ready():
	# Start the hand off-screen (e.g., to the left)
	position = Vector2(-200, 1200)  # adjust -200 to move it further off-screen
	
	# Tween it to the final position
	await get_tree().create_timer(10).timeout
	var tween = create_tween()
	tween.tween_property(hand, "position", final_pos, 4.0)
	#call_deferred("_delayed_slide")  # avoids ready-timing issues

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
	 
