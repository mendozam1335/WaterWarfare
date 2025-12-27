extends SpringArm3D
class_name Smooth_Camera

@export var target: Node3D
@export var decay: float = 20.0

@onready var main_camera: Camera3D = $MainCamera
@onready var aim_camera: Camera3D = $AimCamera


func _ready():
	print(main_camera, aim_camera)


func _physics_process(delta: float) -> void:
	global_transform = global_transform.interpolate_with(
		target.global_transform,
		1.0- exp(-decay*delta)
	)

func set_Camera(camera: String) -> void:
	
	print(aim_camera)
	print(main_camera)
	
	if camera == "aim":
		#main_camera.clear_current()
		aim_camera.make_current()
	else:
		#aim_camera.clear_current()
		main_camera.make_current()

func enter_aim_mode():
	aim_camera.make_current()
	
func enter_third_person_mode():
	main_camera.make_current()
	
