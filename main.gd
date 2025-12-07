extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func toggle_pause() -> void:
	get_tree().paused = !get_tree().paused

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_pause"):
		toggle_pause()




func _on_game_over_pressed() -> void:
	get_tree().reload_current_scene() # Replace with function body.
