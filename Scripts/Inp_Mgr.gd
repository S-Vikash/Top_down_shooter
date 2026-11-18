extends Node

enum Device{
	Keyboard_mouse,
	Gamepad
}

var active_device := Device.Keyboard_mouse

var _look_inp := Vector2.ZERO
var _inp_dir := Vector3.ZERO

var gamepad_sensitivity: float = 3
var mouse_sensitivity: float = 0.003


func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion:
		active_device = Device.Keyboard_mouse
		_look_inp += event.relative * mouse_sensitivity
	
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		active_device = Device.Gamepad
	
	elif event is InputEventKey or InputEventMouseButton:
		active_device = Device.Keyboard_mouse
		
func _process(delta: float) -> void:
	_inp_dir = Vector3(Input.get_axis("left","right"),
					0,
					Input.get_axis("forward","back"))
	
	if active_device == Device.Gamepad:
		var stick_input := Input.get_vector("look_left","look_right","look_up","look_down")
		
		_look_inp = stick_input * gamepad_sensitivity * delta
		
func get_look_input() ->Vector2:
	var input := _look_inp
	_look_inp = Vector2.ZERO
	return input
	
func get_inp_dir()-> Vector3:
	return _inp_dir
	
