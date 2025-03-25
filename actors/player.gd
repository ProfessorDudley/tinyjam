extends RigidBody3D
class_name player

@export var camera: Camera3D

var input_touch: Vector2
@onready var screen_center: Vector2 = get_viewport().size / 2

@onready var camera_initial_position = camera.global_position

func _ready() -> void:
	print(camera_initial_position)


func _input(event: InputEvent) -> void:
	#if (event is InputEventMouse):
		#return
		
	if (event is InputEventScreenDrag):
		input_touch = event.position
		if event.index != 0:
			input_touch = Vector2.ZERO
		
func _physics_process(delta: float) -> void:
	var space_state = get_world_3d().direct_space_state
	
	var mouse_position = get_viewport().get_mouse_position()
	
	var ray_origin = camera.project_ray_origin(input_touch)
	var ray_end = ray_origin + camera.project_ray_normal(input_touch) * 1000
	
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end, 0b0010)
	var intersection = space_state.intersect_ray(query)
	
	if not intersection.is_empty():
		var ray_target = intersection.position
		position = lerp(position, ray_target, delta * 2)
		
		## Camera movement# There is an issue where the game floor moves, so then our reported target location moves, which causes the camera to move relative to the floor, causing the floor to move etc...
		camera.global_position.x = self.global_position.x / 2.4
		camera.global_position.z = self.global_position.z - 6
