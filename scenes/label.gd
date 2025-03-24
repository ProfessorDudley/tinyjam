extends Label

@export var player: RigidBody3D

func _process(delta: float) -> void:
	text = str(clamp(player.score, 0, 100000000000))
