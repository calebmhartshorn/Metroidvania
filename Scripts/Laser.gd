extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed = 800
var hit = false

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var _ignore = get_node("AnimationPlayer").connect("animation_finished", self, "del")
	var _ignore2 = get_node("VisibilityNotifier2D").connect("screen_exited", self, "_on_screen_exited")
	
	if flip_h:
		get_node("RayCast2D").set_cast_to(Vector2(-15, 0))
		get_node("RayCast2D").position.x = 16
		get_node("Light2D").position.x = 16
	else:
		get_node("RayCast2D").set_cast_to(Vector2(15, 0))
		get_node("RayCast2D").position.x = -16
		get_node("Light2D").position.x = -16
		
	get_node("RayCast2D").add_exception(get_node("../../Player/"))
	get_node("AnimationPlayer").play("Shoot")

func _process(delta):
	
	# Move
	if not hit:
		
		if flip_h:
			position.x -= speed * delta
		else:
			position.x += speed * delta
	
	# First Check
	if get_node("RayCast2D").is_colliding():
		hit = true
		if flip_h:
			position.x = 16 * ceil(position.x / 16)
		else:
			position.x = 16 * floor(position.x / 16)
		
		get_node("RayCast2D").force_raycast_update()
		
		# Second Check
		if get_node("RayCast2D").is_colliding():
			if flip_h:
				position.x += 16
			else:
				position.x -= 16
		
		get_node("AnimationPlayer").play("Explode", -1, 2.5)

func _on_screen_exited():
	queue_free()
	
func del(_finished):
	hide()
	queue_free()
