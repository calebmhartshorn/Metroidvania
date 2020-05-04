extends Light2D

func _ready():
	var _ignore = get_node("VisibilityNotifier2D").connect("screen_exited", self, "_on_screen_exited")
	var _ignore2 = get_node("VisibilityNotifier2D").connect("screen_entered", self, "_on_screen_entered")

func _on_screen_exited():
	set_enabled(false)
func _on_screen_entered():
	set_enabled(true)
