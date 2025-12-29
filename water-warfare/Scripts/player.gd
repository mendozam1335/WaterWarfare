extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var rig_pivot: Node3D = $RigPivot


func _physics_process(delta: float) -> void:
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
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()


func getMoveDirection() -> Vector3:
	var input_dir:= Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	#var input_vector:= Vector3(input_dir.x, 0, input_dir.y).normalized()
	return (transform.basis * Vector3(input_dir.x , 0, input_dir.y)).normalized()
