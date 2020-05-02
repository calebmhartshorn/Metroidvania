extends KinematicBody2D

var gravity = 14.6666
var speed = 70
var jump_vel = 200
var slip = 43
var wall_jump_cooldown_limit = 0.2
var ray_length = 5
var smash_vel = 600

var jump_cooldown = 0
var vel = Vector2()
var crouch = false
var last_jump_x = 0
var wall_slide = false
var ledge_hang = false
var wall_jump_cooldown = 0

onready var anim = get_node("Sprite/AnimationPlayer")
onready var sprite = get_node("Sprite")
onready var ray_top = get_node("Ray_Top")
onready var ray_bottom = get_node("Ray_Bottom")
onready var ray_down = get_node("Ray_Down")
onready var ray_mid = get_node("Ray_Mid")
onready var ray_right = get_node("Ray_Right")

func _ready():
	anim.connect("animation_finished", self, "playNextAnim")

func get_input():
	
	# Right
	if Input.is_action_pressed('ui_right') and (wall_jump_cooldown > wall_jump_cooldown_limit or sprite.flip_h == false):
		
		# Crouch Turn Right
		if crouch:
			if sprite.flip_h == true:
				sprite.set_flip_h(false)
				if  anim.get_assigned_animation() != "Crouch_Turn":
					anim.play("Crouch_Turn", -1, 2.0)
					anim.queue("Crouch")
			# Stand up
			elif anim.get_current_animation() == "Crouch":
				crouch = false
				anim.play("Crouch_Transition")
				anim.queue("Run 2")
		
		# Run Right
		else:
			if wall_jump_cooldown > wall_jump_cooldown_limit or sprite.flip_h == false:
				vel.x += speed * max(0.5,Input.get_action_strength("ui_right"))# * wall_jump_cooldown
				
				anim.set_speed_scale(max(0.5,Input.get_action_strength("ui_right")))
				ray_top.set_cast_to(Vector2(ray_length, 0))
				ray_bottom.set_cast_to(Vector2(ray_length, 0))
				ray_mid.set_cast_to(Vector2(ray_length, 0))
			if sprite.flip_h == true and wall_jump_cooldown > wall_jump_cooldown_limit:

				sprite.set_flip_h(false)
				if anim.get_assigned_animation() != "Jump" and anim.get_assigned_animation() != "Turn" and anim.get_assigned_animation() != "Jump_Crouch":
					anim.play("Turn", -1, 2.0)
	
	# Left
	if Input.is_action_pressed('ui_left') and (wall_jump_cooldown > wall_jump_cooldown_limit or sprite.flip_h == true):
		
		# Crouch Turn Left
		if crouch:
			if sprite.flip_h == false:
				sprite.set_flip_h(true)
				if  anim.get_assigned_animation() != "Crouch_Turn":
					anim.play("Crouch_Turn", -1, 2.0)
					anim.queue("Crouch")
			# Stand Up
			elif anim.get_current_animation() == "Crouch":
				crouch = false
				anim.play("Crouch_Transition")
				anim.queue("Run 2")
		
		# Run Left
		else:
			#if is_on_floor():
			if wall_jump_cooldown > wall_jump_cooldown_limit or sprite.flip_h == true:
				vel.x -= speed * max(0.5,Input.get_action_strength("ui_left"))# * wall_jump_cooldown
				anim.set_speed_scale(max(0.5,Input.get_action_strength("ui_left")))
				ray_top.set_cast_to(Vector2(-ray_length, 0))
				ray_bottom.set_cast_to(Vector2(-ray_length, 0))
				ray_mid.set_cast_to(Vector2(-ray_length, 0))
			if sprite.flip_h == false and wall_jump_cooldown > wall_jump_cooldown_limit:
				sprite.set_flip_h(true)
				if anim.get_assigned_animation() != "Jump" and anim.get_assigned_animation() != "Turn" and anim.get_assigned_animation() != "Jump_Crouch":
					anim.play("Turn", -1, 2.0)
	
	# Jump
	if Input.is_action_just_pressed('jump'):
		if (is_on_floor()):
			crouch = false
			if (anim.get_assigned_animation() != "Jump_Crouch"):
				anim.play("Jump_Crouch")
			last_jump_x = position.x
		
		elif Input.is_action_pressed("ui_down"):
			vel.x = 0
			vel.y = smash_vel
		
		elif wall_slide or ledge_hang:
			wall_slide = false
			ledge_hang = false
			vel.y = -jump_vel * 1.7
			if ray_right.is_colliding():
				vel.x = -jump_vel * 3
				sprite.set_flip_h(true)
			else:
				vel.x = jump_vel * 3
				sprite.set_flip_h(false)
			anim.play("Jump")
			last_jump_x = position.x
			
			ray_top.set_cast_to(Vector2(-1 * ray_top.get_cast_to().x, 0))
			ray_bottom.set_cast_to(Vector2(-1 * ray_bottom.get_cast_to().x, 0))
			ray_mid.set_cast_to(Vector2(-1 * ray_mid.get_cast_to().x, 0))
			
			wall_jump_cooldown = 0
	
	# Long Jump
	if Input.is_action_pressed("jump"):
		vel.y += -jump_vel * jump_cooldown
	
	if is_on_floor() and round(vel.y) >= 0.0:
		# Run
		if (Input.is_action_pressed('ui_right') or Input.is_action_pressed('ui_left')) and (not crouch) and anim.assigned_animation != "Jump" and anim.assigned_animation != "Jump_Crouch":
			anim.queue("Run 2")
		else:
			
			# Crouch Down
			if Input.is_action_just_pressed("ui_down") and not crouch:
				crouch = true;
				anim.play("Crouch_Transition", -1, 2)
			
			# Stand Up
			if Input.is_action_just_pressed("ui_up") and crouch:
				crouch = false
				anim.play("Crouch_Transition", -1, 2)
			
			# Crouch Idle
			if crouch:
				anim.queue("Crouch")
			
			# Idle
			else:
				if anim.assigned_animation != "Crouch_Transition" and anim.assigned_animation != "Jump_Crouch":# and anim.assigned_animation != "Jump":
					anim.play("Idle")
					wall_slide = false	
	else:
		if anim.assigned_animation != "Fall" and wall_slide == false and vel.y > 0: 
			anim.play("Fall")

