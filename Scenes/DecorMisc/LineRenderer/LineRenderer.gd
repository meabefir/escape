extends Spatial
tool

# LINE RENDERERS SHOULD BE ABOVE THE LOCKS THEY BELONG TO IN THE SCENE TREE

onready var positions = get_node("positions")
onready var meshes = get_node("meshes")

var points = []
var rotations = []

onready var lineScene = preload("res://Scenes/DecorMisc/LineRenderer/LineSegment.tscn")
export(Color) var color = Color.red setget setColor
export(Color) var defaultColor = Color.red
export(Color) var highlightColor = Color.green

func setColor(value):
	color = value
	
	for child in meshes.get_children():
		var mat = child.get_surface_material(0)
		mat.albedo_color = value

func highlight():
	self.color = highlightColor

func unhighlight():
	self.color = defaultColor

func _ready():
	var children = positions.get_children()
	for child in children:
		points.append(child.global_transform.origin)
		
	for i in range(children.size()-1):
		children[i].look_at(children[i+1].global_transform.origin, Vector3.UP + Vector3(.0000001, .0000001, .0000001))
		#print(children[i].rotation_degrees)
		rotations.append(children[i].rotation_degrees)
		
	for i in range(points.size() - 1):
		var from = points[i]
		var to = points[i+1]
		
		var pos = (from + to) / 2
		var new_line: MeshInstance = lineScene.instance()
		meshes.add_child(new_line)
		new_line.global_transform.origin = pos
		
		var mat = new_line.get_surface_material(0)
		mat.albedo_color = color
		
		var dist = from.distance_to(to)
		new_line.scale.z = dist + .05
		var direction = to - from
		if rotations[i] != Vector3():
			new_line.rotation_degrees = rotations[i]
