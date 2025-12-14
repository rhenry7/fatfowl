extends Area2D

var max_right := 500;

func deactivate():
	visible = false
	set_physics_process(false)
	set_process(false)
	collision_layer = 0
	collision_mask = 0
	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = true
	process_mode = Node.PROCESS_MODE_DISABLED

func activate():
	position.x = max_right
	visible = true
	set_physics_process(true)
	set_process(true)
	collision_layer = 1  # Or whatever your original layer was
	collision_mask = 1   # Or whatever your original mask was
	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = false
	process_mode = Node.PROCESS_MODE_INHERIT

func _ready() -> void:
	add_to_group("hazard")
	connect("body_entered", Callable(self, "_on_hit"))
	respawn()
	
func _on_hit(body: Node2D) -> void:
	if body.name == "Bird":
		var zapped = get_tree().current_scene.get_node("Pausable/Zapped")
		zapped.play()
		get_tree().current_scene.get_node("Pausable/FearThePower").play()
		body.take_damage()

func respawn() -> void:
	modulate.a = 0.0
	while true:
		var thunder = get_tree().current_scene.get_node("Pausable/Thunder")
		thunder.play()
		await get_tree().create_timer(5, false, true).timeout
		if position.x < -1900:
			max_right = 500
		position.x = max_right
		max_right -= 1000
		if not get_tree().paused:
			var tween = create_tween()
			tween.tween_property(self, "modulate:a", 0, 1).from(1.0)
			await get_tree().create_timer(1, false, true).timeout
	
			#var final_pos: Vector2 = Vector2(randf_range(-1500, 400), -200)
			#tween.tween_property(bolt, "position", final_pos, 4.0)
			
			# Wait for tween to finish
			#await tween.finished
			# Stay on screen for 15 seconds
			#await get_tree().create_timer(3, false, true).timeout
			
			# Slide hand out of frame
 			#tween.tween_property(self, "modulate:a", 0.1, 5.0).from(1.0)
			var tween_out = create_tween()
			tween_out.tween_property(self, "modulate:a", 1, 0).from(1.0)
			# Wait for exit animation to finish
			await tween_out.finished
			print(max_right)
