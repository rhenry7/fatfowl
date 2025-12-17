extends AnimatedSprite2D

@onready var startMenu = $"."
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position.x = 200
	position.y = -200
	get_tree().current_scene.get_node("Control/Paper").play()
	#await get_tree().create_timer(0.2).timeout
	startMenu.play()
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
