extends MeshInstance

export(NodePath) onready var label = get_node(label)

func _physics_process(delta):
	var player = get_tree().get_nodes_in_group("player")[0]
	look_at(player.global_transform.origin, Vector3.UP)
	label.text = str(rotation_degrees)
