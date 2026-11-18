extends Node3D

@export var life_time: float = 0.5
@export var speed: float = 20.0

var direction: Vector3

func trajectory(start: Vector3, dir: Vector3) -> void:
	global_position = start
	direction = dir
	start_timer()

func _process(delta: float) -> void:
	global_position += direction * speed * delta

func start_timer() -> void:
	await get_tree().create_timer(life_time).timeout
	queue_free()
