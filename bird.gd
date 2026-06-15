extends CharacterBody2D
var GRAVITY = 2000
# const FLAP_STRENGTH = -350.0 # original speed
const FLAP_STRENGTH = -700.0
const FLAP_STRENGTH_X = 400.0
const SPEED = 10.0
const TOP_Y = -850
const BOTTOM_Y = 1500
const MAX_HEARTS := 3
var HEARTS := 3
var IS_DEAD := false
var is_invincible := false
var invincibility_duration := 2.0  # Increased to match usage
var fireball = preload("res://fireball.tscn")
const GREEK_FREAK_FONT = preload("res://Greek-Freak.ttf")

var shots_fired: int = 0
var enemies_killed: int = 0
var damage_taken: int = 0

@onready var sprite:AnimatedSprite2D = $AnimatedSprite2D
@onready var hearts_container := get_tree().current_scene.get_node("Pausable/UI/HeartsContainer")
@onready var game_over_card := get_tree().current_scene.get_node("Pausable/UI/GameOver")
@onready var coinDisplay = get_tree().current_scene.get_node("Pausable/UI/Coins")
@onready var distanceDisplay = get_tree().current_scene.get_node("Pausable/UI/Distance")
@onready var dash_bar: ProgressBar = get_tree().current_scene.get_node("Pausable/UI/DashBar")
@onready var feathers:int = 0
@onready var coins: int = 0
@onready var distance:int = 0
var tracking = true

# multiply base speed
const DASH_MULTIPLIER := 5.0
# how long the burst lasts
const DASH_DURATION := 0.25
# lockout before next dash
const DASH_COOLDOWN := 2.0
#  how fast the second tap must come in
const DOUBLE_TAP_WINDOW := 0.3
const FIRE_HEAT_PER_SHOT := 25.0
const FIRE_HEAT_MAX := 100.0
const FIRE_HEAT_RECOVERY_RATE := 10.0
const FIRE_LOCKOUT_DURATION := 3.0

var _dash_active := false
var _dash_dir := 0
var _dash_timer := 0.0
var _cooldown_timer := 0.0
var _last_tap_time := {"fly-left": -1.0, "fly-right": -1.0}
var _fire_heat := 0.0
var _fire_lockout_timer := 0.0

func fall_damage():
	if IS_DEAD or is_invincible:
		return  # Ignore damage if dead or invincible
	damage_taken += 1
	get_tree().current_scene.get_node("Pausable/Audio/FallDamage").play()
	# Start invincibility period
	remove_heart()  # Only call once
	is_invincible = true
	respawn()
	await start_invincibility_visual()  # Wait for visual to complete
	
	if HEARTS <= 0:
		die()
	else:
		# End invincibility after duration
		is_invincible = false

func remove_heart():
	if HEARTS <= 0 or is_invincible:
		return
	HEARTS -= 1
	var heart_to_hide = hearts_container.get_child(HEARTS)
	var c = heart_to_hide.modulate
	heart_to_hide.modulate = Color(c.r, c.g, c.b, 0.0)
	
func add_heart():
	if IS_DEAD or MAX_HEARTS == HEARTS:
		return
	# Get the heart that was previously hidden
	var heart_to_show = hearts_container.get_child(HEARTS)
	heart_to_show.visible = true  # Ensure it's visible
	var c = heart_to_show.modulate
	heart_to_show.modulate = Color(c.r, c.g, c.b, 1.0)
	HEARTS += 1
 
func heal(amount: int): 
	for i in range(amount):
		add_heart()
	print("Healed! Current health: ", HEARTS, "/", MAX_HEARTS)
	
func add_coin(amount: int):
	coins += amount
	coinDisplay.text = str(coins)
	print("Coin added! Current coins: ", coins)
	
func shoot():
	shots_fired += 1
	var bullet = fireball.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = $Muzzle.global_position
	

func _ready() -> void:
	coinDisplay.text = str(feathers)
	add_to_group("player")
	print("Global Position: ", global_position)
	position.x = 300
	position.y = -100
	$BirdHurtBox.body_entered.connect(_on_body_entered)
	sprite.play("fly")
	_setup_dash_bar()
	_track_distance()

