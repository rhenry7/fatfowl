extends Node2D

@export var speed := 150.0
@export var spawn_margin := 100.0
@export var right_spawn_offset := 200.0
@export var top_y := -2200.0
@export var bottom_y := 50.0

func _process(delta: float) -> void:
	position.x -= speed * delta
	var cam := get_viewport().get_camera_2d()
	if cam:
		var left_bound := cam.global_position.x - (get_viewport().get_visible_rect().size.x / 2) - spawn_margin
		if position.x < left_bound:
			
			respawn(cam)

func respawn(cam: Camera2D = null) -> void:
	var view_width := get_viewport().get_visible_rect().size.x

	var right_x = 50
	var random_y = randf_range(top_y, bottom_y)
	modulate.a = 1.0        # restore visibility
	position = Vector2(right_x, random_y)