# Transition Animations
func playNextAnim(finished):
	if(finished == "Crouch_Transition" and crouch == false):
		anim.play("Idle")
	if(finished == "Jump_Crouch"):
		anim.play("Jump")
		jump_cooldown = 1
		vel.y = -jump_vel;



func _physics_process(delta):
	jump_cooldown = max(0, jump_cooldown * 27 * delta)
	wall_jump_cooldown += delta
	
	get_input()
	
	vel.x *= 0.71666 #slip * delta
	
	if wall_slide:
		vel.y += gravity  * 0.1
	elif ledge_hang:
		pass
	else:
		vel.y += gravity 
	
	var _move = move_and_slide(vel, Vector2(0, -1))
	
	# Wall Slide
	if  (not is_on_floor()) and ray_top.is_colliding() and ray_bottom.is_colliding() and (not ray_down.is_colliding()):
		if abs(position.x - last_jump_x) > 8:
			anim.play("Wall_Hang")
			last_jump_x = position.x
			vel.y=0
			vel.x = 0
			wall_slide = true
			
			if ray_right.is_colliding():
				sprite.set_flip_h(false)
				position.x = 16 * floor(position.x / 16) + 8 + 4
			else:
				sprite.set_flip_h(true)
				position.x = 16 * floor(position.x / 16) + 8 - 4
	else:
		wall_slide = false
	
	#Ledge Grab
	if (not is_on_floor()) and (not ray_top.is_colliding()) and ray_mid.is_colliding() and wall_jump_cooldown > 0.1  and (not ray_down.is_colliding()):
		
		anim.play("Ledge_Hang")
		vel.y=0
		vel.x = 0
		ledge_hang = true
		
		if ray_right.is_colliding():
			sprite.set_flip_h(false)
			position.x = 16 * floor(position.x / 16) + 8 + 4
		else:
			sprite.set_flip_h(true)
			position.x = 16 * floor(position.x / 16) + 8 - 4
		
		position.y = 16 * ceil((position.y + 9) / 16) - 9 - 5
	else:
		ledge_hang = false
	if (is_on_floor() or is_on_ceiling()):
		vel.y = 0