func _setup_dash_bar() -> void:
	dash_bar.min_value = 0.0
	dash_bar.max_value = FIRE_HEAT_MAX
	dash_bar.value = 0.0
	var fill = StyleBoxFlat.new()
	fill.bg_color = Color("#ff3303")
	fill.corner_radius_top_left = 6
	fill.corner_radius_top_right = 6
	fill.corner_radius_bottom_left = 6
	fill.corner_radius_bottom_right = 6
	dash_bar.add_theme_stylebox_override("fill", fill)
	var bg = StyleBoxFlat.new()
	bg.bg_color = Color(0.125, 0.102, 0.773, 0.2)
	bg.corner_radius_top_left = 6
	bg.corner_radius_top_right = 6
	bg.corner_radius_bottom_left = 6
	bg.corner_radius_bottom_right = 6
	dash_bar.add_theme_stylebox_override("background", bg)


func _track_distance():
	while tracking:
		if !get_tree().paused:
			await get_tree().create_timer(2).timeout
			distance += 1
			distanceDisplay.text =  str(distance) + " Meters"
		else:
			await get_tree().process_frame

func _on_body_entered(body):
	print("Collision with:", body.name)
	if body.is_in_group("ZeusHand"):
		hide_body()
	if body.is_in_group("hazard"):
		take_damage()
	if body.is_in_group("heal"):
		heal(1)
	if body.is_in_group("coins"):
		add_coin(1)

	
func hide_body():
	print("hide body function")
	is_invincible = true
	GRAVITY = 0 
	sprite.visible = false
	await get_tree().create_timer(3).timeout
	sprite.visible = true
	is_invincible = false
	GRAVITY = 2000
	position.x = 300
	position.y = -2000
		
func add_kill() -> void:
	enemies_killed += 1

func take_damage():
	print("is invincible", is_invincible)
	if IS_DEAD or is_invincible:
		return  # Ignore damage if dead or invincible
	damage_taken += 1
	# Start invincibility period
	remove_heart()
	is_invincible = true
	
	print("Player took damage! Hearts left:", HEARTS)
	sprite.play("shocked")
	
	if HEARTS <= 0:
		die()
	else:
		# Run invincibility visual and timer
		await start_invincibility_visual()
		is_invincible = false

# Visual feedback during invincibility
func start_invincibility_visual():
	# Blink effect - now matches invincibility_duration
	var blink_count = int(invincibility_duration * 5)  # 5 blinks per second
	for i in range(blink_count):
		sprite.modulate.a = 0.5  # Semi-transparent
		await get_tree().create_timer(0.1).timeout
		sprite.modulate.a = 1.0  # Fully visible
		await get_tree().create_timer(0.1).timeout
	
	# Ensure sprite is fully visible at the end
	sprite.modulate.a = 1.0

func die():
	if IS_DEAD:
		return
	IS_DEAD = true
	tracking = false
	velocity = Vector2.ZERO
	print("GAME OVER")
	call_deferred("_disable_gameplay_for_game_over")
	var scene = get_tree().current_scene
	var audio_root = scene.get_node("Pausable/Audio")
	for child in audio_root.get_children():
		if (child is AudioStreamPlayer or child is AudioStreamPlayer2D) and child.name != "Music":
			child.stop()
	var scrollSprite: AnimatedSprite2D = scene.get_node("Pausable/UI/GameOverScroll")
	scene.get_node("Pausable/UI/GameOverScroll").visible = true
	scene.get_node("Pausable/UI/GameOver").visible = true
	scene.get_node("Control/Paper").play()
	await get_tree().create_timer(0.5).timeout
	scrollSprite.play()
	await get_tree().create_timer(1).timeout
	scene.get_node("Control/ZeusGameOver").play()
	scene.get_node("Pausable/Bird").visible = false
	await get_tree().create_timer(0.5).timeout
	_show_game_over_stats()

func _show_game_over_stats() -> void:
	var ui: CanvasLayer = get_tree().current_scene.get_node("Pausable/UI")
	var vp_center: Vector2 = get_viewport_rect().size / 2.0
	var color = Color8(33, 27, 197)

	var container = VBoxContainer.new()
	container.position = vp_center + Vector2(-480, -300)
	container.custom_minimum_size = Vector2(520, 340)
	container.alignment = BoxContainer.ALIGNMENT_CENTER

	var stats = [
		["Shots Fired", shots_fired],
		["Enemies Killed", enemies_killed],
		["Accuracy", int((enemies_killed / float(shots_fired)) * 100) if shots_fired > 0 else 0],
		["Damage Taken", damage_taken],
		["Score", coins],
		["Miles Traveled", distance],
	]
	var intro := Label.new()
	intro.text = "GAME OVER"
	intro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intro.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	intro.add_theme_font_override("font", GREEK_FREAK_FONT)
	intro.add_theme_font_size_override("font_size", 125)
	intro.add_theme_color_override("font_color", color)
	container.add_child(intro)
	
	for stat in stats:
		var label := Label.new()
		label.text = "%s ................ %d" % [stat[0], stat[1]]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_override("font", GREEK_FREAK_FONT)
		label.add_theme_font_size_override("font_size", 72)
		label.add_theme_color_override("font_color", color)
		container.add_child(label) 

	ui.add_child(container)

