class_name CloudBase
extends Area2D

var _sprite_y_min: float = -1199.0
var _sprite_y_max: float = -549.0

func cache_sprite_y_bounds() -> void:
	for child in get_children():
		if child is AnimatedSprite2D:
			var frames = child.sprite_frames
			if frames == null:
				return
			var anim = child.animation
			if frames.get_frame_count(anim) == 0:
				return
			var tex = frames.get_frame_texture(anim, 0)
			if tex == null:
				return
			var half_h = tex.get_size().y * 0.5 * child.scale.y
			_sprite_y_min = child.position.y - half_h
			_sprite_y_max = child.position.y + half_h
			return

func on_hit() -> void:
	var kill_pos := global_position
	var bird = get_tree().current_scene.get_node_or_null("Pausable/Bird")
	if bird and bird.has_method("add_kill"):
		bird.add_kill()
	ScorePopup.spawn(kill_pos, 100)
	set_deferred("visible", false)
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	set_process(false)
	set_physics_process(false)
	for child in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", true)
	await get_tree().create_timer(3.0, false, true).timeout
	if not is_inside_tree():
		return
	position.x = randf_range(1000, 3000)
	position.y = screen_y()
	visible = true
	monitoring = true
	monitorable = true
	set_process(true)
	set_physics_process(true)
	for child in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", false)

func screen_y() -> float:
	if not is_inside_tree():
		return position.y
	var inv = get_canvas_transform().affine_inverse()
	var vp = get_viewport_rect()
	var viewport_top = (inv * vp.position).y
	var viewport_bottom = (inv * (vp.position + vp.size)).y
	var sprite_height = _sprite_y_max - _sprite_y_min
	var max_clip = sprite_height * 0.2
	var y_min = viewport_top - max_clip - _sprite_y_min
	var y_max = viewport_bottom + max_clip - _sprite_y_max
	if y_min > y_max:
		return (y_min + y_max) * 0.5
	return randf_range(y_min, y_max)
