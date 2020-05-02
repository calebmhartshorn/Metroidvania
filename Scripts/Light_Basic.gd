extends Light2D

func _ready():
	get_node("VisibilityNotifier2D").connect("screen_exited", self, "_on_screen_exited")
	get_node("VisibilityNotifier2D").connect("screen_entered", self, "_on_screen_entered")

func _on_screen_exited():
	set_enabled(false)
func _on_screen_entered():
	set_enabled(true)
