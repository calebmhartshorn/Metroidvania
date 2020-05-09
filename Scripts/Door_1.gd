extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var anim = get_node("AnimationPlayer")
onready var open = get_node("open")
onready var close = get_node("close")

var map = preload("res://Map.tres")

var dist = 64
# Called when the node enters the scene tree for the first time.
func _ready():
	var player = get_tree().get_root().get_node("Root/Player")
	var dif = player.position - position
	if abs(dif.x) < dist and abs(dif.y) < dist:
		anim.play("Open")
	else:
		anim.play("Closed")

func _process(_delta):
	var player = get_tree().get_root().get_node("Root/Player")
	var dif = player.position - position
	if abs(dif.x) < dist and abs(dif.y) < dist:
		if flip_h:
			if anim.get_assigned_animation() != "Closed->Open" and player.position.x < position.x and anim.get_assigned_animation() != "Open": #and map.position_to_room(player.position) == map.position_to_room(position):
				anim.play("Closed->Open")
				open.play()
		else:
			if anim.get_assigned_animation() != "Closed->Open" and player.position.x > position.x and anim.get_assigned_animation() != "Open": #and map.position_to_room(player.position) == map.position_to_room(position):
				anim.play("Closed->Open")
				open.play()
	elif abs(dif.x) > 1.5 * dist or abs(dif.y) > 1.5 * dist:
		if flip_h:
			if anim.get_assigned_animation() != "Open->Closed" and player.position.x < position.x and anim.get_assigned_animation() != "Closed":#  and map.position_to_room(player.position) != map.position_to_room(position):
				anim.play("Open->Closed")
				close.play()
		else:
			if anim.get_assigned_animation() != "Open->Closed" and player.position.x > position.x and anim.get_assigned_animation() != "Closed":#  and map.position_to_room(player.position) != map.position_to_room(position):
				anim.play("Open->Closed")
				close.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
