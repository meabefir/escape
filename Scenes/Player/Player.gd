extends KinematicBody

class_name Player

onready var torso = get_node("Torso")
onready var head = get_node("Torso/Head")
onready var camera = get_node("Torso/Head/Camera")

onready var interactRay = get_node("Torso/Head/InteractRay")
onready var interactLabel = get_node("CanvasLayer/InteractLabel")

onready var grabPoint = get_node("Torso/Head/GrabPoint")
onready var pinJoint = get_node("Torso/Head/GrabPoint/PinJoint")

onready var settings = get_node("CanvasLayer/Settings")

#export(NodePath) onready var interactRay = get_node(interactRay)
#export(NodePath) onready var interactLabel = get_node(interactLabel)
#export(NodePath) onready var camera = get_node(camera)

#export(NodePath) onready var grabPoint = get_node(grabPoint)
#export(NodePath) onready var pinJoint = get_node(pinJoint)

enum STATE {
	DEFAULT,
	INTERACT_MENU,
	PAUSED
}

var state = STATE.DEFAULT setget setState

var speed = 6
var acc = 1
var dec = 3
var jumpForce = 16
var fallAcceleration = 75

var cam_accel = 40
var mouseSpeed = .13
var headVerticalClamp = [-90, 90]

var inputVector = Vector3()
var velocity = Vector3()
var onFloor = false
var canJump = false

var pickableGrabbed: Pickable = null
var grabbedOffset = Vector3()

# testing
export(NodePath) onready var velLabel = get_node(velLabel)
export(NodePath) onready var normalLabel = get_node(normalLabel)

func setState(value):
	match state:
		STATE.PAUSED:
			settings.hide()
	
	state = value
		
	match state:
		STATE.DEFAULT:
			interactLabel.text = ""
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		STATE.INTERACT_MENU:
			interactLabel.text = ""
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			resetInput()
		STATE.PAUSED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			settings.show()
			resetInput()
		
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	settings.hide()

func _input(event):
	if Input.is_action_just_pressed("test"):
		if pickableGrabbed:
			pickableGrabbed.queue_free()
	match state:
		STATE.DEFAULT:
			stateDefaultInput(event)
		STATE.PAUSED:
			statePausedInput(event)
			
func _physics_process(delta):
	match state:
		STATE.DEFAULT:
			stateDefault(delta)
		STATE.INTERACT_MENU:
			move(delta)
		STATE.PAUSED:
			move(delta)
			
	velLabel.text = str(state)
	normalLabel.text = str(get_floor_normal())
	
func stateDefaultInput(event):
	if event is InputEventMouseMotion:
		# rotate
		# if mouse mode not captured, return
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			return
		torso.rotate_y(- deg2rad(event.relative.x) * mouseSpeed)
		head.rotate_z(- deg2rad(event.relative.y) * mouseSpeed)
		
		#clamp it
		head.rotation_degrees.z = clamp(head.rotation_degrees.z, headVerticalClamp[0], headVerticalClamp[1])
	
	if event is InputEventKey:
		if Input.is_action_just_pressed("escape"):
			self.state = STATE.PAUSED
	
func statePausedInput(event):
	if event is InputEventKey:
		if Input.is_action_just_pressed("escape"):
			self.state = STATE.DEFAULT
	
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
	inputVector = inputVector.rotated(Vector3.UP, torso.rotation.y - deg2rad(90))
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
		current_grav = get_floor_normal() * fallAcceleration * delta	
	velocity -= current_grav
	
	#velocity = move_and_slide(velocity, Vector3.UP)
	var snap_vector = Vector3.DOWN
	if onFloor:
		snap_vector = -get_floor_normal()
	if jump_this_frame:
		snap_vector = Vector3()
	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, true, 4, .78, false)
	
#	for i in get_slide_count():
#		var collider = get_slide_collision(i).collider
#		if !collider is Pickable:
#			continue
#		var vec_to_collider = (collider.global_transform.origin - global_transform.origin).normalized()
#		collider.apply_central_impulse(vec_to_collider * 55)
	
func updateInteractRay():
	var interactable = interactRay.get_collider()
	if pickableGrabbed:
		if !Input.is_action_pressed("interact"):
			resetGrabbed()
		return
		
	if interactable is Interactable:
		if interactable.locked:
			interactLabel.text = interactable.lockedMessage
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
			pinJoint.set_node_b(pinJoint.get_path_to(pickableGrabbed))
			var mass_ratio = 1
			pinJoint.set_param(PinJoint.PARAM_IMPULSE_CLAMP, pickableGrabbed.mass * mass_ratio)
			interactLabel.text = ""
	else:
		interactLabel.text = ""
		return
	
func resetGrabbed():
	pickableGrabbed = null
	pinJoint.set_node_b("")
	
func stateDefault(delta):
	getInput()
	move(delta)
	updateInteractRay()
