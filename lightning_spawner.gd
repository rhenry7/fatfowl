extends Area2D

const LIGHTNING_SCENE = preload("res://lightning_bolt.tscn")

@export var step_size := 500.0
@export var reset_threshold_x := -2000.0
@export var fade_in_duration := 2.0
@export var active_duration := 0.5
@export var fade_out_duration := 1.0
@export var post_delay := 0.5

var _initial_spawn_position := Vector2.ZERO
var _next_spawn_x := 0.0
var _spawn_generation := 0
var _is_active := false
var _spawned_bolts: Array[Node] = []

func _ready() -> void:
	_initial_spawn_position = position
	_next_spawn_x = _initial_spawn_position.x
	_disable_placeholder()
	process_mode = Node.PROCESS_MODE_DISABLED

func activate() -> void:
	if _is_active:
		return

	_is_active = true
	process_mode = Node.PROCESS_MODE_INHERIT
	_spawn_generation += 1
	call_deferred("_run_spawn_loop", _spawn_generation)

func deactivate() -> void:
	_is_active = false
	_spawn_generation += 1
	_clear_spawned_bolts()
	_disable_placeholder()
	process_mode = Node.PROCESS_MODE_DISABLED

func _run_spawn_loop(generation: int) -> void:
	while _is_active and generation == _spawn_generation:
		if get_tree().paused:
			await get_tree().process_frame
			continue

		_spawn_bolt()
		await get_tree().create_timer(_cycle_duration(), false).timeout

func _spawn_bolt() -> void:
	var bolt = LIGHTNING_SCENE.instantiate()
	get_parent().add_child(bolt)
	bolt.position = Vector2(_next_spawn_x, _initial_spawn_position.y)

	if bolt.has_method("configure"):
		bolt.configure({
			"fade_in_duration": fade_in_duration,
			"active_duration": active_duration,
			"fade_out_duration": fade_out_duration,
			"post_delay": post_delay,
		})

	_spawned_bolts.append(bolt)
	bolt.tree_exited.connect(_on_bolt_removed.bind(bolt))
	_advance_spawn_x()

func _advance_spawn_x() -> void:
	_next_spawn_x -= step_size
	if _next_spawn_x < reset_threshold_x:
		_next_spawn_x = _initial_spawn_position.x

func _cycle_duration() -> float:
	return fade_in_duration + active_duration + fade_out_duration + post_delay

func _clear_spawned_bolts() -> void:
	for bolt in _spawned_bolts:
		if is_instance_valid(bolt):
			bolt.queue_free()
	_spawned_bolts.clear()

func _on_bolt_removed(bolt: Node) -> void:
	_spawned_bolts.erase(bolt)

func _disable_placeholder() -> void:
	visible = false
	monitoring = false
	monitorable = false
	set_process(false)
	set_physics_process(false)
	for child in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", true)
		elif child is CanvasItem:
			child.visible = false
