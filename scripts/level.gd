extends Node2D

var start: Node = null
var exit: Exit = null
@onready var hurt_player = $AudioStreamPlayer
@onready var win_player = $WinAudio
var hurt_sound = preload("res://assets/audio/hurt.wav")
var player = null
@export var levels: Array[PackedScene]
var current_level_index = 0
var current_level: Node = null
var times: Array[int] = []
@export var enable_music = true

@onready var timer: TimeLabel = $CanvasLayer/Control/Time
var timer_scene = preload("res://scenes/timer_label.tscn")
var total_time = 0

func _ready():
	init_level()	
	
func init_level():
	if current_level_index >= levels.size() || current_level != null:
		#Game Over
		prepare_game_over_screen()
		return
	current_level = levels[current_level_index].instantiate()
	add_child(current_level)
	start = get_tree().get_first_node_in_group("start")
	exit = get_tree().get_first_node_in_group("exit")
	exit.on_win.connect(on_win)
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
	timer.start()
	if enable_music: $BGMusicPlayer.play()
	
func create_time_label_with_time(time: int):
	var time_label: TimeLabel = timer_scene.instantiate()
	time_label.set_time(time)
	total_time += time
	return time_label

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
	

func on_win():
	timer.stop()
	times.append(timer.get_time())
	win_player.play()
	await win_player.finished
	next_level()
	
	
func next_level():
	timer.reset()
	current_level_index += 1
	remove_child(current_level)
	current_level.queue_free()
	current_level = null
	init_level()

func reset_player():
	timer.reset()
	player.global_position = start.get_spawn_position()
	player.velocity = Vector2.ZERO
	
func prepare_game_over_screen():
	$BGMusicPlayer.stop()
	win_player.play()
	$ThankYou.visible = true
	timer.visible = false
	times.map(create_time_label_with_time).map($ThankYou/MarginContainer/VBoxContainer.add_child)
	$ThankYou/MarginContainer/VBoxContainer.add_child(HSeparator.new())
	$ThankYou/MarginContainer/VBoxContainer.add_child(create_time_label_with_time(total_time))
