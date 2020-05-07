extends Node2D

var smoothing = 0.2
var offset = Vector2(0,0)
var offset_width = 100
var pos = Vector2()

var current_room = ""
var map = preload("res://Map.tres")

var screen_size = Vector2(ProjectSettings.get_setting("display/window/size/width"),ProjectSettings.get_setting("display/window/size/height"))

onready var tiles = get_node("../Foreground")
onready var loaded_rooms = get_node("../LoadedRooms")

#func _ready():
#	tiles.load_room("Main_Room", false)

func _physics_process(_delta):
	
	if not map.room_contains_position(get_node("../Player").position):
		get_node("../Player").position = Vector2(256, 88)

	
	
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
		if get_node("../Player/Sprite").flip_h:
			offset.x += (-offset_width - offset.x) * 0.01
		else:
			offset.x += (offset_width - offset.x) * 0.01
	
	pos.x += smoothing * ((get_node("../Player").get_position().x + offset.x) - pos.x)
	pos.y += smoothing * ((get_node("../Player").get_position().y + offset.y) - pos.y)
	
	var position_to_room = map.position_to_room(get_node("../Player").position)
	var room = map.map_data[position_to_room][0]
	
	pos.x = max(pos.x, room.position.x + (screen_size.x / 2))
	pos.x = min(pos.x, room.position.x + room.size.x - (screen_size.x / 2))
	pos.y = max(pos.y, room.position.y + (screen_size.y / 2))
	pos.y = min(pos.y, room.position.y + room.size.y - (screen_size.y / 2))
	
	position = Vector2(round(pos.x), round(pos.y))
	
	# Unload/Load Rooms
	if current_room != position_to_room:
		for i in loaded_rooms.get_children():
			if i.get_name() != current_room:
				print("Unloading: " + i.get_name())
				tiles.unload_room(i.get_name())
		current_room = position_to_room
		tiles.load_room(current_room, false)
