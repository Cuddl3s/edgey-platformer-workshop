extends CharacterBody2D
class_name Player

@onready var animated_sprite = $AnimatedSprite2D

@export_group("Physics")
@export var gravity = 400 								# downward acceleration per second
@export var acceleration = 200 							# added speed per second
@export var max_run_speed = 125 						# maximum speed
@export var jump_force = 200 							# upward force on jump
@export_range(0, 1, 0.01) var friction = .98 			# how much velocity remains each frame when we have no input
@export_range(0, 1, 0.1) var jump_released_adjust = .6 	# the lower the value, the more "variable" the jump height
@export_range(0, 1, 0.01) var air_control = .5 			# amount of air control (1 = full control in air)

func _physics_process(delta):		
	if Input.is_action_just_pressed("jump") && is_on_floor():
		jump(jump_force)
	if Input.is_action_just_released("jump") && velocity.y < 0:
		velocity.y *= jump_released_adjust
		
	var direction = Input.get_axis("left", "right")
	
	if direction != 0:
		animated_sprite.flip_h = direction == -1
	else:
		velocity.x *= friction
		
	var added_speed = direction * acceleration * delta
	var air_adjusted_acceleration = added_speed * (1 if is_on_floor() else air_control)
	var new_speed = clamp(velocity.x + air_adjusted_acceleration, -max_run_speed, max_run_speed)
	if abs(new_speed) < .1:
		new_speed = 0
	
	velocity.x = new_speed
	
	# Gravity
	if !is_on_floor():
		velocity.y += gravity*delta
		
	move_and_slide()
	update_animations(direction)
	
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
	velocity.y = -force
