extends CharacterBody2D

const GRAVITY = 2000.0
const FLAP_STRENGTH = -400.0
const FLAP_STRENGTH_X = 600.0 
const SPEED = 10.0 
const TOP_Y = -850
const BOTTOM_Y = 1500
const MAX_HEARTS := 3   
var HEARTS := MAX_HEARTS
var IS_DEAD := false

@onready var sprite:AnimatedSprite2D = $AnimatedSprite2D
@onready var hearts_container := get_tree().current_scene.get_node("Pausable/UI/HeartsContainer")
@onready var game_over_card := get_tree().current_scene.get_node("Pausable/UI/GameOver")

func remove_heart():
	if HEARTS <= 0:
		return
	HEARTS -= 1
	var heart_to_hide = hearts_container.get_child(HEARTS)
	var c = heart_to_hide.modulate
	heart_to_hide.modulate = Color(c.r, c.g, c.b, 0.0)

func on_damage(amount):
	#Effects.flash_opacity(sprite)
	print("damage received:", amount)

func _ready() -> void:
	position.x = 100
	position.y = -500
	$Hurtbox.body_entered.connect(_on_body_entered)
	sprite.play("fly")

func _on_body_entered(body):
	print("Collision with:", body.name)
	if body.is_in_group("hazard"):
		print("Body is in group")
		take_damage()

func take_damage():
	if IS_DEAD:
		return
	remove_heart()
	var zapped = get_tree().current_scene.get_node("Pausable/Zapped")
	zapped.play()
	print("Player took damage! Hearts left:", HEARTS)
	sprite.play("shocked")
	if HEARTS <= 0:
		die()
	#respawn()

func die():
	IS_DEAD = true
	print("GAME OVER")
	if IS_DEAD:
		get_tree().current_scene.get_node("Pausable/Bird").process_mode = Node.PROCESS_MODE_DISABLED
		get_tree().current_scene.get_node("Pausable/UI/GameOver").visible = true
		var music = get_tree().current_scene.get_node("Pausable/Music")
		music.stop()
		await get_tree().create_timer(1).timeout
		get_tree().current_scene.get_node("Pausable/Bird").visible = false
		var outro = get_tree().current_scene.get_node("Pausable/ZeusOutro")
		outro.play()
		#get_tree().current_scene.get_node("UI/Pause_Play").disabled = true
	

func respawn() -> void:
	position.x = -200
	position.y = -1350

func _physics_process(delta: float) -> void:
	# Add the gravity.
	velocity.y += GRAVITY * delta
	velocity.y = clamp(velocity.y, FLAP_STRENGTH, GRAVITY)
	velocity.x = 0
	position.y = clamp(position.y, TOP_Y, BOTTOM_Y)
	position.x = clamp(position.x, -250, 2000)
	
	if(position.y > 1000):
		# take_damage()
		respawn()
		
	if Input.is_action_just_pressed("fly"):
		velocity.y = FLAP_STRENGTH
		sprite.play("fly")
	if Input.is_action_just_pressed("fly-right"):
		velocity.x = FLAP_STRENGTH_X
		sprite.play("fly")
	elif Input.is_action_just_pressed("fly-left"):
		velocity.x = -FLAP_STRENGTH_X
		sprite.play("fly")
		
		
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED 
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
