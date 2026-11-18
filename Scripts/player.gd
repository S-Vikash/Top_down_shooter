extends CharacterBody3D

@export var walk_speed: float = 4
@export var run_speed: float = 8
@export var turn_speed: float = 10
@export var gravity: float = -20.0
@export var jump_height:float = 3

var jump_vel:float = sqrt(-2 * gravity * jump_height)

@export var camera: Camera3D
@export var player_body: Node3D

@onready var ui: Control = $"../UI"

@export var auto_shoot_mode: bool = false
var auto_shoot:bool
var enemies: Array[Node3D] = []


func _physics_process(delta: float) -> void:
	move(delta)
	jump(delta)
	move_and_slide()

	if auto_shoot and auto_shoot_mode:
		update_auto_fire(delta)
	else:
		look_at_mouse_pos(delta)

	if(enemies.size()>0):
		auto_shoot = true
	else:
		auto_shoot = false

func move(delta: float) -> void:
	var input_dir := InpMgr.get_inp_dir()

	var move_dir := get_move_direction(input_dir)
	var move_speed := get_move_speed()

	velocity.x = move_dir.x * move_speed
	velocity.z = move_dir.z * move_speed


func jump(delta:float)->void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if(Input.is_action_just_pressed("jump")):
			velocity.y = jump_vel

func get_move_direction(input_dir: Vector3) -> Vector3:
	var move_dir: Vector3 = player_body.basis * input_dir
	move_dir.y = 0.0
	return move_dir.limit_length(1.0)   # keeps analog magnitude, still caps diagonals


func get_move_speed() -> float:
	if Input.is_action_pressed("Run"):
		return run_speed

	return walk_speed


# Auto mode: hold the "shoot" action while an enemy is in range, so the
# existing gun script fires on its own. Release it when nothing is in range.
func update_auto_fire(delta: float) -> void:
	var hit := look_at_nearby_enemy(delta)

	if hit.is_empty():
		Input.action_release("shoot")
	else:
		Input.action_press("shoot")


# The gun script calls this to get its aim point. In auto mode it returns the
# nearest enemy's position instead of the crosshair hit, in the same
# {"position": Vector3} format, so the gun script needs no changes.
func look_at_mouse_pos(delta: float) -> Dictionary:
	if auto_shoot and auto_shoot_mode:
		return look_at_nearby_enemy(delta)

	if not camera:
		return {}

	var mouse_pos: Vector2 = ui.get_node("Crosshair").global_position

	var ray_origin: Vector3 = camera.project_ray_origin(mouse_pos)
	var ray_direction: Vector3 = camera.project_ray_normal(mouse_pos)
	var ray_end: Vector3 = ray_origin + ray_direction * 1000.0

	var hit := raycast_from_camera(ray_origin, ray_end)

	if hit:
		rotate_towards_position(hit.position, delta)

	return hit


func look_at_nearby_enemy(delta: float) -> Dictionary:
	var enemy := get_nearest_enemy()
	if not enemy:
		return {}

	
	rotate_towards_position(enemy.global_position, delta)
	return {"position": enemy.global_position}


func get_nearest_enemy() -> Node3D:
	var nearest: Node3D = null
	var nearest_dist := INF

	for e in enemies:
		var d := e.global_position.distance_squared_to(global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = e

	return nearest


func raycast_from_camera(
	ray_origin: Vector3,
	ray_end: Vector3
) -> Dictionary:

	var query := PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_end
	)

	query.exclude = [get_rid()]

	return get_world_3d().direct_space_state.intersect_ray(query)


func rotate_towards_position(
	target_position: Vector3,
	delta: float
) -> void:

	# Keep rotation horizontal
	target_position.y = global_position.y

	var direction := target_position - global_position

	if direction.length_squared() <= 0.01:
		return

	var target_basis := Basis.looking_at(
		direction,
		Vector3.UP
	)

	player_body.global_basis = player_body.global_basis.slerp(
		target_basis,
		turn_speed * delta
	)


func _on_enemy_detection_zone_body_entered(body: Node3D) -> void:
	if(body.get_parent().is_in_group("Enemy")):
		enemies.append(body)


func _on_enemy_detection_zone_body_exited(body: Node3D) -> void:
	if(body.get_parent().is_in_group("Enemy")):
		enemies.erase(body)
