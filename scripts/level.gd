extends Node2D

@onready var start = $Objects/Start
var player = null

func _ready():
	player = get_tree().get_first_node_in_group("player")
	if player!=null:
		player.global_position = start.get_spawn_position()
	var traps = get_tree().get_nodes_in_group("traps")
	for trap in traps:
		trap.touched_player.connect(_on_trap_touched_player)
	

func _process(delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()


func _on_death_zone_body_entered(body):
	reset_player()


func _on_trap_touched_player():
	reset_player()

func reset_player():
	player.global_position = start.get_spawn_position()
	player.velocity = Vector2.ZERO
