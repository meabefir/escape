extends Lock

onready var ui = get_node("CanvasLayer/LockScreen")
onready var lockScreen3d = get_node("Viewport/LockScreen")
#export(NodePath) onready var ui = get_node(ui)
#export(NodePath) onready var lockScreen3d = get_node(lockScreen3d)

export var code: String

func _ready():
	ui.hide()
	ui.connect("entered", self, "codeEntered")
	ui.connect("closed", self, "lockMenuClosed")
	ui.connect("textChanged", self, "lockTextChanged")
	ui.connect("error", self, "lockError")
	ui.connect("unlocked", self, "lockUnlocked")
	
	interactTooltip = "enter code"

	unlockedLayer = 0 + 2
	lockedLayer = 0

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
		ui.unlock()
		lockScreen3d.unlock()
	else:
		ui.error()

func lockUnlocked():
	ui.hide()
	freePlayer()
	
	ui.maxLength = 9
	ui.text = "unlocked"

	lock(null)
	.lockUnlocked()

func lockTextChanged(_text):
	lockScreen3d.text = _text

func lockError():
	lockScreen3d.error()
