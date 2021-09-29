extends Interactable

class_name Lock

export(NodePath) var interactableLocked
export var lockOnStart = true

export(Array, NodePath) var lines3d

func _ready():
	if interactableLocked != "":
		interactableLocked = get_node(interactableLocked)
	else:
		interactableLocked = null
	
	for i in range(lines3d.size()):
		lines3d[i] = get_node(lines3d[i])
	
	if lockOnStart:
		lockLocked()

func lockLocked():
	if interactableLocked == null:
		return
	interactableLocked.lock(self)

	for line in lines3d:
		if line:
			line.unhighlight()

func lockUnlocked():
	if interactableLocked == null:
		return
	interactableLocked.unlock(self)
	
	for line in lines3d:
		if line:
			line.highlight()
