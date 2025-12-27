extends Area2D

var speed := randf_range(300, 500)
@onready var load_y_position = randf_range(300, -500)

func _process(delta: float) -> void:
	position.x += speed * delta
	print("pegasus position: ", position.x)
	if position.x > 4500:
		respawn()

func respawn() -> void:
	position.y = randf_range(-100, 700)
	position.x = randf_range(-2000, 20)
	speed_increase_loop()
	
func _on_body_entered(body):
	# Check if the object that collided is the player
	# call_deferred(collision).disabled = true
	if body.is_in_group("player"):
		print("Peggy connected to player")
		# Check if player has a heal method
		if body.has_method("addCoin"):
			print("Peggy gives coins to player")
			# Give player 1 heart (change to health_amount if you want to use the export variable)
			body.addCoin(100)
			get_tree().current_scene.get_node("Pausable/Audio/CoinGroup").play()

func _ready():
	position.x = -1800
	position.y = load_y_position
	body_entered.connect(_on_body_entered)

func _on_hit(body: Node2D) -> void:
	if body.name == "Bird":
		# upgrade gravity with gravity boost
		print("Horse and Bird collision")
		
func speed_increase_loop() -> void:
	print("current speed", speed)
	if speed >= 1500:
		return
	speed += 10
