class_name VirtualJoystick extends TouchScreenButton

var _pressed: bool
var ORIGIN: Vector2 = self.position
var _input_vector: Vector2 = ORIGIN
var _output_vector: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if _pressed:
		_input_vector = get_global_mouse_position()
	else:
		_input_vector = ORIGIN
	
	_calculate_vector()


func _on_pressed() -> void:
	_pressed = true
	
func _calculate_vector() -> void:
	_output_vector = ((_input_vector - ORIGIN) / shape.get_rect().size) * 2


func _on_released() -> void:
	_pressed = false
