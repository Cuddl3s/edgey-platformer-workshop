extends Label
class_name TimeLabel

var frame = 0
var ms_since_start = 0
var running = false

func start():
	running = true

func stop():
	running = false
	
func reset():
	ms_since_start = 0
	
func _physics_process(delta):
	if running: 
		update_time(delta)

func update_time(delta: float):
	ms_since_start += floori(delta * 1000)
	var ms_total = ms_since_start
	var s = ms_total / 1000
	var ms = ms_total % 1000
	var m = ms_total / 60000
	
	var m_string = pad_with_zeros(m, 2)
	var s_string = pad_with_zeros(s, 2)
	var ms_string = pad_with_zeros(ms, 3)
	text = m_string + ":" + s_string + ":" + ms_string
	
func pad_with_zeros(val: int, zeros: int) -> String:
	var zerostring = "000000000000000000000".substr(0,zeros-1)
	var string = zerostring + str(val)
	return string.substr(string.length()-zeros,-1)
	
func set_time(time: int):
	ms_since_start = time
	update_time(0.0)
	
func get_time():
	return ms_since_start
	
