extends Interactable

onready var animationPlayer = get_node("AnimationPlayer")
export(NodePath) onready var wall = get_node(wall)

var closed = true

func _ready():
	interactTooltip = "open" if closed else "close"

func getAngleToPlayer():
	var player = get_tree().get_nodes_in_group("player")[0]
	var dir_to_player = wall.global_transform.origin.direction_to(player.global_transform.origin)
	return rad2deg(Vector3.FORWARD.rotated(Vector3.UP, deg2rad(wall.rotation_degrees.y)).angle_to(dir_to_player))

func interact():
	if closed:
		open()
	else:
		close()

func open():
	var angle_to_player = getAngleToPlayer()
	if angle_to_player <= 90:
		animationPlayer.play("open")
	else:
		animationPlayer.play("open_back")
	closed = false
	interactTooltip = "close"

func close():
	if rotation_degrees.y > 0:
		animationPlayer.play_backwards("open")
	else:
		animationPlayer.play_backwards("open_back")
	closed = true
	interactTooltip = "open"

func lock(by):
	.lock(by) 
	if !closed:
		close()

func unlock(by):
	.unlock(by)
