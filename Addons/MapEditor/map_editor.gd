tool
extends TileMap

class_name MapEditor

var Light_Tank = preload("res://Scenes/Light_Tank.tscn")
var Gauge_1 = preload("res://Scenes/Light_Gauge_1.tscn")
var Door_1 = preload("res://Scenes/Door_1.tscn")

var map =  preload("res://Map.tres")

var current_room = map.map_data.keys()[0]
var rename
var neighborCount = 0

export var color : Color = Color("#89fff1") setget set_color
export var selected_color : Color = Color("#f056ad") setget set_selected_color

func _get(property):
	
	#map.get_map_data(current_room)[1].resize(neighborCount)
	if not map.map_data.has(current_room):
		current_room = map.map_data.keys()[0]
	
	if property == "MapEditor/room":
		return current_room
	if property == "MapEditor/name":
		return rename
	if property == "MapEditor/rect":
		return map.get_map_data(current_room)[0]
	if property == "MapEditor/neighborCount":
		return neighborCount
	for i in range(neighborCount):
		if property == "MapEditor/neighbor_" + str(i+1):
			return map.map_data[current_room][1][i]

func _set(property, value):
	
	if not map.map_data.has(current_room):
		current_room = map.map_data.keys()[0]
	
	# If changing current room
	if property == "MapEditor/room":
		rename = value
		current_room = value
		neighborCount = len(map.get_map_data(current_room)[1])
	# If renaming current room
	if property == "MapEditor/name":
		
		if value == "Null":
			return true
		
		if map.rename_room(current_room, value):
			current_room = value
		rename = value
	if property == "MapEditor/rect":
		map.map_data[current_room][0] = value
	if property == "MapEditor/neighborCount":
		neighborCount = value
		map.get_map_data(current_room)[1].resize(neighborCount)
	for i in range(neighborCount):
			if property == "MapEditor/neighbor_" + str(i+1) and value != null:
				map.map_data[current_room][1][i] = value
	
	rename = current_room
	neighborCount = len(map.get_map_data(current_room)[1])
	update()
	property_list_changed_notify()

# call once when node selected 
func _get_property_list():

	var property_list = []
	var rooms = str(map.get_rooms()).replace("[", "").replace("]","").replace(" ","")
	property_list.append({
		"name": "MapEditor/refresh",
		"type": TYPE_BOOL
	})
	property_list.append({
		"name": "MapEditor/room",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": rooms
	})
	#if current_room != "":
	property_list.append({
		"name": "MapEditor/name",
		"type": TYPE_STRING,
	})
	property_list.append({
		"name": "MapEditor/rect",
		"type": TYPE_RECT2,
	})
	property_list.append({
		"name": "MapEditor/neighborCount",
		"type": TYPE_INT,
	})
	for i in range(neighborCount):
		property_list.append({
			"name": "MapEditor/neighbor_" + str(i + 1),
			"type": TYPE_STRING,
			#"hint": PROPERTY_HINT_ENUM,
			#"hint_string": rooms
		})

	return property_list




func set_color(value: Color) -> void:
	color = value
	update()
	
func set_selected_color(value: Color) -> void:
	selected_color = value
	update()

func load_room(room_name : String, load_neighbors : bool):
	
	var names = []
	for i in get_node("../LoadedRooms").get_children():
		names.append(i.get_name())
	
	if (not names.has(room_name)) and map.get_rooms().has(room_name):
		
		var room_node = Node2D.new()
		var lights_node = Node2D.new()
		var enemies_node = Node2D.new()
		var doors_node = Node2D.new()
		room_node.set_name(room_name)
		lights_node.set_name("Lights")
		enemies_node.set_name("Enemies")
		doors_node.set_name("Doors")
		
		room_node.add_child(lights_node)
		room_node.add_child(enemies_node)
		room_node.add_child(doors_node)
		
		get_node("../LoadedRooms").add_child(room_node)
		
		var lights_path = "../LoadedRooms/" + room_name + "/Lights"
	# warning-ignore:unused_variable
		var enemies_path = "../LoadedRooms/" + room_name + "/Enemies"
		var doors_path = "../LoadedRooms/" + room_name + "/Doors"
		
		var size_x = get_cell_size().x
		var size_y = get_cell_size().y
		var tileset = get_tileset()
		
		var room = Rect2(
			Vector2(
				map.map_data[room_name][0].position.x / 16,
				map.map_data[room_name][0].position.y / 16
			),
			Vector2(
				map.map_data[room_name][0].size.x / 16,
				map.map_data[room_name][0].size.y / 16
			)
		)
		
		var used_tiles = get_used_cells()
		
		for y in range(room.size.y) :
			for x in range(room.size.x) :
				
				var pos = Vector2(room.position.x +  x, room.position.y + y)
				if used_tiles.has(pos):
					
					var id = get_cell(pos.x, pos.y)
					var name = tileset.tile_get_name(id)
					
					if name == "Tank_1":
						var node = Light_Tank.instance()
						node.set_position(Vector2(pos.x * size_x + (size_x), pos.y * size_y + (3 * size_y)))
						get_node(lights_path).add_child(node)
					if name == "Gauge_1":
						var node = Gauge_1.instance()
						node.set_position(Vector2(pos.x * size_x + (0.5 * size_x), pos.y * size_y + (0.5 * size_y)))
						get_node(lights_path).add_child(node)
						#set_cell(pos.x, pos.y, -1) #this line remove the tile in TileMap
					if name == "Door_1":
						var node = Door_1.instance()
						node.set_position(Vector2(pos.x * size_x + (size_x), pos.y * size_y + (2 * size_y)))
						node.flip_h = is_cell_x_flipped(pos.x, pos.y)
						get_node(doors_path).add_child(node)
						#set_cell(pos.x, pos.y, -1) #this line remove the tile in TileMap

	if load_neighbors:
		for n in map.map_data[room_name][1]:
			load_room(str(n), false)

func unload_room(room_name : String):
	
	if not get_node("../LoadedRooms/").has_node(room_name):
		return
	
	var node = get_node("../LoadedRooms/" + room_name)
	get_node("../LoadedRooms/").remove_child(node)
	node.queue_free()
