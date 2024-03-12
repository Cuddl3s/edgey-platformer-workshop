extends Area2D

@onready var animation = $AnimatedSprite2D
@onready var particles = $Particles
@onready var audio_player = $AudioStreamPlayer

func animate():
	animation.play("default")
	particles.emitting = true


func _on_body_entered(body):
	animate()
	body.freeze()
	audio_player.play()
	audio_player.finished.connect(func(): get_tree().reload_current_scene())
	
