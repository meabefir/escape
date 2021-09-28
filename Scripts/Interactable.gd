extends StaticBody

class_name Interactable

var interactTooltip = ""
export var locked = false

export var noCollisionWhenLocked = false
export var interactOnUnlock = true
export(Array, NodePath) var chainsWithPropagate
export(Array, NodePath) var chainsWith

var unlockedLayer = 0 + 2
var lockedLayer = 0

var lockedBy = []

func _ready():
	if locked:
		collision_layer = lockedLayer
	else:
		collision_layer = unlockedLayer
		
	for i in range(chainsWithPropagate.size()):
		chainsWithPropagate[i] = get_node(chainsWithPropagate[i])

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
#	if noCollisionWhenLocked:
#		collision_layer = lockedLayer\
	collision_layer = lockedLayer

func unlock(by):
	lockedBy.erase(by)
	if lockedBy.size() == 0:
		# unlocked it
		locked = false
#		if noCollisionWhenLocked:
#			collision_layer = unlockedLayer
		collision_layer = unlockedLayer
		if interactOnUnlock:
			interact()
