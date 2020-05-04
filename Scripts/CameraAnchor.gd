extends Node2D

var smoothing = 0.2
var offset = Vector2(0,0)
var offset_width = 100
var pos = Vector2()

func _physics_process(_delta):
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
		if get_node("../Player/Sprite").flip_h:
			offset.x += (-offset_width - offset.x) * 0.01
		else:
			offset.x += (offset_width - offset.x) * 0.01
	
	pos.x += smoothing * ((get_node("../Player").get_position().x + offset.x) - pos.x)
	pos.y += smoothing * ((get_node("../Player").get_position().y + offset.y) - pos.y)
	position = Vector2(round(pos.x), round(pos.y))
