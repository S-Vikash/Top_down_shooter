extends Camera3D

@export var player: CharacterBody3D
@export var offset := Vector3(5, 8, 3)

@export var position_speed := 5.0
@export var rotation_speed := 8.0


func _physics_process(delta: float) -> void:
	if not player:
		return

	var target_pos := player.global_position + offset

	global_position = global_position.lerp(
		target_pos,
		position_speed * delta
	)

	var target_rotation := global_transform.looking_at(
		player.global_position,
		Vector3.UP
	).basis

	global_basis = global_basis.slerp(
		target_rotation,
		rotation_speed * delta
	)
