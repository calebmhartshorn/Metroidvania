extends TileMap

var Light_Tank = preload("res://Scenes/Light_Tank.tscn")
var Gauge_1 = preload("res://Scenes/Light_Gauge_1.tscn")
var map =  preload("res://Map.tres")

var current_room = "Main_Room"

func _ready():
	
	#show()
	
	var size_x = get_cell_size().x
	var size_y = get_cell_size().y
	var tileset = get_tileset()
	
	var room = Rect2(
		Vector2(
			map.map_data[current_room][0].position.x / 16,
			map.map_data[current_room][0].position.y / 16
		),
		Vector2(
			map.map_data[current_room][0].size.x / 16,
			map.map_data[current_room][0].size.y / 16
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
					get_node('../Lights').add_child(node)
				if name == "Gauge_1":
							var node = Gauge_1.instance()
							node.set_position(Vector2(pos.x * size_x + (0.5 * size_x), pos.y * size_y + (0.5 * size_y)))
							get_node('../Lights').add_child(node)
							#set_cell(pos.x, pos.y, -1) #this line remove the tile in TileMap
