extends CharacterBody2D
class_name Player

@onready var animated_sprite = $AnimatedSprite2D
@onready var audio_stream_player = $AudioStreamPlayer

@export_group("Physics")
@export var gravity = 400 								## downward acceleration per second
@export var acceleration = 200 							## added speed per second
@export var max_run_speed = 125 						## maximum horizontal speed
@export var jump_force = 200 							## upward force on jump
@export_range(0, 1, 0.01) var friction = .98 			## how much velocity remains each frame when we have no input
@export_range(0, 1, 0.01) var air_friction = .98 		## how much velocity remains each frame when we have no input
@export_range(0, 1, 0.1) var jump_released_adjust = .6 	## the lower the value, the more "variable" the jump height
@export_range(0, 1, 0.01) var air_control = .5 			## amount of air control (1 = full control in air)
@export_group("Feel")
@export var coyote_frames = 5							## number of frames after falling where jumping is possible
var _coyote_frames = 0
@export var jump_buffer_frames = 5						## number of frames a jump will be buffered
var _jump_buffer_frames = 0
@export var squash_and_stretch: bool = false

var _previous_on_floor = true
var _frozen = false
var previous_y = 0.0

func _physics_process(delta):
	# flags
	var _has_landed = !_previous_on_floor && is_on_floor()
	var has_fallen = _previous_on_floor && !is_on_floor() && velocity.y >= 0
	_previous_on_floor = is_on_floor()
	
	handle_coyote_time(has_fallen)
	
	if !_frozen: handle_jump()
	var direction = handle_horizontal_movement(delta)
	
	# Gravity
	if !is_on_floor():
		velocity.y += gravity*delta
		previous_y = velocity.y
	move_and_slide()
	update_animations(direction)
	if squash_and_stretch: do_squash_and_stretch(_has_landed,previous_y, delta)
	
func handle_jump():
	if _jump_buffer_frames > 0:
		_jump_buffer_frames -= 1
	if Input.is_action_just_pressed("jump") && !is_on_floor():
		_jump_buffer_frames = jump_buffer_frames
	if (_jump_buffer_frames > 0 && is_on_floor()) || Input.is_action_just_pressed("jump") && (is_on_floor() || _coyote_frames > 0):
		_jump_buffer_frames = 0
		_coyote_frames = 0
		jump(jump_force)
	if Input.is_action_just_released("jump") && velocity.y < 0:
		velocity.y *= jump_released_adjust

func handle_horizontal_movement(delta) -> int:
	var direction = 0.0 if _frozen else Input.get_axis("left", "right")
	
	if direction != 0:
		animated_sprite.flip_h = direction == -1
	else:
		var used_friction = friction if is_on_floor() else air_friction
		velocity.x *= used_friction
		
	var added_speed = direction * acceleration * delta
	var air_adjusted_acceleration = added_speed * (1.0 if is_on_floor() else air_control)
	var new_speed = clamp(velocity.x + air_adjusted_acceleration, -max_run_speed, max_run_speed)
	if abs(new_speed) < .1:
		new_speed = 0
	
	velocity.x = new_speed
	return direction
	
func handle_coyote_time(has_fallen: bool):
	if _coyote_frames > 0:
		_coyote_frames -= 1
	if has_fallen:
		_coyote_frames = coyote_frames
	
func update_animations(direction):
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		if velocity.y < 0:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("fall")
		
func jump(force):
	audio_stream_player.play()   
	velocity.y = -force
	
func freeze():
	_frozen = true
	
func do_squash_and_stretch(_has_landed, previous_y, delta):
	"""
	-- New Code from this Point --
	If the player is in the air, make scale of sprite
	based on the y motion value using range_lerp
	The fast the y motion, 
	the larger the y stretch, 
	the larger the x squash
	"""
	
	if not is_on_floor():
		$AnimatedSprite2D.scale.y = remap(abs(velocity.y), 0, abs(jump_force), 0.75, 1.5)
		$AnimatedSprite2D.scale.x = remap(abs(velocity.y), 0, abs(jump_force), 1.25, 0.75)
	
	"""
	If there's a floor collision,
	set squashed scale values based on
	previous motion
	"""
	
	if _has_landed:
		print("land squash!")
		print(previous_y)
		$AnimatedSprite2D.scale.x = remap(abs(previous_y), 0, 516.66, 1.2, 2.0)
		$AnimatedSprite2D.scale.y = remap(abs(previous_y), 0, 516.66, 0.8, 0.5)
	
	
	"""
	lerp function eases sprite scale to default position
	See article on using delta with lerp:
		https://www.construct.net/en/blogs/ashleys-blog-2/using-lerp-delta-time-924
	"""
	
	$AnimatedSprite2D.scale.x = lerp($AnimatedSprite2D.scale.x, 1.0, 1 - pow(0.01, delta))
	$AnimatedSprite2D.scale.y = lerp($AnimatedSprite2D.scale.y, 1.0, 1 - pow(0.01, delta))

