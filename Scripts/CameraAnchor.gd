extends Node2D

var smoothing = 0.2
var offset = Vector2(0,0)
var offset_width = 100
var pos = Vector2()
var target = Vector2()
var max_scroll_speed = 32
#ar vel = Vector2(0,0)

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
	
	var player_pos = get_node("../Player").get_position()
	target = player_pos + offset
	
	var position_to_room = map.position_to_room(player_pos)
	if position_to_room == "Null":
		return
	var room = map.map_data[position_to_room][0]
	
	target.x = max(target.x, room.position.x + (screen_size.x / 2))
	target.x = min(target.x, room.position.x + room.size.x - (screen_size.x / 2))
	target.y = max(target.y, room.position.y + (screen_size.y / 2))
	target.y = min(target.y, room.position.y + room.size.y - (screen_size.y / 2))
	
	#sqt / (2.0f * (sqt - t) + 1.0f);
	
#	vel *= 0.8
#	vel.x += 2 * ((target.x - pos.x) / abs(target.x - pos.y))
#	vel.y += 2 * ((target.y - pos.y) / abs(target.y - pos.y))
#	if abs(target.x - pos.x) < 1:
#		vel.x *= abs(target.x - pos.x)
#	if abs(target.y - pos.y) < 1:
#		vel.y *= abs(target.y - pos.y)
#
#	pos += vel
	
	pos.x += to_range(smoothing * (target.x - pos.x), -max_scroll_speed, max_scroll_speed)
	pos.y += to_range(smoothing * (target.y - pos.y), -max_scroll_speed, max_scroll_speed)
	
	position = Vector2(round(pos.x), round(pos.y))
	
	# Unload/Load Rooms
	if current_room != position_to_room:
		for i in loaded_rooms.get_children():
			if i.get_name() != current_room:
				print("Unloading: " + i.get_name())
				tiles.unload_room(i.get_name())
		current_room = position_to_room
		tiles.load_room(current_room, false)
		
func to_range(value, _min, _max):
	return max(_min, min(value, _max))
