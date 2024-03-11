extends Area2D

@onready var animation = $AnimatedSprite2D
@onready var particles = $Particles

func animate():
	animation.play("default")
	particles.emitting = true


func _on_body_entered(body):
	animate()
