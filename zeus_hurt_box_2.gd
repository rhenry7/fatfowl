extends "res://zeus_hurt_box.gd"

@export var start_position: Vector2 = Vector2(-150,  100)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	position = start_position
	add_to_group("hazard")
	add_to_group("ZeusHand")
	connect("body_entered", Callable(self, "_on_hit"))
	respawn()
