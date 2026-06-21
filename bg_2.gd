extends Sprite2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fade_out()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func fade_out():
	await get_tree().create_timer(120).timeout
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.1, 240.0)
	await tween.finished
	queue_free()
