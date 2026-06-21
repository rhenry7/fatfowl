extends AnimatedSprite2D

const GREEK_FREAK_FONT = preload("res://Greek-Freak.ttf")

var canvas_layer: CanvasLayer
var game_started := false

func _ready() -> void:
	position.x = 200
	position.y = -200
	get_tree().current_scene.get_node("Control/Paper").play()
	play("intro")
	await get_tree().process_frame
	await get_tree().create_timer(0.5, true).timeout
	if not game_started:
		_show_labels()

func _show_labels() -> void:
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 2
	get_tree().current_scene.add_child(canvas_layer)

	var scroll_pos = get_global_transform_with_canvas().origin

	var title = Label.new()
	title.text = "PHOENIX FYRE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", GREEK_FREAK_FONT)
	title.add_theme_font_size_override("font_size", 140)
	title.add_theme_color_override("font_color", Color8(33, 27, 197))
	title.size = Vector2(900, 220)
	title.position = Vector2(scroll_pos.x - 450, scroll_pos.y - 250)
	canvas_layer.add_child(title)

	var body = Label.new()
	body.text = (
		"Avenge your family, destroy the gods! \n"
		+ "Press 'A' and 'D' to go horizontally. 'SPACE' to fly \n"
		+ "'L' to shoot. 'P' to pause.\n"
		+ "Press 'SPACE' to start."
	)
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# body.add_theme_font_override("font", GREEK_FREAK_FONT)
	body.add_theme_font_size_override("font_size", 42)
	body.add_theme_color_override("font_color", Color8(33, 27, 197))
	body.size = Vector2(1000, 260)
	body.position = Vector2(scroll_pos.x - 550, scroll_pos.y - 70)
	canvas_layer.add_child(body)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not game_started:
		game_started = true
		if canvas_layer:
			canvas_layer.queue_free()
		get_tree().current_scene._on_start_button_pressed()
