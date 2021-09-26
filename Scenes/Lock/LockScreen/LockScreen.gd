extends Control

signal entered
signal closed
signal textChanged
signal error
signal unlocked

export(NodePath) onready var label = get_node(label)

onready var animationPlayer = get_node("AnimationPlayer")

var canTakeInput = true
export var maxLength = 4
var text = "" setget setText

func setText(value):
	if !canTakeInput:
		return
	if value.length() <= maxLength:
		text = value
	else:
		return
	
	label.text = text
	
	emit_signal("textChanged", text)
	if text.length() == maxLength:
		emit_signal("entered", text)

func error():
	emit_signal("error")
	canTakeInput = false
	animationPlayer.play("error")
	yield(animationPlayer, "animation_finished")
	canTakeInput = true
	reset()

func unlock():
	canTakeInput = false
	animationPlayer.play("unlocked")
	yield(animationPlayer, "animation_finished")
	canTakeInput = true
	emit_signal("unlocked")

func _input(event):
	if Input.is_action_just_pressed("escape"):
		if visible:
			emit_signal("closed")
			hide()
	if visible and canTakeInput:
		if Input.is_action_just_pressed("1"):
			self.text += "1"
		if Input.is_action_just_pressed("2"):
			self.text += "2"
		if Input.is_action_just_pressed("3"):
			self.text += "3"
		if Input.is_action_just_pressed("4"):
			self.text += "4"
		if Input.is_action_just_pressed("5"):
			self.text += "5"
		if Input.is_action_just_pressed("6"):
			self.text += "6"
		if Input.is_action_just_pressed("7"):
			self.text += "7"
		if Input.is_action_just_pressed("8"):
			self.text += "8"
		if Input.is_action_just_pressed("9"):
			self.text += "9"
		
			
func _ready():
	self.text = ""

func reset():
	self.text = ""

func _on_b1_pressed():
	self.text += "1"

func _on_b2_pressed():
	self.text += "2"

func _on_b3_pressed():
	self.text += "3"

func _on_b4_pressed():
	self.text += "4"

func _on_b5_pressed():
	self.text += "5"

func _on_b6_pressed():
	self.text += "6"

func _on_b7_pressed():
	self.text += "7"

func _on_b8_pressed():
	self.text += "8"

func _on_b9_pressed():
	self.text += "9"

func _on_backspace_pressed():
	self.text = text.substr(0, text.length() - 1)

func _on_delete_pressed():
	self.text = ""

func _on_confirm_pressed():
	if !canTakeInput:
		return
	emit_signal("entered", text)
