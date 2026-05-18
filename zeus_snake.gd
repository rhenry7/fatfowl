extends Area2D
@onready var sprite = $AnimatedSprite2D
@export var amplitude: float = 4.0  # How far it moves (pixels)
@export var frequency: float = 2.0  # How fast it oscillates

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.play("default")
	run_attack_loop()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x = position.x + sin(Time.get_ticks_msec() / 1000.0 * frequency) * amplitude
	
func run_attack_loop() -> void:
	while true:
		await get_tree().create_timer(5.0).timeout
		sprite.play("attack")
		
		await sprite.animation_finished
		sprite.play("default")
