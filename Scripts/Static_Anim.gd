extends Sprite

func _ready():

	get_node("AnimationPlayer").play("Anim")
	get_node("AnimationPlayer").advance(rand_range(0, 2))
