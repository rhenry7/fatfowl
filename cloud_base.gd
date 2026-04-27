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
