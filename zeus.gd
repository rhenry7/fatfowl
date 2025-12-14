extends AnimatedSprite2D
@onready var sprite: AnimatedSprite2D = $"."

func introTaunt() -> void:
	await get_tree().create_timer(5).timeout
	var intro = get_tree().current_scene.get_node("Pausable/ZeusIntro")
	intro.play()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Start invsible
	introTaunt()
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.6, 20.0).from(0.0)
	await get_tree().create_timer(30).timeout
	sprite.play()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
