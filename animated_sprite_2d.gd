extends AnimatedSprite2D


@onready var lightning = $AnimatedSprite2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lightning.play("shock")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
