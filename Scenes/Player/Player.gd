extends KinematicBody

class_name Player

onready var head = get_node("Head")
onready var groundRay = get_node("GroundRay")

enum STATE {
	DEFAULT,
	INTERACT_MENU
}

var state = STATE.DEFAULT setget setState

var speed = 6
var acc = 1
var dec = 3
var jumpForce = 16
var fallAcceleration = 75

var mouseSpeed = .13
var headVerticalClamp = [-90, 90]

var inputVector = Vector3()
var velocity = Vector3()
var onFloor = false
var canJump = false

var pickableGrabbed: Pickable = null
var grabbedOffset = Vector3()

export(NodePath) onready var interactRay = get_node(interactRay)
export(NodePath) onready var interactLabel = get_node(interactLabel)
export(NodePath) onready var grabPoint = get_node(grabPoint)

export(NodePath) onready var velLabel = get_node(velLabel)

func setState(value):
	state = value
	
	match state:
		STATE.DEFAULT:
			interactLabel.text = ""
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		STATE.INTERACT_MENU:
			interactLabel.text = ""
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	match state:
		STATE.DEFAULT:
			getMouseInput(event)
				
func _physics_process(delta):
	match state:
		STATE.DEFAULT:
			stateDefault(delta)
			
	#velLabel.text = str(groundRay.get_collision_normal())
	velLabel.text = str(Vector2(velocity.x, velocity.z).length())
	
func getMouseInput(event):
	if event is InputEventMouseMotion:
		# rotate
		# if mouse mode not captured, return
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			return
		rotate_y(- deg2rad(event.relative.x) * mouseSpeed)
		head.rotate_z(- deg2rad(event.relative.y) * mouseSpeed)
		
		#clamp it
		head.rotation_degrees.z = clamp(head.rotation_degrees.z, headVerticalClamp[0], headVerticalClamp[1])
	
	if event is InputEventKey:
		if Input.is_action_just_pressed("escape"):
			if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func getInput():
	inputVector = Vector3()
	if Input.is_action_pressed("left"):
		inputVector.x -= 1
	if Input.is_action_pressed("right"):
		inputVector.x += 1
	if Input.is_action_pressed("up"):
		inputVector.z -= 1
	if Input.is_action_pressed("down"):
		inputVector.z += 1
	inputVector = inputVector.normalized()
	
func resetInput():
	inputVector = Vector3()
	
func move(delta):
	# this is retarded, only works when the player is direct child of the world
	inputVector = inputVector.rotated(Vector3.UP, rotation.y - deg2rad(90))
	var wanted_velocity_xy = Vector2()
	
	# acceleration
	wanted_velocity_xy.x = inputVector.x * speed
	wanted_velocity_xy.y = inputVector.z * speed
	var velocity_xy = Vector2(velocity.x, velocity.z)
	if inputVector != Vector3():
		velocity_xy = velocity_xy.move_toward(wanted_velocity_xy, acc)
	else:
		velocity_xy = velocity_xy.move_toward(wanted_velocity_xy, dec)
	velocity.x = velocity_xy.x
	velocity.z = velocity_xy.y
		
	var jump_this_frame = false
	onFloor = is_on_floor()
	if onFloor and Input.is_action_pressed("jump"):
		velocity.y = jumpForce
		jump_this_frame = true

	# apply gravity
	var current_grav = Vector3(0, fallAcceleration, 0) * delta
	if onFloor:
		current_grav = groundRay.get_collision_normal() * fallAcceleration * delta	
	velocity -= current_grav
	
	#velocity = move_and_slide(velocity, Vector3.UP)
	var snap_vector = Vector3.DOWN
	if onFloor:
		snap_vector = -groundRay.get_collision_normal()
	if jump_this_frame:
		snap_vector = Vector3()
	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, true, 4, .78, false)

func updateInteractRay():
	if pickableGrabbed:
		if !Input.is_action_pressed("interact"):
			pickableGrabbed = null
			grabbedOffset = Vector3()
			return
		var impulse_pos = pickableGrabbed.global_transform.origin + grabbedOffset
		
		var direction_vector:Vector3 = grabPoint.global_transform.origin - impulse_pos
		if direction_vector.length_squared() >= 2.25:
			direction_vector = direction_vector.normalized() * 1.5
		if direction_vector.length_squared() >= .01:
			pickableGrabbed.add_central_force(direction_vector * direction_vector.length_squared() * 500)
		return
		
	var interactable = interactRay.get_collider()
	if interactable == null:
		interactLabel.text = ""
		return
		
	if interactable is Interactable:
		if interactable.locked:
			interactLabel.text = "locked"
			return
		interactLabel.text = interactable.interactTooltip
		if Input.is_action_just_pressed("interact"):
			interactable.interact()
			
	elif interactable is Pickable:
		interactLabel.text = "grab"
		
		if Input.is_action_just_pressed("interact"):
			pickableGrabbed = interactable
			# set grabPosition new offset so the original position of the pickable is the grab point
			grabPoint.translation.x = max((pickableGrabbed.global_transform.origin - head.global_transform.origin).length(), 1.5)
			grabbedOffset = interactRay.get_collision_point() - pickableGrabbed.global_transform.origin
			interactLabel.text = ""
	
func stateDefault(delta):
	getInput()
	move(delta)
	updateInteractRay()
