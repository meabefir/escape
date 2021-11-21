extends Interactable

class_name Lock

export(Array, NodePath) var interactablesLocked
export var lockOnStart = true

export(Array, NodePath) var lines3d

func _ready():
	for i in range(interactablesLocked.size()):
		interactablesLocked[i] = get_node(interactablesLocked[i])
	
	for i in range(lines3d.size()):
		lines3d[i] = get_node(lines3d[i])
	
	if lockOnStart:
		lockLocked()

func lockLocked():
	for line in lines3d:
		if line:
			line.unhighlight()

	if interactablesLocked.size() == 0:
		return
	for i in range(interactablesLocked.size()):
		interactablesLocked[i].lock(self)

func lockUnlocked():
	for line in lines3d:
		if line:
			line.highlight()
	
	if interactablesLocked.size() == 0:
		return
	for i in range(interactablesLocked.size()):
		interactablesLocked[i].unlock(self)
