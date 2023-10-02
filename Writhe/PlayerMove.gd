extends CharacterBody3D

const MOUSE_SENS = 0.3
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var camera_anglev = 0

var paused = false

var gun_model

func _init():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# Pausing the game.
	if event.is_action_pressed("ui_cancel"):
		paused = !paused
		if (paused):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event is InputEventMouseMotion and !paused:
		# Rotate camera/player with mouse.
		var changeh = -event.relative.x*MOUSE_SENS
		var changev = -event.relative.y*MOUSE_SENS
		
		rotate_y(deg_to_rad(changeh))
		
		if camera_anglev + changev > -90 and camera_anglev + changev < 90:
			camera_anglev += changev
			$Camera.rotate_x(deg_to_rad(changev))
		
		# Make gun model lean into movement
		if gun_model != null:
			gun_model.rotate_x(deg_to_rad(changev) * 0.5)
			gun_model.rotate_y(deg_to_rad(changeh) * 0.5)

func _process(delta):
	if gun_model != null:
		gun_model.basis = Basis(gun_model.basis.get_rotation_quaternion().slerp(Quaternion.from_euler(Vector3(0, PI, 0)), delta*30)).scaled(gun_model.basis.get_scale())
	else:
		# idk how to initialize this properly since _init apparently
		# isn't guaranteed to run before _process does so we have this check
		# until I can find a better solution
		gun_model = get_node("Camera/Sawed-off-mesh")

func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("strafe_left", "strafe_right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
