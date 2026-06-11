extends Sprite2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fade_out()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func fade_out():
	var tween = create_tween()
	# Fades the alpha (opacity) to 0.0 over 1.0 seconds
	tween.tween_property(self, "modulate:a", 0.3, 360.0)
	
	# Optional: Delete the node when the fade finishes
	await tween.finished
	queue_free()
