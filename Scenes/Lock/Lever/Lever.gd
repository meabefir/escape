extends Lock

enum STATE {
	UP,
	DOWN
}

onready var animationPlayer = get_node("AnimationPlayer")

export(STATE) var startState
var state = STATE.UP
export(STATE) var stateNeeded

func _ready():
	interactTooltip = "pull"

	setState(startState)

func setState(_state):
	if _state == STATE.UP and state != STATE.UP:
		animationPlayer.play("up")
	elif _state == STATE.DOWN and state != STATE.DOWN:
		animationPlayer.play("down")
	if animationPlayer.is_playing():
		yield(animationPlayer, "animation_finished")
	
	if state == stateNeeded and _state != stateNeeded:
		interactableLocked.lock(self) 
	state = _state
	
	yield(get_tree().create_timer(.1), "timeout")
	if state == stateNeeded:
		lockUnlocked()
	
func interact(propagate = true):
	.interact(propagate)
	if animationPlayer.is_playing():
		return
	if state == STATE.DOWN:
		setState(STATE.UP)
	else:
		setState(STATE.DOWN)
