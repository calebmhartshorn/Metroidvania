extends KinematicBody2D

#===================#
#   - Constants -   #
#===================#

# px/sec
const gravity = 880
const jump_vel = 370
const max_speed = 180
const accel = 800
const decel = 1200

# sec
const wall_jump_immobility_time = 0.2
const coyote_time = 0.06
const turn_time = 0.075
const shoot_time = 0.15

# px 
const ray_length = 5

# state
enum states {IDLE, RUN, JUMP, FALL, CROUCH, SLIDE, HANG}
enum        {IDLE, RUN, JUMP, FALL, CROUCH, SLIDE, HANG}

# node
onready var anim = get_node("Sprite/AnimationPlayer")
onready var sprite = get_node("Sprite")
onready var ray_top = get_node("Rays/Ray_Top")
onready var ray_bottom = get_node("Rays/Ray_Bottom")
onready var ray_down = get_node("Rays/Ray_Down")
onready var ray_mid = get_node("Rays/Ray_Mid")
onready var ray_right = get_node("Rays/Ray_Right")
onready var ray_down_long = get_node("Rays/Ray_Down_Long")

# scene
const Laser = preload("res://Scenes/Laser.tscn")

#===================#
#   - Variables -   #
#===================#

var vel = Vector2()

# sec
var wall_jump_immobility_timer = 0
var shoot_timer = 0
var coyote_timer = 0
var turn_timer = 0

# state
var state = IDLE
var saved_state = IDLE
var last_jump_x = 0

func _ready():
	anim.connect("animation_finished", self, "play_next_anim")
	
	for i in $Rays.get_children():
		i.add_exception(self)

func _physics_process(delta):
	
	manage_states(delta)
	
	# Decelerate
	if not (Input.is_action_pressed('ui_right') or Input.is_action_pressed('ui_left')):
		if vel.x > 0:
			vel.x = max(0, vel.x - decel * delta)
		else:
			vel.x = min(0, vel.x + decel * delta)
	if Input.is_action_pressed('ui_right') and vel.x < 0:
		vel.x += decel * delta
	if Input.is_action_pressed('ui_left') and vel.x > 0:
		vel.x -= decel * delta
	
	# Move
	var _move = move_and_slide(vel, Vector2(0, -1))
	
	if (is_on_floor() or is_on_ceiling()):
		vel.y = 0
	
	# Gravity
	if state == SLIDE:
		vel.y += 0.1 * gravity * delta
	elif state == HANG:
		pass
	else:
		vel.y += gravity * delta
	
	# Timers
	if is_on_floor():
		coyote_timer = 0
	else:
		coyote_timer += delta
	
	shoot_timer += delta
	wall_jump_immobility_timer += delta
	
		# Test Stuff
	if Input.is_action_just_pressed("respawn"):
		position = Vector2(256,88)
	#$CanvasLayer/Label.set_text("State: " + str(states.keys()[state]))

