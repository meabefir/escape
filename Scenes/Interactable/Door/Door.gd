extends Interactable

onready var animationPlayer = get_node("AnimationPlayer")

var closed = true

func _ready():
	interactTooltip = "open" if closed else "close"
	
func interact():
	if closed:
		animationPlayer.play("open")
		closed = false
		interactTooltip = "close"
	else:
		animationPlayer.play_backwards("open")
		closed = true
		interactTooltip = "open"
		
func lock():
	.lock() 

func unlock():
	.unlock()
	interact()
