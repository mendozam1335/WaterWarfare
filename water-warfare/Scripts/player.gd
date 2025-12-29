extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var _look := Vector2.ZERO
var mouse_moved: bool = false

@export var mouse_sensitivity: float = 0.00075
@export var decay: float = 20.0
@export var min_boundary: float = -60
@export var max_boundary: float = 10

@onready var horizontal_pivot: Node3D = $HorizontalPivot
@onready var vertical_pivot: Node3D = $HorizontalPivot/VerticalPivot
@onready var camera_rig: Node3D = $CameraRig
@onready var rig_pivot: Node3D = $RigPivot


#func _ready() -> void:
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	#frame_camera_rotation()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := getMoveDirection()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		#look_toward_direction(direction, delta)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	#if mouse_moved:
	#	look_toward_direction(direction,delta)
	#	mouse_moved = false
	move_and_slide()

#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_cancel"):
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	#todo: toggle camera movement for shoulder placment left or right
	#if event.is_action_pressed("aim"):
		#print("currently aiming")
		##camera_rig.is_aiming = true
		#
	#if event.is_action_released("aim"):
		#print("no longer aiming")
		#camera_rig.is_aiming = false
		
	#if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		#if event is InputEventMouseMotion:
			#_look += -event.relative * mouse_sensitivity
			#mouse_moved = true
			

func getMoveDirection() -> Vector3:
	var input_dir:= Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	#var input_vector:= Vector3(input_dir.x, 0, input_dir.y).normalized()
	return (transform.basis * Vector3(input_dir.x , 0, input_dir.y)).normalized()

#rotates the pivots but not the actual camera. Camera is set to pivot point in Smooth_camera script. 
func frame_camera_rotation() -> void:
	horizontal_pivot.rotate_y(_look.x)
	vertical_pivot.rotate_x(_look.y)
	
	#Make sure camera cannot go over head or underskirt
	vertical_pivot.rotation.x = clampf(
		vertical_pivot.rotation.x,
		deg_to_rad(min_boundary),
		deg_to_rad(max_boundary)
	)
	
	_look = Vector2.ZERO
	
func look_toward_direction(direction: Vector3, delta: float) -> void:
	var target_transform := rig_pivot.global_transform.looking_at(
		rig_pivot.global_position + direction, 
		Vector3.UP,
		true
	)
	
	rig_pivot.global_transform = rig_pivot.global_transform.interpolate_with(
		target_transform,
		1.0 - exp(-decay * delta)
	)
