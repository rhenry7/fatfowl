extends Node2D
@onready var startMenu = $"Control"
@onready var lifebar = $"Pausable/UI"
@onready var cloudEnemies = $"Pausable/CloudEnemies"
@onready var zeusBody = $"Pausable/Enemies"
@onready var player = $"Pausable/Bird"




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lifebar.visible = false
	cloudEnemies.visible = false
	zeusBody.visible = false
	player.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
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


func _on_zeus_hurt_box_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_start_button_pressed() -> void:
	get_tree().paused = false
	get_tree().current_scene.get_node("Pausable/Prepare").play()
	#var tween = create_tween()
	#tween.tween_property(startMenu, "modulate:a", 0.0, 1.0).from(1.0)
	#await tween.finished
	startMenu.visible = false
	lifebar.visible = true
	cloudEnemies.visible = true
	zeusBody.visible = true
	player.visible = true
	pass # Replace with function body.
