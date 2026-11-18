extends Node3D

@export var player_mesh: Node3D
@onready var player: CharacterBody3D = $"../.."

@export var fire_rate: float = 1.0 / 10
@onready var muzzle: Node3D = $Gun/Muzzle
@export var min_range: float = 3

@export var aim_speed: float = 15
@onready var ui: Control = $"../../../UI"

var target_point: Vector3
var can_shoot: bool = true

var bullet_scene: Resource = load("res://Scenes/bullet.tscn")


func _process(delta: float) -> void:
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot(delta)
		ui.scale_crosshair(1.3)


func shoot(delta: float) -> void:
	target_point = get_target_point(delta)

	if target_point == Vector3.ZERO:
		return

	rotate_gun(delta)
	shoot_raycast()
	spawn_bullet()

	start_fire_cooldown()


func get_target_point(delta: float) -> Vector3:
	var hit: Dictionary = player.look_at_mouse_pos(delta)

	if hit and player.global_position.distance_to(hit.position) <= min_range:
		return Vector3.ZERO  # Target too close, don't shoot

	if hit and player.global_position.distance_to(hit.position) > min_range:
		return hit.position

	return player_mesh.global_position - player_mesh.global_basis.z * 10.0
	#If ray does not hit anything, return pos of 10uts fwd wrt player

func rotate_gun(delta: float) -> void:
	var target_transform := global_transform.looking_at(
		target_point,
		Vector3.UP
	)

	global_basis = global_basis.slerp(
		target_transform.basis,
		aim_speed * delta
	)


func shoot_raycast() -> void:
	var query := PhysicsRayQueryParameters3D.create(
		player.global_position,
		target_point
	)

	var _result: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)


func spawn_bullet() -> void:
	var shoot_direction: Vector3 = (
		target_point - muzzle.global_position
	).normalized()

	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)

	bullet.trajectory(
		muzzle.global_position,
		shoot_direction
	)
	bullet.global_rotation = muzzle.global_rotation


func start_fire_cooldown() -> void:
	can_shoot = false
	await get_tree().create_timer(fire_rate).timeout
	ui.scale_crosshair(1.0)
	can_shoot = true
