extends StaticBody

class_name Interactable

var interactTooltip = ""
export var locked = false

export var noCollisionWhenLocked = false
export var interactOnUnlock = true
export(Array, NodePath) var chainsWith

var unlockedLayer = 0 + 2
var lockedLayer = 0

var lockedBy = []

func _ready():
	for i in range(chainsWith.size()):
		chainsWith[i] = get_node(chainsWith[i])

func interact():
	for interactable in chainsWith:
		interactable.interact()
	
func lock(by):
	if by in lockedBy:
		return
	locked = true
	lockedBy.append(by)
	if noCollisionWhenLocked:
		collision_layer = lockedLayer

func unlock(by):
	lockedBy.erase(by)
	if lockedBy.size() == 0:
		# unlocked it
		locked = false
		if noCollisionWhenLocked:
			collision_layer = unlockedLayer
		if interactOnUnlock:
			interact()
