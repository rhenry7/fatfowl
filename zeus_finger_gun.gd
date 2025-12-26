extends Area2D
var max_right := 100;
var speed := 0;
@onready var sprite = $ZeusFingerShoot

@onready var hurtbox = $ZeusLightArea


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
	process_mode = Node.PROCESS_MODE_DISABLED
	position.y = randf_range(-700.00, 700.00)
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
		if not get_tree().paused:
			# Fade in - lightning appears
			#var thunder = get_tree().current_scene.get_node("Pausable/Thunder")
			#thunder.play()		
			# Enable collision when fully visible
			enable_collision()
			
			# Wait while visible and active
			await get_tree().create_timer(2.0 , false, true).timeout
			
			# Disable collision when starting to fade
			disable_collision()
			# HARD MODE
			# position.y = randf_range(-700.00, 700.00)
			
