extends Interactable

class_name Lock

export(NodePath) onready var interactableLocked = get_node(interactableLocked)

func _ready():
	interactableLocked.lock(self)

func lockUnlocked():
	interactableLocked.unlock(self)
