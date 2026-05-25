extends Node

const ZEUS_BOSS_HEAD_SCENE = preload("res://zeus_boss.tscn")
const ATTACKS = ["eyebeam", "spitball", "barfbeam"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var enemy = ZEUS_BOSS_HEAD_SCENE.instantiate()
	add_child(enemy)

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
