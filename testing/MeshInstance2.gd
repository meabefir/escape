extends MeshInstance

func _physics_process(delta):
	var player = get_tree().get_nodes_in_group("player")[0]
	look_at(player.global_transform.origin, Vector3.UP)
