tool
extends EditorPlugin

var map_editor: MapEditor
var map = load("res://Map.tres")

enum Anchors { TOP_LEFT, BOTTOM_RIGHT }

# List of all anchors drawn over the RectExtents node
# Each anchor has the form { position: Vector2, rect: Rect2 }
var anchors: Array
# Get and stores the anchor the user is dragging from the anchors array above
var dragged_anchor: Dictionary = {}
# Stores the RectExtents' state when the user starts dragging an anchor
# we need this info to safely add undo/redo support when the drag operation ends
#var rect_drag_start: Dictionary = {'size': Vector2(), 'offset': Vector2()}

const CIRCLE_RADIUS: float = 9.0
const STROKE_RADIUS: float = 2.0
const FILL_COLOR = Color("#ffffff")

func edit(object: Object) -> void:
	print("edit %s" % object.get_path())
	map_editor = object

func make_visible(_visible: bool) -> void:
#	# Called when the editor is requested to become visible.
#	if not map_editor:
#		return
#	if not visible:
#		map_editor = null
# warning-ignore:return_value_discarded
	update_overlays()

func handles(object: Object) -> bool:
	# Required to use forward_canvas_draw_... below
	print(object is MapEditor)
	return object is MapEditor


func forward_canvas_draw_over_viewport(overlay: Control) -> void:
	
	if not map_editor:
		return
	
	var current_room = map_editor.current_room
	if not map.map_data.has(map_editor.current_room):
		return
		
	var pos = map.map_data[current_room][0].position
	var size: Vector2 = map.map_data[current_room][0].size
	
	var edit_anchors := {
		Anchors.TOP_LEFT: pos,
		Anchors.BOTTOM_RIGHT: pos + size
	}
	
	var selected_color = map_editor.selected_color
	var color = map_editor.color

	anchors = []
	var transform_viewport := map_editor.get_viewport_transform()
	var transform_global := map_editor.get_canvas_transform()
	
	while map_editor.get_node("Labels").get_child_count() >map.map_data.size():
		var node = map_editor.get_node("Labels").get_child(0)
		map_editor.get_node("Labels").remove_child(node)
		node.queue_free()
	while map_editor.get_node("Labels").get_child_count() < map.map_data.size():

		map_editor.get_node("Labels").add_child(Label.new())
	var j = 0
	for i in map.map_data:

		# Draw Rects
# warning-ignore:unused_variable
		var rect_pos: Vector2 = transform_viewport * (transform_global * map.map_data[i][0].position)
# warning-ignore:unused_variable
		var rect_br: Vector2 = transform_viewport * (transform_global * (map.map_data[i][0].position + map.map_data[i][0].size))
		#var rect_size: Vector2 = Vector2(rect_br - rect_pos) - Vector2(1, 1)
		
		if i == current_room:
			draw_rect(map.map_data[i][0], selected_color, false, overlay)
			#draw_rect(Rect2(map.map_data[i][0].position + Vector2(1, 1), map.map_data[i][0].size + Vector2(-2, -2)), selected_color, false, overlay)
			#overlay.draw_rect(Rect2(rect_pos, rect_size), selected_color, false)
			#overlay.draw_rect(Rect2(rect_pos + Vector2(1, 1), rect_size + Vector2(-2, -2)), selected_color, false)
		else:
			draw_rect(map.map_data[i][0], color, false, overlay)
			#overlay.draw_rect(Rect2(rect_pos, rect_size), color, false)
			#overlay.draw_rect(Rect2(rect_pos + Vector2(1, 1), rect_size + Vector2(-2, -2)), color, false)
		
		# Label Rooms
		var label = map_editor.get_node("Labels").get_child(j)
		label.set_text(i)
		label.set_scale(Vector2(2, 2))
		label.set_position(map.map_data[i][0].position)
		
		j += 1
	var anchor_size: Vector2 = Vector2(CIRCLE_RADIUS * 2.0, CIRCLE_RADIUS * 2.0)
	
	var type = "Pos"
	for coord in edit_anchors.values():

		var anchor_center: Vector2 = transform_viewport * (transform_global * coord)
		var new_anchor = {
			'position': anchor_center,
			'rect': Rect2(anchor_center - anchor_size / 2.0, anchor_size),
			'type': type
		}
		draw_anchor(new_anchor, overlay)
		anchors.append(new_anchor)
		type = "Size"

func draw_anchor(anchor: Dictionary, overlay: Control) -> void:
	var pos = Vector2(round(anchor['position'].x), round(anchor['position'].y))
	var selected_color = map_editor.selected_color
	overlay.draw_circle(pos, CIRCLE_RADIUS, selected_color)
	overlay.draw_circle(pos, CIRCLE_RADIUS - STROKE_RADIUS, FILL_COLOR)

