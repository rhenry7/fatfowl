extends "res://large_bolt.gd"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	add_to_group("hazard")
	add_to_group("ZeusHand")
	connect("body_entered", Callable(self, "_on_hit"))
	respawn()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
