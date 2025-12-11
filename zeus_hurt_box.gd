extends Area2D
@onready var hand := $"."
var max_left = -1000
var max_right = 600

func deactivate():
	visible = false
	set_physics_process(false)
	set_process(false)

	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = true


func activate():
	visible = true
	set_physics_process(true)
	set_process(true)

	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = false

func _process(delta: float) -> void:
	pass

func _ready():  
	position.x = 50
	position.y = 500
	respawn()
	add_to_group("hazard")
	connect("body_entered", Callable(self, "_on_hit"))

func _on_hit(body: Node2D) -> void:
	if body.name == "Bird":
		body.take_damage()
		print("Hand and bird meet")
		
func respawn() -> void:
	while true:
		# Wait 15 seconds before starting
		#await get_tree().create_timer(0, false, true).timeout
		if not get_tree().paused:
			# Slide hand into frame
			var final_pos: Vector2 = Vector2(randf_range(10, 500), 500)
			var tween = create_tween()
			tween.tween_property(hand, "position", final_pos, 5.0)
			#
			## Wait for tween to finish
			await tween.finished
			
			# Stay on screen time
			await get_tree().create_timer(3, false, true).timeout
			
			# Slide hand out of frame
			var off_screen_pos: Vector2 = Vector2(randf_range(0, 2400), 2000)  # or wherever "out of frame" is
			var tween_out = create_tween()
			tween_out.tween_property(hand, "position", off_screen_pos, 4.0)
			
			# Wait for exit animation to finish
			await tween_out.finished
