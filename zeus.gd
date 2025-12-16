extends AnimatedSprite2D
@onready var sprite: AnimatedSprite2D = $"."



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Start invsible
	modulate.a = 0.0
	await get_tree().create_timer(5).timeout
	#get_tree().current_scene.get_node("Pausable/FearThePower").play()
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.6, 120.0).from(0.0)
	#await get_tree().create_timer(30).timeout
	#get_tree().current_scene.get_node("Pausable/ZeusRant2").play()
	#await get_tree().create_timer(30).timeout
	#get_tree().current_scene.get_node("Pausable/ZeusRant3").play()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
