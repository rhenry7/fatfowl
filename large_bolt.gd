extends Area2D
var max_right := 100;
var speed := 0;


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
	
	
func speed_increase_loop() -> void:
	print("current speed", speed)
	if speed >= 1500:
		return
	speed += 50
	
	
func activate():
	position.x = 100
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
	process_mode = Node.PROCESS_MODE_DISABLED
	position.x = 500
	add_to_group("hazard")
	connect("body_entered", Callable(self, "_on_hit"))
# Left edge center
	var left = Vector2(0, get_viewport_rect().size.y / 2)
	# Right edge center
	var right = Vector2(get_viewport_rect().size.x, get_viewport_rect().size.y / 2)
	# Top center
	var top = Vector2(get_viewport_rect().size.x / 2, 0)
	# Bottom center
	var bottom = Vector2(get_viewport_rect().size.x / 2, get_viewport_rect().size.y)
	# Center of viewport
	var center = get_viewport_rect().size / 2
	respawn()
	
func _on_hit(body: Node2D) -> void:
	if body.name == "Bird":
		var zapped = get_tree().current_scene.get_node("Pausable/Audio/Zapped")
		zapped.play()
		get_tree().current_scene.get_node("Pausable/Audio/FearThePower").play()
		body.take_damage()
		get_tree().current_scene.get_node("Pausable/Audio/ZeusLaugh").play()
		
		
func respawn() -> void:
	while true:
		# Reset to right side if too far left
		if position.x < -2000:
			max_right = 100
		
		# Always spawn at max_right position
		position.x = max_right
		max_right -= 300
		
		if not get_tree().paused:
			# Fade in - lightning appears
			get_tree().current_scene.get_node("Pausable/Audio/Thunder").play()
			var tween = create_tween()
			#var thunder = get_tree().current_scene.get_node("Pausable/Thunder")
			#thunder.play()		
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
			await get_tree().create_timer(5.0 , false, true).timeout
			print("Lightning at x:", max_right, "- Collision disabled")