func draw_rect(rect: Rect2, c : Color, f : bool, overlay: Control) -> void:
	
	var transform_viewport := map_editor.get_viewport_transform()
	var transform_global := map_editor.get_canvas_transform()
	
	var rect_pos: Vector2 = transform_viewport * (transform_global * rect.position)
	var rect_br: Vector2 = transform_viewport * (transform_global * (rect.position + rect.size))
	var rect_size: Vector2 = Vector2(rect_br - rect_pos) - Vector2(1, 1)
	
	overlay.draw_rect(Rect2(rect_pos, rect_size), c, f)

func drag_to(event_position: Vector2) -> void:
	if not dragged_anchor:
		return
	
	var cr = map_editor.current_room
# warning-ignore:unused_variable
	var pos = map.map_data[cr][0].position
# warning-ignore:unused_variable
	var size = map.map_data[cr][0].size
	
	
#	# Calculate the position of the mouse cursor relative to the RectExtents' center
#	var viewport_transform_inv := map_editor.get_viewport().get_global_canvas_transform().affine_inverse()
#	var viewport_position: Vector2 = viewport_transform_inv.xform(event_position)
#	var transform_inv := map_editor.get_global_transform().affine_inverse()
#	var target_position: Vector2 = transform_inv.xform(viewport_position.round())
	var target_position = viewport_to_world(event_position)
	
	target_position.x = 16.0 * round(target_position.x / 16.0)
	target_position.y = 16.0 * round(target_position.y / 16.0)
	
	if dragged_anchor["type"] == "Pos":
		map.map_data[cr][0] = Rect2(target_position, map.map_data[cr][0].size)
	else:
		map.map_data[cr][0] = Rect2(map.map_data[cr][0].position, target_position - map.map_data[cr][0].position)
		if map.map_data[cr][0].size.x < 512:
			map.map_data[cr][0].size.x = 512
		if map.map_data[cr][0].size.y < 288:
			map.map_data[cr][0].size.y = 288

func viewport_to_world(value):
	# Calculate the position of the mouse cursor relative to the RectExtents' center
	var viewport_transform_inv := map_editor.get_viewport().get_global_canvas_transform().affine_inverse()
	var viewport_position: Vector2 = viewport_transform_inv.xform(value)
	var transform_inv := map_editor.get_global_transform().affine_inverse()
	var target_position: Vector2 = transform_inv.xform(viewport_position.round())
	
	return target_position

func forward_canvas_gui_input(event: InputEvent) -> bool:
	if not map_editor or not map_editor.visible:
		return false
	#var cr = map_editor.current_room
	if not map.map_data.has(map_editor.current_room):
		print("DONT HAVE IT 174")
		return false
	
	#var pos = map.map_data[cr][0].position
	#var size = map.map_data[cr][0].size
#	# Clicking and releasing the click
	if event is InputEventMouseButton and event.button_index == BUTTON_MIDDLE and Input.is_key_pressed(16777237) and Input.is_key_pressed(88):
		for i in map.map_data:
			if not map.map_data[i][0].has_point(viewport_to_world(event.position)):
				continue
			map.map_data.erase(i)
			print("Found Room: " + str(i))
			return true
	# Clicking and releasing the click
	if event is InputEventMouseButton and event.button_index == BUTTON_MIDDLE and Input.is_key_pressed(16777237):
		
		if not dragged_anchor and event.is_pressed():
			print("Searching for Anchor")
			for anchor in anchors:
				if not anchor['rect'].has_point(event.position):
					continue
				dragged_anchor = anchor
#				print("Drag start: %s" % dragged_anchor)
#				rect_drag_start = {
#					'position': pos,
#					'size': size,
#				}
			if not dragged_anchor:
				
				var pos = viewport_to_world(event.position)
				
				if map.room_contains_position(pos):
					map_editor.current_room = map.position_to_room(pos)
				else:
					var target_position = viewport_to_world(event.position)
					target_position.x = 16.0 * round(target_position.x / 16.0)
					target_position.y = 16.0 * round(target_position.y / 16.0)
					var name = "New_Room" + str(randi())
					map.add_room(str(name), target_position, Vector2(512, 288))
					map_editor.current_room = name
				
#
#
#				print("Searching for Room")
#				var found_room = false
#				for i in map.map_data:
#					if not map.map_data[i][0].has_point(viewport_to_world(event.position)):
#						continue
#					found_room = true
#					map_editor.current_room = i
#					print("Found Room: " + str(i))
#				if not found_room:
#					var target_position = viewport_to_world(event.position)
#					target_position.x = 16.0 * round(target_position.x / 16.0)
#					target_position.y = 16.0 * round(target_position.y / 16.0)
#					var name = "New_Room" + str(randi())
#					map.add_room(str(name), target_position, Vector2(512, 288))
#					map_editor.current_room = name

			return true
		elif dragged_anchor and not event.is_pressed():
			drag_to(event.position)
			dragged_anchor = {}
			return true
		
	if not dragged_anchor:
		return false
#	# Dragging
	if event is InputEventMouseMotion:
		drag_to(event.position)
# warning-ignore:return_value_discarded
		update_overlays()
		return true
#	# Cancelling with ui_cancel
#	if event.is_action_pressed("ui_cancel"):
#		dragged_anchor = {}
#
#		return true
	return false