func _disable_gameplay_for_game_over() -> void:
	var scene = get_tree().current_scene
	scene.get_node("Pausable/Bird").process_mode = Node.PROCESS_MODE_DISABLED
	scene.get_node("Pausable/Enemies").process_mode = Node.PROCESS_MODE_DISABLED
	scene.get_node("Pausable/Enemies2").process_mode = Node.PROCESS_MODE_DISABLED
	scene.get_node("Pausable/CloudEnemies").process_mode = Node.PROCESS_MODE_DISABLED
		
func respawn() -> void:
	position.x = -100
	position.y = -1350

func _on_area_2d_body_entered(body):
	_on_body_entered(body)

func _physics_process(delta: float) -> void:
	if IS_DEAD:
		return
	# Add the gravity.
	velocity.y += GRAVITY * delta
	velocity.y = clamp(velocity.y, FLAP_STRENGTH, GRAVITY)
	velocity.x = 0
	position.y = clamp(position.y, TOP_Y, BOTTOM_Y)
	position.x = clamp(position.x, -250, 2500)
	
	if(position.y > 1000):
		fall_damage()

	_update_dash(delta)
	dash_bar.value = _fire_heat
	
	if Input.is_action_just_pressed("Fire"):
		_try_fire()
	
	if Input.is_action_just_pressed("fly"):
		velocity.y = FLAP_STRENGTH
		sprite.play("fly")

	var move_x := _get_horizontal_velocity()
	if move_x != 0.0:
		velocity.x = move_x
		sprite.play("fly")

	move_and_slide()

func _update_dash(delta: float) -> void:
	if _dash_timer > 0.0:
		_dash_timer -= delta
		if _dash_timer <= 0.0:
			_dash_active = false
			GRAVITY = 2000
	if _cooldown_timer > 0.0:
		_cooldown_timer -= delta
	if _fire_lockout_timer > 0.0:
		_fire_lockout_timer = max(_fire_lockout_timer - delta, 0.0)
		_fire_heat = (_fire_lockout_timer / FIRE_LOCKOUT_DURATION) * FIRE_HEAT_MAX
	elif _fire_heat > 0.0:
		_fire_heat = max(_fire_heat - FIRE_HEAT_RECOVERY_RATE * delta, 0.0)

	var now := Time.get_ticks_msec() / 1000.0
	for action in ["fly-right", "fly-left"]:
		if Input.is_action_just_pressed(action):
			var dir := 1 if action == "fly-right" else -1
			if now - _last_tap_time[action] <= DOUBLE_TAP_WINDOW and _cooldown_timer <= 0.0:
				_dash_active = true
				_dash_dir = dir
				_dash_timer = DASH_DURATION
				_cooldown_timer = DASH_COOLDOWN
			_last_tap_time[action] = now

func _try_fire() -> void:
	if _fire_lockout_timer > 0.0:
		_show_fire_limit_feedback()
		return

	# sprite.play("shoot")
	sprite.animation_finished
	shoot()
	# sprite.play("fly")
	_fire_heat = min(_fire_heat + FIRE_HEAT_PER_SHOT, FIRE_HEAT_MAX)

	if _fire_heat >= FIRE_HEAT_MAX:
		sprite.play("overheat")
		_trigger_fire_lockout()
		_show_fire_limit_feedback()

func _trigger_fire_lockout() -> void:
	_fire_heat = FIRE_HEAT_MAX
	_fire_lockout_timer = FIRE_LOCKOUT_DURATION

func _show_fire_limit_feedback() -> void:
	print("cant fire anymore")
	# TODO: Show the fire-limit warning sprite here once the art is ready.

func _get_horizontal_velocity() -> float:
	if _dash_active:
		GRAVITY = 0
		return FLAP_STRENGTH_X * DASH_MULTIPLIER * _dash_dir
	if Input.is_action_pressed("fly-right"):
		return FLAP_STRENGTH_X
	if Input.is_action_pressed("fly-left"):
		return -FLAP_STRENGTH_X
	return 0.0
