extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_pause_play_toggled(pressed: bool) -> void:
	if pressed:
		get_tree().paused = false
	else:
		get_tree().paused = true


func _on_game_over_pressed() -> void:
	get_tree().reload_current_scene() # Replace with function body.
