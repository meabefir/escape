extends StaticBody

class_name Interactable

var interactTooltip = null
var locked = false
export var noCollisionWhenLocked = false

var unlockedLayer
var lockedLayer

func interact():
	pass
	
func lock():
	locked = true
	if noCollisionWhenLocked:
		collision_layer = lockedLayer

func unlock():
	locked = false
	if noCollisionWhenLocked:
		collision_layer = unlockedLayer
