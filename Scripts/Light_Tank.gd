extends Light2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("AnimationPlayer").advance(rand_range(0, 2))
	var _ignore = get_node("VisibilityNotifier2D").connect("screen_exited", self, "_on_screen_exited")
	var _ignore2 = get_node("VisibilityNotifier2D").connect("screen_entered", self, "_on_screen_entered")

func _on_screen_exited():
	set_enabled(false)
func _on_screen_entered():
	set_enabled(true)
