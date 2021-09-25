extends Lock

export(NodePath) onready var ui = get_node(ui)
export(NodePath) onready var lockScreen3d = get_node(lockScreen3d)

export var code: String

func _ready():
	ui.hide()
	ui.connect("entered", self, "codeEntered")
	ui.connect("closed", self, "lockMenuClosed")
	ui.connect("textChanged", self, "lockTextChanged")
	
	interactTooltip = "enter code"

	unlockedLayer = 1 + 2
	lockedLayer = 1

func interact():
	openUi()

func openUi():
	# lock player in place aka no input
	var player = get_tree().get_nodes_in_group("player")[0]
	player.state = Player.STATE.INTERACT_MENU
	
	ui.reset()
	ui.show()
	
func lockMenuClosed():
	freePlayer()
	
func freePlayer():
	var player = get_tree().get_nodes_in_group("player")[0]
	player.state = Player.STATE.DEFAULT

func codeEntered(_code):
	if _code == code:
		ui.hide()
		interactableLocked.unlock()
		freePlayer()
		
		ui.maxLength = 9
		ui.text = "unlocked"
	
		lock()
	else:
		ui.reset()

func lockTextChanged(_text):
	lockScreen3d.text = _text
