extends Node3D

@onready var edge_spring_arm: SpringArm3D = $EdgeSpringArm
@onready var rear_spring_arm: SpringArm3D = $EdgeSpringArm/RearSpringArm
@onready var camera: Camera3D = $EdgeSpringArm/RearSpringArm/Camera


@export var mouse_sensitivity: float = 0.0025
@export var min_boundary: float = deg_to_rad(-60)
@export var max_boundary: float = deg_to_rad(60)

var camera_rotation: Vector2 = Vector2.ZERO
var camera_alignment_speed: float = 0.2
var aim_speed: float = 0.2

@export var aim_distance: float = 0.5
@export var aim_shoulder_offset: float = 0.5
@export var aim_fov: float = 55

@export var default_rear_distance := 1.5
@export var default_shoulder_offset := 1.0
@export var default_fov: float = 75

@export var target : Node3D
@export var player: CharacterBody3D

var camera_tween: Tween
var shoulder_sign: float = 1.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	edge_spring_arm.spring_length = default_shoulder_offset

#func _physics_process(delta: float) -> void:
	#global_transform = global_transform.interpolate_with(
		#target.global_transform, 
		#1.0 - exp(-follow_speed * delta)
		#)
	#_handle_aim(delta)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		#else:
			#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			var mouse_event: Vector2 = event.screen_relative * mouse_sensitivity
			camera_look(mouse_event)
			
	if event.is_action_pressed("camera_switch"):
		shoulder_sign *= -1.0
		swap_camera_alignment()
	
	if event.is_action_pressed("aim"):
		enter_aim()
		
	if event.is_action_released("aim"):
		exit_aim()
	
#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("camera_switch"):
		#shoulder *= -1.0
		#_apply_shoulder()

func camera_look(mouse_movement: Vector2) -> void:
	camera_rotation += mouse_movement
	
	transform.basis = Basis()
	player.transform.basis = Basis()
	
	camera_rotation.y = clampf(
		camera_rotation.y,
		min_boundary,
		max_boundary
	)
	
	player.rotate_object_local(Vector3(0,1,0), -camera_rotation.x)
	rotate_object_local(Vector3(1,0,0), -camera_rotation.y)

#func _handle_aim(delta: float) -> void:
	#var target_dist := aim_distance if is_aiming else desired_distance
	#smooth_camera.spring_length = lerp(smooth_camera.spring_length, target_dist, 1.0 - exp(-10.0 *delta))
#
#func _apply_shoulder() -> void:
	#smooth_camera.position.x = default_shoulder_offset * shoulder

func swap_camera_alignment() -> void:
	set_rear_spring_arm_position(default_shoulder_offset * shoulder_sign, camera_alignment_speed)
	
func set_rear_spring_arm_position(pos: float, speed: float) -> void:
	if camera_tween:
		camera_tween.kill() 
	camera_tween = get_tree().create_tween()
	camera_tween.tween_property(edge_spring_arm, "spring_length", pos, speed)
	
func enter_aim() ->void:
	if camera_tween:
		camera_tween.kill()
	camera_tween = get_tree().create_tween()
	camera_tween.set_parallel()
	
	camera_tween.tween_property(camera, "fov", aim_fov, aim_speed)
	camera_tween.tween_property(edge_spring_arm, "spring_length", aim_shoulder_offset * shoulder_sign, aim_speed)
	camera_tween.tween_property(rear_spring_arm, "spring_length", aim_distance, aim_speed)

func exit_aim() -> void:
	if camera_tween:
		camera_tween.kill()
	camera_tween = get_tree().create_tween()
	camera_tween.set_parallel()
	
	camera_tween.tween_property(camera, "fov", default_fov, aim_speed)
	camera_tween.tween_property(edge_spring_arm, "spring_length", default_shoulder_offset * shoulder_sign, aim_speed)
	camera_tween.tween_property(rear_spring_arm, "spring_length", default_rear_distance, aim_speed)
