extends Interactable

onready var spawnPos = get_node("SpawnPosition")

export(NodePath) var itemScannerConnected
export(Array, PackedScene) var itemsSpawnedScenes
export(int) var currentIndex = 0

export var maxItems = 10
var itemsSpawned = []

func _ready():
	interactTooltip = "spawn item"
	lockedMessage = ""
	
	if itemScannerConnected != "":
		itemScannerConnected = get_node(itemScannerConnected)
	else:
		itemScannerConnected = null
	
func interact(propagate = true):
	.interact(propagate)
	
	var new_item = itemsSpawnedScenes[currentIndex].instance()
	add_child(new_item)
	new_item.global_transform.origin = spawnPos.global_transform.origin
	
	if itemScannerConnected:
		itemScannerConnected.neededItem = new_item
	
	itemsSpawned.append(new_item)
	if itemsSpawned.size() > maxItems:
		itemsSpawned[0].queue_free()
		itemsSpawned.pop_front()
