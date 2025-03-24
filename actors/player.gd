extends RigidBody3D
class_name player

@export var rolling_force = 40
@export var smoothing = 0.1
@export var max_speed = 4
@export var game_start_trigger: Area3D
var isPaused
var score: float
var drift: float = 1.6
var camera_y: float

func _ready():
	$CameraRig.top_level = true
	$Character.top_level = true
	camera_y = $CameraRig.global_position.y

func _process(delta: float) -> void:
	score = game_start_trigger.global_position.z - global_position.z
	score = floor(score * 10)
	
	
func _physics_process(delta: float) -> void:
	var new_camera_position = lerp($CameraRig.global_transform.origin, global_transform.origin, smoothing)
	$CameraRig.global_transform.origin = new_camera_position
	$CameraRig.global_position.y = camera_y
	$Character.global_transform.origin = global_transform.origin - Vector3(0, 0.2, 0)
	
	
	if Input.is_action_pressed("MoveForward"):
		angular_velocity.x -= rolling_force*delta
	if Input.is_action_pressed("MoveBackward"):
		angular_velocity.x += rolling_force*delta
	if Input.is_action_pressed("MoveLeft"):
		angular_velocity.z += ((rolling_force)*delta)/4
	if Input.is_action_pressed("MoveRight"):
		angular_velocity.z -= ((rolling_force)*delta)/4
		
	angular_velocity = angular_velocity.clamp(Vector3(-max_speed, -max_speed, -max_speed), Vector3(max_speed, max_speed, max_speed))
	

func _on_timer_timeout() -> void:
	constant_torque.z = randf_range(-drift, drift)


func _on_game_start_trigger_body_entered(body: Node3D) -> void:
	print("Game Starts")
	$Timer.start()
