extends Area2D
@onready var hand := $"."
@onready var sprite:AnimatedSprite2D = $ZeusHand/ZeusHandAnimation
var max_left = -1000
var max_right = 600

func deactivate():
	visible = false
	set_physics_process(false)
	set_process(false)
	collision_layer = 0
	collision_mask = 0
	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = true

func activate():
	position.x = 500
	position.y = 2000
	visible = true
	set_physics_process(true)
	set_process(true)
	collision_layer = 1  # Or whatever your original layer was
	collision_mask = 1   # Or whatever your original mask was
	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = false

func _process(delta: float) -> void:
	pass

func _ready():  
	process_mode = Node.PROCESS_MODE_DISABLED
	position.x = 500
	position.y = 2000
	add_to_group("hazard")
	add_to_group("ZeusHand")
	connect("body_entered", Callable(self, "_on_hit"))
	respawn()

func _on_hit(body: Node2D) -> void:
	if body.name == "Bird":
		var strangle = get_tree().current_scene.get_node("Pausable/Strangle")
		strangle.play()
		var laugh = get_tree().current_scene.get_node("Pausable/ZeusLaugh")
		laugh.play()
		body.take_damage()
		body.hide_body()
		sprite.play("HandGrab")	
		#get_tree().current_scene.get_node("Pausable/GrabTaunt").play()
			# Stay on screen time
		await get_tree().create_timer(3, false, true).timeout
		sprite.play("HandWave")
			## Slide hand out of frame
		#var off_screen_pos: Vector2 = Vector2(randf_range(-100, 1000), 1000)  # or wherever "out of frame" is
		#var tween_out = create_tween()
		#tween_out.tween_property(hand, "position", off_screen_pos, 4.0)
		#await get_tree().create_timer(3, false, true).timeout

		
func respawn() -> void:
	while true:
		# Wait 15 seconds before starting
		#await get_tree().create_timer(0, false, true).timeout
		if not get_tree().paused:
			# Slide hand into frame
			var vert = randf_range(-1600, 1600)
			var final_pos: Vector2 = Vector2(vert, 350)
			var tween = create_tween()
			tween.tween_property(hand, "position", final_pos, 10.0)
			## Wait for tween to finish
			await tween.finished
			
			# Stay on screen time
			await get_tree().create_timer(3, false, true).timeout
			
			# Slide hand out of frame
			var off_screen_pos: Vector2 = Vector2(vert, 2000)  # or wherever "out of frame" is
			var tween_out = create_tween()
			tween_out.tween_property(hand, "position", off_screen_pos, 4.0)
			
			# Wait for exit animation to finish
			await tween_out.finished
