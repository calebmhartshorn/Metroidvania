tool
extends Resource

class_name MapData

func get_map_data(room):
	return map_data[room]

func rename_room(old_name, new_name):
	if map_data.has(old_name) and (not map_data.has(new_name)):
		map_data[new_name] = map_data[old_name]
		map_data.erase(old_name)
		return true
	else:
		return false

func get_rooms():
	return map_data.keys()

func add_room(name, position, size):
	if map_data.has(name):
		print("Attempted to create duplicate room")
		return
	map_data[name] = [Rect2 (
			# Position
			Vector2(position),
			# Size
			Vector2(size)
		),
		# Neighbors
		[]
	]

func room_contains_position(pos : Vector2) -> bool:
	for i in map_data:
		if not map_data[i][0].has_point(pos):
			continue
		# Found
		return true
		
	# Not Found
# warning-ignore:unreachable_code
	return false

func position_to_room(pos : Vector2) -> String:
	for i in map_data:
		if not map_data[i][0].has_point(pos):
			continue
		# Found
		return str(i)
		
	# Not Found
# warning-ignore:unreachable_code
	return ""

export var map_data = {
	# Name
	"Room_1" : [
		Rect2 (
			# Position
			Vector2(0, 0),
			# Size
			Vector2(100, 100)
		),
		# Neighbors
		[
			"Room_2",
			"Room_4"
		]
	] ,
	
	"Room_2" : [
		Rect2 (
			# Position
			Vector2(100, 0),
			# Size
			Vector2(200, 100)
		),
		# Neighbors
		[
			"Room_1",
			"Room_5"
		]
	]
}
