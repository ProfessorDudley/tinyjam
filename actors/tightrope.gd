extends Node3D
class_name tightrope

var active = true
@export var spawn_points: Array[Marker3D] = []
var spawn_clouds: bool =  true
var cloud_delay: float = 3
var previous_spawn: Marker3D
var spawnpoint: Marker3D

func _on_spawn_trigger_body_entered(body: Node3D) -> void:
	if active == true:
		var tightrope = load("res://actors/tightrope.tscn").instantiate()
		tightrope.position = $SpawnAnchor.global_position
		get_parent().add_child(tightrope)
		spawn_clouds = false
		active = false
	else:
		print("Already Spawned")




func _on_timer_timeout() -> void:
	if spawn_clouds:
		spawnpoint = _try_get_spawnpoint()
		previous_spawn = spawnpoint
		print("spawning cloud at: ", spawnpoint.global_position)
		var cloud = load("res://actors/cloud.tscn").instantiate()
		spawnpoint.add_child(cloud)
		cloud.global_position = spawnpoint.global_position
	else:
		print("cant spawn clouds")

func _try_get_spawnpoint() -> Marker3D:
	var newpoint: Marker3D = null
	while newpoint == previous_spawn or newpoint == null:
		newpoint = spawn_points.pick_random()
	print("found spawnpoint: ", newpoint)
	return newpoint
