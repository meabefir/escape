extends Spatial

# LINE RENDERERS SHOULD BE ABOVE THE LOCKS THEY BELONG TO IN THE SCENE TREE

var points = []
var rotations = []

onready var lineScene = preload("res://Scenes/DecorMisc/LineRenderer/LineSegment.tscn")
export(Color) var color = Color.red setget setColor
export(Color) var defaultColor = Color.red
export(Color) var highlightColor = Color.green

func setColor(value):
	color = value
	
	for child in get_children():
		var mat = child.get_surface_material(0)
		mat.albedo_color = value

func highlight():
	self.color = highlightColor

func unhighlight():
	self.color = defaultColor

func _ready():
	var children = get_children()
	for child in children:
		points.append(child.global_transform.origin)
	for i in range(children.size()-1):
		children[i].look_at(children[i+1].global_transform.origin, Vector3.UP)
		if children[i].rotation_degrees != Vector3.ZERO:
			rotations.append(children[i].rotation_degrees)
		else:
			rotations.append(Vector3(90, 0, 0))
		
	for child in children:
		child.free()
		
	for i in range(points.size() - 1):
		var from = points[i]
		var to = points[i+1]
		
		var pos = (from + to) / 2
		var new_line: MeshInstance = lineScene.instance()
		add_child(new_line)
		new_line.global_transform.origin = pos
		
		var mat = new_line.get_surface_material(0)
		mat.albedo_color = color
		
		var dist = from.distance_to(to)
		new_line.scale.z = dist + .05
		var direction = to - from
		new_line.rotation_degrees = rotations[i]
		#new_line.rotate_y(deg2rad(-90))
