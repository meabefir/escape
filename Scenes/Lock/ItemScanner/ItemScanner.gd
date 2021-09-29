extends Lock

export(NodePath) var neededItem
onready var areaMesh = get_node("ScanArea/MeshInstance")
onready var tween = get_node("Tween")

var badColor = Color8(241, 0, 0, 93)
var goodColor = Color8(36, 241, 0, 93)

var itemsInside = []

func _ready():
	if neededItem != "":
		neededItem = get_node(neededItem)
	else:
		neededItem = null

func checkItems():
	if itemsInside.size() > 1 or itemsInside.size() == 0:
		lockLocked()
		if interactableLocked:
			interactableLocked.lock(self)
		var mat: Material = areaMesh.get_surface_material(0)
		tween.stop_all()
		tween.interpolate_property(mat, "albedo_color", mat.albedo_color, badColor, .3)
		tween.start()
		return
	if itemsInside.size() == 1 and itemsInside[0] == neededItem:
		lockUnlocked()
		var mat: Material = areaMesh.get_surface_material(0)
		tween.stop_all()
		tween.interpolate_property(mat, "albedo_color", mat.albedo_color, goodColor, .3)
		tween.start()

func _on_ScanArea_body_entered(body):
	if not body in itemsInside:
		itemsInside.append(body) 
	checkItems()
		
func _on_ScanArea_body_exited(body):
	itemsInside.erase(body)
	checkItems()
		
