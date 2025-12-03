extends Node2D

@export var speed := 150.0
@export var right_spawn_x := 1200.0
@export var top_y := 50.0
@export var bottom_y := 150.0

func _ready() -> void:
	$VisibilityNotifier2D.screen_exited.connect(_on_screen_exited)
	# Optional: connect area_entered to handle hits (but don't respawn there)
	# $Area2D.area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	position.x -= speed * delta

func _on_screen_exited() -> void:
	respawn()

func respawn() -> void:
	var random_y := randf_range(top_y, bottom_y)
	position = Vector2(right_spawn_x, random_y)
	print("respawned at ", position)
