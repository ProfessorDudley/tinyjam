extends RigidBody3D

@export var _input: VirtualJoystick
@export var _camera: Camera3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	apply_torque(Vector3(-_input._output_vector.y, 0, _input._output_vector.x) * Vector3(2.4, 0, 1.4) * 8)
	_camera.global_position.x = self.global_position.x / 2.4
	_camera.global_position.z = self.global_position.z - 6
