extends Lock

onready var timer = get_node("Timer")
onready var animationPlayer = get_node("AnimationPlayer")
onready var buttonMesh = get_node("button mesh")
onready var tween = get_node("Tween")

enum STATE {
	DEFAULT,
	PUSHED
}

var badColor = Color("e73d3d")
var goodColor = Color("52e73d")

var state = STATE.DEFAULT
export(float) var resetTime = 2
export(STATE) var stateNeeded = STATE.DEFAULT

func _init():
	unlockedLayer = 0 + 2
	lockedLayer = 0

func _ready():
	interactTooltip = "push"
	
	timer.wait_time = resetTime
	
	# unlock if state is already needed one
	yield(get_tree().create_timer(.1), "timeout")
	if state == stateNeeded:
		lockUnlocked()

func interact(propagate = true):
	if state == STATE.PUSHED:
		return
	.interact(propagate)
	
	animationPlayer.play("push")
	state = STATE.PUSHED
	interactTooltip = ""
	var mat: Material = buttonMesh.get_surface_material(0)
	tween.stop_all()
	tween.interpolate_property(mat, "albedo_color", mat.albedo_color, goodColor, .2)
	tween.start()
	
	if state == stateNeeded:
		lockUnlocked()
	else:
		lockLocked()

	yield(animationPlayer, "animation_finished")
	timer.start()

func _on_Timer_timeout():
	animationPlayer.play("release")
	yield(animationPlayer, "animation_finished")
	
	state = STATE.DEFAULT
	interactTooltip = "push"
	var mat: Material = buttonMesh.get_surface_material(0)
	tween.stop_all()
	tween.interpolate_property(mat, "albedo_color", mat.albedo_color, badColor, .2)
	tween.start()
	
	if state == stateNeeded:
		lockUnlocked()
	else:
		lockLocked()
