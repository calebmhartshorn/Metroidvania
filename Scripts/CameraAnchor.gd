extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var smoothing = 0.1

# Called when the node enters the scene tree for the first time.
func _physics_process(_delta):
	#position = Vector2( round(get_node("../Player").get_position().x), round(get_node("../Player").get_position().y) )
	position += Vector2( 
	round(smoothing * (get_node("../Player").get_position().x - position.x)), 
	round(smoothing * (get_node("../Player").get_position().y - position.y)) 
	)
