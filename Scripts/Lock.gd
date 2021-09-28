extends Interactable

class_name Lock

export(NodePath) var interactableLocked
export var lockOnStart = true

func _ready():
	if interactableLocked != "":
		interactableLocked = get_node(interactableLocked)
	else:
		interactableLocked = null
	
	if lockOnStart:
		lockLocked()

func lockLocked():
	if interactableLocked == null:
		return
	interactableLocked.lock(self)

func lockUnlocked():
	if interactableLocked == null:
		return
	interactableLocked.unlock(self)
