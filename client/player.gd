extends Node3D


@export var mouse_sensitivity = 0.1
@export var speed = 50.0

@onready var rig = $CameraRig
@onready var camera = get_node("%Camera3D")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var y_movement = 0.0
	if Input.is_action_pressed("camera.down"):
		y_movement = -1.0
	elif Input.is_action_pressed("camera.up"):
		y_movement = 1.0

	var input_vector = Input.get_vector(
			"camera.left",
			"camera.right",
			"camera.forward",
			"camera.back")

	var camera_basis = camera.transform.basis
	var direction = camera_basis * Vector3(
			input_vector.x,
			y_movement,
			input_vector.y)

	translate(direction * speed * delta)


func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rig.rotate_x(deg2rad(event.relative.y * -mouse_sensitivity))
		rotate_y(deg2rad(event.relative.x * -mouse_sensitivity))

		var camera_rot = rig.rotation
		camera_rot.x = clamp(camera_rot.x, deg2rad(-70), deg2rad(70))
		rig.rotation = camera_rot
