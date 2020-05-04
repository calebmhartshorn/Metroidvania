extends TileMap

var Light_Tank = preload("res://Scenes/Light_Tank.tscn")
var Gauge_1 = preload("res://Scenes/Light_Gauge_1.tscn")

func _ready():
	
	#show()
	
	var size_x = get_cell_size().x
	var size_y = get_cell_size().y
	var tileset = get_tileset()
	var used_cells = get_used_cells()
	
	for pos in used_cells :
		var id = get_cell(pos.x, pos.y)
		var name = tileset.tile_get_name(id)
		if name == "Tank_1":
			var node = Light_Tank.instance()
			#node.set_position(Vector2( pos.x * size_x + (0.5 * size_x), pos.y * size_y + (0.5 * size_y)))
			node.set_position(Vector2( pos.x * size_x + (size_x), pos.y * size_y + (3 * size_y)))
			get_node('../Lights').add_child(node)
			#set_cell(pos.x, pos.y, -1) #this line remove the tile in TileMap
		if name == "Gauge_1":
					var node = Gauge_1.instance()
					node.set_position(Vector2( pos.x * size_x + (0.5 * size_x), pos.y * size_y + (0.5 * size_y)))
					get_node('../Lights').add_child(node)
					#set_cell(pos.x, pos.y, -1) #this line remove the tile in TileMap
