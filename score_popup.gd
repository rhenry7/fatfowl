class_name ScorePopup
extends Node2D

const FONT := preload("res://Greek-Freak.ttf")
var _text: String = ""

static func spawn(world_pos: Vector2, score: int) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if not tree:
		return
	var popup := ScorePopup.new()
	popup._text = "+" + str(score)
	tree.current_scene.add_child(popup)
	popup.global_position = world_pos
	popup.queue_redraw()

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	queue_free()

func _draw() -> void:
	draw_string(FONT, Vector2(-40, 0), _text, HORIZONTAL_ALIGNMENT_LEFT, -1, 72, Color(168.0/255.0, 254.0/255.0, 117.0/255.0, 1.0))
