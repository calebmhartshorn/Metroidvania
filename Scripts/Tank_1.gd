extends Sprite

func _ready():

	get_node("AnimationPlayer").play("Bubbles", -1, 0.7)
	get_node("AnimationPlayer").advance(rand_range(0, 2))
