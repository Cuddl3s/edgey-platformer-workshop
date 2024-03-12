extends Area2D
class_name Exit

@onready var animation = $AnimatedSprite2D
@onready var particles = $Particles

signal on_win

func animate():
	animation.play("default")
	particles.emitting = true


func _on_body_entered(body):
	animate()
	body.freeze()
	on_win.emit()
	
