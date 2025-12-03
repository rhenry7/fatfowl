# Effects.gd
extends Node

func flash_opacity(node: Node):
	var t = node.get_tree().create_tween()
	t.tween_property(node, "modulate:a", 0.3, 0.1)
	t.tween_property(node, "modulate:a", 1.0, 0.1)
