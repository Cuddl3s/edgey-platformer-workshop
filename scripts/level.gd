extends Node2D

@onready var start = get_tree().get_first_node_in_group("start")
@onready var hurt_player = $AudioStreamPlayer
var hurt_sound = preload("res://assets/audio/hurt.wav")
var player = null

func _ready():
	player = get_tree().get_first_node_in_group("player")
	if player!=null:
		player.global_position = start.get_spawn_position()
	var traps = get_tree().get_nodes_in_group("traps")
	for trap in traps:
		trap.touched_player.connect(_on_trap_touched_player)
	var deathzones = get_tree().get_nodes_in_group("deathzone")
	for deathzone in deathzones:
		if deathzone is Area2D:
			deathzone.body_entered.connect(_on_death_zone_body_entered)
	

func _process(delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()


func _on_death_zone_body_entered(body):
	hurt_player.play()
	reset_player()

func _on_trap_touched_player():
	hurt_player.play()
	reset_player()

func reset_player():
	player.global_position = start.get_spawn_position()
	player.velocity = Vector2.ZERO
