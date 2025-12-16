extends Area2D
var max_right := 500;

func disable_collision():
	monitoring = false
	monitorable = false
	for child in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", true)

func enable_collision():
	monitoring = true
	monitorable = true
	for child in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", false)

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
	var thunder = get_tree().current_scene.get_node("Pausable/Thunder")
	thunder.play()
	process_mode = Node.PROCESS_MODE_DISABLED
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
	while true:
		var thunder = get_tree().current_scene.get_node("Pausable/Thunder")
		thunder.play()		
		# Reset to right side if too far left
		if position.x < -1900:
			max_right = 500
		
		# Always spawn at max_right position
		position.x = max_right
		max_right -= 500
		
		if not get_tree().paused:
			# Fade in - lightning appears
			var tween = create_tween()
			tween.tween_property(self, "modulate:a", 1.0, 2).from(0.0)
			await tween.finished
			
			# Enable collision when fully visible
			enable_collision()
			
			# Wait while visible and active
			await get_tree().create_timer(0.5 , false, true).timeout
			
			# Fade out - lightning disappears
			var tween_out = create_tween()
			tween_out.tween_property(self, "modulate:a", 0.0, 1).from(1.0)
			
			# Disable collision when starting to fade
			disable_collision()
			
			await tween_out.finished
			print("Lightning at x:", max_right, "- Collision disabled")
