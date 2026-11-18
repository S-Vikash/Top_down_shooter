extends Control

@onready var crosshair: Sprite2D = $Crosshair

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func scale_crosshair(scale : float)->void:
	crosshair.scale = Vector2.ONE * scale * 0.2
	
func _process(delta: float) -> void:
	update_cross_hair(delta)

func _unhandled_input(_event: InputEvent) -> void:
	if(Input.is_action_just_pressed("Pause")):
		if(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func update_cross_hair(_delta: float) -> void:
	crosshair.position += InpMgr.get_look_input() * 500.0
	
	var ssize = get_viewport().get_visible_rect().size
	crosshair.position.x = clamp(crosshair.position.x, -ssize.x/2, ssize.x/2)
	crosshair.position.y = clamp(crosshair.position.y, -ssize.y/2, ssize.y/2)
	
