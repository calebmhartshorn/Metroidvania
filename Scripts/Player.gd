extends KinematicBody2D

var gravity = 14.6666
var speed = 50#70
var jump_vel = 370#200
var slip = 43
var wall_jump_cooldown_limit = 0.2
var ray_length = 5
var smash_vel = 600

#var jump_cooldown = 0
var vel = Vector2()
var crouch = false
var last_jump_x = 0
var wall_slide = false
var ledge_hang = false
var wall_jump_cooldown = 0
var jump_grace_timer = 0
var jump_grace = 0.06
var shoot_cooldown = 0

onready var anim = get_node("Sprite/AnimationPlayer")
onready var sprite = get_node("Sprite")
onready var ray_top = get_node("Ray_Top")
onready var ray_bottom = get_node("Ray_Bottom")
onready var ray_down = get_node("Ray_Down")
onready var ray_mid = get_node("Ray_Mid")
onready var ray_right = get_node("Ray_Right")
onready var ray_down_long = get_node("Ray_Down_Long")

var Laser = preload("res://Scenes/Laser.tscn")

func _ready():
	anim.connect("animation_finished", self, "playNextAnim")

func get_input():
	
	if Input.is_action_just_pressed("respawn"):
		position = Vector2(256,88)
	
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
	
	if ledge_hang and Input.is_action_pressed("ui_up"):
		anim.play("Climb")
		ledge_hang = false
	
	# Jump
	if Input.is_action_just_pressed('jump'):
		if (is_on_floor() or jump_grace_timer < jump_grace):
			
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
			vel.y = -jump_vel * 0.91#1.7
			if ray_right.is_colliding():
				vel.x = -jump_vel * 1.6#3
				sprite.set_flip_h(true)
			else:
				vel.x = jump_vel * 1.6#3
				sprite.set_flip_h(false)
			anim.play("Jump")
			last_jump_x = position.x
			
			ray_top.set_cast_to(Vector2(-1 * ray_top.get_cast_to().x, 0))
			ray_bottom.set_cast_to(Vector2(-1 * ray_bottom.get_cast_to().x, 0))
			ray_mid.set_cast_to(Vector2(-1 * ray_mid.get_cast_to().x, 0))
			
			wall_jump_cooldown = 0
	
	# Long Jump
	#if Input.is_action_pressed("jump"):
	#	pass# vel.y += -jump_vel * jump_cooldown
		
	if (not Input.is_action_pressed("jump")) and vel.y < 0 :
		vel.y *= 0.95
	
	if Input.is_action_just_pressed("Shoot") and shoot_cooldown > .15:
		shoot_cooldown = 0
		get_node("AudioStreamPlayer").play()
		var node = Laser.instance()
		# Camera shake
		if sprite.flip_h:
			get_node("../CameraAnchor").pos.x -= 3
			node.position.x = position.x - 16
			node.flip_h = true
		else:
			get_node("../CameraAnchor").pos.x += 3
			node.position.x = position.x + 16
		if crouch:
			node.position.y = position.y + 10
		else:
			node.position.y = position.y - 6
		get_node('../Bullets').add_child(node)
	
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
		if anim.assigned_animation != "Fall" and wall_slide == false and vel.y > 0 and jump_grace_timer > jump_grace: 
			anim.play("Fall")

# Transition Animations
func playNextAnim(finished):
	if(finished == "Crouch_Transition" and crouch == false):
		anim.play("Idle")
	if(finished == "Jump_Crouch"):
		anim.play("Jump")
		#jump_cooldown = 1
		vel.y = -jump_vel;



func _physics_process(delta):
	#jump_cooldown = max(0, jump_cooldown * 27 * delta)
	wall_jump_cooldown += delta
	shoot_cooldown += delta
	
	if is_on_floor():
		jump_grace_timer = 0
	else:
		jump_grace_timer += delta
	
	get_input()
	
	if(Input.is_action_pressed('ui_right') or Input.is_action_pressed('ui_left')):
		vel.x *= 0.8#0.71666
	else:
		vel.x *= 0.5 #slip * delta
	
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
				#position.x = 16 * floor(position.x / 16) + 8 + 4
				position.x = 16 * floor(position.x / 16) + 8 + 4
			else:
				sprite.set_flip_h(true)
				#position.x = 16 * floor(position.x / 16) + 8 - 4
				position.x = 16 * floor(position.x / 16) + 8 - 4
	else:
		wall_slide = false
	
	#Ledge Grab
	if (not is_on_floor()) and (not ray_top.is_colliding()) and ray_mid.is_colliding() and wall_jump_cooldown > 0.1 and anim.assigned_animation != "Climb":
		if (not ray_down_long.is_colliding()):
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