func manage_states(delta):
	
	if is_on_floor():
		last_jump_x = 9999999999
	
	# Fall
	if vel.y > 0 and (not is_on_floor()) and not state in [FALL, SLIDE, HANG]:
		state = FALL
		anim.play("Fall")
		anim.advance(0.05)
	
	# Shoot
	if Input.is_action_just_pressed("Shoot") and shoot_timer > shoot_time and not state in [SLIDE, HANG]:
		shoot_timer = 0
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
		if state == CROUCH:
			node.position.y = position.y + 10
		else:
			node.position.y = position.y - 7
		get_node('../Bullets').add_child(node)
		
		# Vibration
		Input.start_joy_vibration(0, 0.15, 0, 0.2)
		get_node('../UI/TextureRect').get_material().set_shader_param("Flip", true)
	
	# Wall Slide
	if  (not is_on_floor()) and ray_top.is_colliding() and ray_bottom.is_colliding() and (not ray_down.is_colliding()) and (not state in [HANG]):
		if abs(position.x - last_jump_x) > 8:
			anim.play("Slide")
			last_jump_x = position.x
			vel.y=0
			vel.x = 0
			state = SLIDE
			if ray_right.is_colliding():
				flip_rays(1)
				sprite.set_flip_h(false)
				position.x = 16 * floor(position.x / 16) + 8 + 4
			else:
				flip_rays(-1)
				sprite.set_flip_h(true)
				position.x = 16 * floor(position.x / 16) + 8 - 4
	
	# Ledge Grab
	if (not is_on_floor()) and (not ray_top.is_colliding()) and ray_mid.is_colliding() and (not ray_down_long.is_colliding()) and wall_jump_immobility_timer > 0.1:
		if (vel.x > 0 and Input.is_action_pressed("ui_right")) or (vel.x < 0 and Input.is_action_pressed("ui_left")):
			
			# Snap
			var old_pos = position
			while not ray_top.is_colliding():
				position.y += 1
				ray_top.force_raycast_update()
			position.y -= 6
			
			if old_pos.y < position.y:
				position.y = old_pos.y
			else:
				vel.y=0
				anim.play("Hang")
				vel.x = 0
				state = HANG
				if ray_right.is_colliding():
					sprite.set_flip_h(false)
					position.x = 16 * floor(position.x / 16) + 8 + 4
				else:
					sprite.set_flip_h(true)
					position.x = 16 * floor(position.x / 16) + 8 - 4
	
	match state:
		IDLE:
			
			# Run
			if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
				
				state = RUN
				anim.play("Run 2")
			
			# Jump
			if Input.is_action_just_pressed('jump'):
				
				# TODO: Jump Input Buffer
				if (coyote_timer < coyote_time):
					state = JUMP
					last_jump_x = position.x
					vel.y = -jump_vel
					anim.play("Jump")
			
			# Crouch
			if Input.is_action_just_pressed("ui_down"):
				
				state = CROUCH;
				anim.play("Crouch_Transition", -1, 2)
				anim.queue("Crouch")
		
		RUN:
			
			# Idle
			if not (Input.is_action_pressed("ui_left") or Input.is_action_pressed('ui_right')):
				
				turn_timer += delta
				if turn_timer > turn_time:
					state = IDLE
					anim.play("Idle")
					return
			else:
				turn_timer = 0
			
			# Run
			if Input.is_action_pressed("ui_left"):
				
				vel.x = max(-max_speed, vel.x - accel * delta)
				
				# Turn anim
				if not sprite.flip_h:
					sprite.flip_h = true
					flip_rays(-1)
					anim.play("Turn")
			if Input.is_action_pressed("ui_right"):
				
				vel.x = min(max_speed, vel.x + accel * delta)
				
				# Turn anim
				if sprite.flip_h:
					sprite.flip_h = false
					flip_rays(1)
					anim.play("Turn")
			
			# Jump
			if Input.is_action_just_pressed('jump'):
				
				# TODO: Jump Input Buffer
				if (coyote_timer < coyote_time):
					state = JUMP
					last_jump_x = position.x
					vel.y = -jump_vel
					anim.play("Jump")
		
		FALL:
			
			# Land
			if is_on_floor():
				if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
					
					state = RUN
					anim.play("Run 2")
				else:
					
					state = IDLE
					anim.play("Idle")
			
			# Run
			if Input.is_action_pressed("ui_left"):
				
				vel.x = max(-max_speed, vel.x - accel * delta)
				
				# Turn anim
				if not sprite.flip_h:
					sprite.flip_h = true
					flip_rays(-1)
					#anim.play("Turn")
			if Input.is_action_pressed("ui_right"):
				
				vel.x = min(max_speed, vel.x + accel * delta)
				
				# Turn anim
				if sprite.flip_h:
					sprite.flip_h = false
					flip_rays(1)
					#anim.play("Turn")
			
			# Jump
			if Input.is_action_just_pressed('jump'):
				
				# TODO: Jump Input Buffer
				if (coyote_timer < coyote_time):
					state = JUMP
					last_jump_x = position.x
					anim.play("Jump")
					vel.y = -jump_vel
		
		JUMP:
			
			# Run
			if Input.is_action_pressed("ui_left") and wall_jump_immobility_timer > wall_jump_immobility_time:
				
				vel.x = max(-max_speed, vel.x - accel * delta)
				
				# Turn anim
				if not sprite.flip_h:
					sprite.flip_h = true
					flip_rays(-1)
					anim.play("Turn")
			if Input.is_action_pressed("ui_right") and wall_jump_immobility_timer > wall_jump_immobility_time:
				
				vel.x = min(max_speed, vel.x + accel * delta)
				
				# Turn anim
				if sprite.flip_h:
					sprite.flip_h = false
					flip_rays(1)
					anim.play("Turn")
			
			# Shorten Jump
			if not Input.is_action_pressed("jump"):
				vel.y *= 0.9
		
		CROUCH:
			
			# Run
			if Input.is_action_pressed("ui_left") or Input.is_action_pressed('ui_right'):
				
				turn_timer += delta
				if turn_timer > turn_time * 2:
					state = RUN
					anim.play("Crouch_Transition")
					return
				else:
					# Turn left
					if Input.is_action_pressed("ui_left"):
						if not sprite.flip_h:
							sprite.flip_h = true
							flip_rays(-1)
							anim.play("Crouch_Turn")
					# Turn right
					else:
						if sprite.flip_h:
							sprite.flip_h = false
							flip_rays(1)
							anim.play("Crouch_Turn")
			else:
				turn_timer = 0
			
			# Stand
			if Input.is_action_pressed("ui_up"):
				state = IDLE
				anim.play("Crouch_Transition")
			
			# Jump
			if Input.is_action_just_pressed('jump'):
				
				# TODO: Jump Input Buffer
				if (coyote_timer < coyote_time):
					state = JUMP
					last_jump_x = position.x
					vel.y = -jump_vel
					anim.play("Crouch_Transition")
		
		SLIDE:
			
			# Fall
			if  not((not is_on_floor()) and ray_top.is_colliding() and ray_bottom.is_colliding() and (not ray_down.is_colliding())):
				state = FALL
				anim.play("Fall")
			
			# Jump
			if Input.is_action_just_pressed("jump"):
				
				vel.y = -jump_vel * 0.91
				if ray_right.is_colliding():
					vel.x = -jump_vel * 0.5
					flip_rays(-1)
					sprite.set_flip_h(true)
				else:
					vel.x = jump_vel * 0.5
					flip_rays(1)
					sprite.set_flip_h(false)
				
				last_jump_x = position.x
				wall_jump_immobility_timer = 0
				state = JUMP
				anim.play("Jump")
		
		HANG:
			
			# Jump
			if Input.is_action_just_pressed("jump"):
				
				vel.y = -jump_vel * 0.91
				if ray_right.is_colliding():
					vel.x = -jump_vel * 0.5
					flip_rays(-1)
					sprite.set_flip_h(true)
				else:
					vel.x = jump_vel * 0.5
					flip_rays(1)
					sprite.set_flip_h(false)
				
				last_jump_x = position.x
				wall_jump_immobility_timer = 0
				state = JUMP
				anim.play("Jump")

func play_next_anim(finished):
	
	match finished:
		"Crouch_Transition":
			if state == IDLE:
				anim.play("Idle")
			elif state == RUN:
				anim.play("Run 2")
			elif state == JUMP:
				anim.play("Jump")
		"Turn":
			if state == IDLE:
				anim.play("Idle")
			elif state == RUN:
				anim.play("Run 2")
			elif state == JUMP:
				anim.play("Jump")
				anim.advance(0.05)
		"Crouch_Turn":
			anim.play("Crouch")

func flip_rays(value):
	ray_top.set_cast_to(Vector2(value * ray_length, 0))
	ray_bottom.set_cast_to(Vector2(value * ray_length, 0))
	ray_mid.set_cast_to(Vector2(value * ray_length, 0))
