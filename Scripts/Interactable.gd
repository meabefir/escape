extends StaticBody

class_name Interactable

var interactTooltip = ""
export var locked = false
export var lockedMessage = "locked"

export var onlyInteractOnUnlock = false
export var interactOnUnlock = true
export(Array, NodePath) var chainsWithPropagate
export(Array, NodePath) var chainsWith

# default collisions, world and interactable layer when unlocked
# world layer when locked
var unlockedLayer = 1 + 2
var lockedLayer = 1

var lockedBy = []

func _ready():
	if locked:
		collision_layer = lockedLayer
	else:
		collision_layer = unlockedLayer
		
	for i in range(chainsWithPropagate.size()):
		chainsWithPropagate[i] = get_node(chainsWithPropagate[i])
	for i in range(chainsWith.size()):
		chainsWith[i] = get_node(chainsWith[i])

func interact(propagate = true):
	if propagate:
		for interactable in chainsWithPropagate:
			interactable.interact()
		for interactable in chainsWith:
			interactable.interact(false)
	
func lock(by):
	if by in lockedBy:
		return
	locked = true
	lockedBy.append(by)
	collision_layer = lockedLayer

func unlock(by):
	lockedBy.erase(by)
	if lockedBy.size() == 0:
		if onlyInteractOnUnlock:
			interact()
		else:
			# unlocked it
			locked = false
			collision_layer = unlockedLayer
			if interactOnUnlock:
				interact()
