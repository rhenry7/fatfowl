extends RichTextLabel


var distance := 0

func _ready() -> void:
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1.0
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout() -> void:
	distance += 1
	var distanceText = get_tree().current_scene.get_node("Pausable/UI/Distance")
	distanceText.text = str(distance) + "M"
