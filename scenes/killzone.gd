extends Area3D

signal player_fell

func _on_body_entered(_body: Node3D) -> void:
	player_fell.emit()
	get_tree().call_deferred("reload_current_scene")
