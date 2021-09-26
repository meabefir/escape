extends StaticBody

class_name Interactable

var interactTooltip = ""
var locked = false

export var noCollisionWhenLocked = false
export var interactOnUnlock = true

var unlockedLayer
var lockedLayer

var lockedBy = []

func interact():
	pass
	
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
