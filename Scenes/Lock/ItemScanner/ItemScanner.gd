extends Lock

export(NodePath) onready var neededItem = get_node(neededItem)
onready var areaMesh = get_node("ScanArea/MeshInstance")

var badColor = Color8(241, 0, 0, 93)
var goodColor = Color8(36, 241, 0, 93)

var itemsInside = []

func checkItems():
	if itemsInside.size() > 1 or itemsInside.size() == 0:
		interactableLocked.lock(self)
		var mat: Material = areaMesh.get_surface_material(0)
		mat.albedo_color = badColor
		return
	if itemsInside.size() == 1 and itemsInside[0] == neededItem:
		lockUnlocked()
		var mat: Material = areaMesh.get_surface_material(0)
		mat.albedo_color = goodColor

func _on_ScanArea_body_entered(body):
	if not body in itemsInside:
		itemsInside.append(body) 
	checkItems()
		
func _on_ScanArea_body_exited(body):
	itemsInside.erase(body)
	checkItems()
		
