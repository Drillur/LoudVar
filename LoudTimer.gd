class_name LoudTimer
extends Resource



# Timers are already loud, but this will automate some basic things like
# adding it to the scene tree. Some useful additions are the 'started' signal,
# and the 'get_percent()' and 



signal timeout
signal started
signal wait_time_changed
signal stopped
signal timed_out_or_stopped
signal duration_elapsed_when_stopped(duration)

var timer: Timer
var wait_time: LoudFloat # the number matching timer.wait_time
var running := LoudBool.new(false)
var wait_time_range: LoudFloatPair # a range in which the timer wait_time will be randomly assigned
var random: bool



func _init(_wait_time := 0.0, optional_maximum_duration := 0.0) -> void:
	if optional_maximum_duration > 0.0:
		wait_time_range = LoudFloatPair.new(_wait_time, optional_maximum_duration)
		wait_time = LoudFloat.new(0.0)
		random = true
		randomize()
	else:
		wait_time = LoudFloat.new(_wait_time)
		random = false
	wait_time.changed.connect(wait_time_changed_receiver)
	wait_time.minimum_limit = 0.05
	
	started.connect(running.set_true)
	timed_out_or_stopped.connect(running.set_false)
	
	timer = Timer.new()
	gv.add_child(timer) # You will have to replace this line with your own singleton. Mine is gv (GlobalVariables)
	
	timer.one_shot = true
	timer.timeout.connect(timer_timeout)
	if wait_time.get_value() > 0.05:
		timer.wait_time = wait_time.get_value()




#region Signals


func timer_timeout() -> void:
	set_timer_wait_time()
	timed_out_or_stopped.emit()
	timeout.emit()


func wait_time_changed_receiver() -> void:
	if is_stopped():
		set_timer_wait_time()


func set_timer_wait_time() -> void:
	if are_wait_times_equal():
		return
	if wait_time.get_value() == 0:
		print_debug("Yeah don't let this happen!")
		return
	timer.wait_time = wait_time.get_value()
	wait_time_changed.emit()


#endregion


#region Internal


func are_wait_times_equal() -> bool:
	return wait_time.get_value() == timer.wait_time


#endregion


#region Action


func start() -> void:
	if random:
		wait_time.edit_change(Book.Category.ADDED, wait_time_range, wait_time_range.get_random_point())
	
	timer.start()
	started.emit()


func stop() -> void:
	if is_running():
		duration_elapsed_when_stopped.emit(timer.wait_time - timer.time_left)
		timer.stop()
		timed_out_or_stopped.emit()
		stopped.emit()


func restart() -> void:
	stop()
	start()


func set_wait_time(value: float) -> void:
	wait_time.set_to(value)


func set_minimum_duration(value: float) -> void:
	wait_time_range.current.set_to(value)
	random = true


func set_maximum_duration(value: float) -> void:
	wait_time_range.total.set_to(value)
	random = true


func edit_divided(source, value: float) -> void:
	wait_time.edit_change(Book.Category.DIVIDED, source, value)


func edit_multiplied(source, value: float) -> void:
	wait_time.edit_change(Book.Category.MULTIPLIED, source, value)


#endregion


#region Get


func get_wait_time() -> float:
	return timer.wait_time


func get_time_left() -> float:
	return timer.time_left


func get_inverted_time_left() -> float:
	return get_wait_time() - get_time_left()


func get_percent() -> float:
	return 1.0 - (get_time_left() / get_wait_time())


func is_stopped() -> bool:
	return running.is_false()


func is_running() -> bool:
	return not is_stopped()


func get_wait_time_text() -> String:
	return tp.quick_parse(get_wait_time(), true)


func get_time_left_text() -> String:
	return tp.quick_parse(get_time_left(), true)


func get_inverted_time_left_text() -> String:
	return tp.quick_parse(get_inverted_time_left(), true)


func get_text() -> String:
	return "%s/%s" % [
		Big.get_float_text(get_wait_time() - get_time_left()),
		get_wait_time_text()
	]


func get_average_duration() -> float:
	if random:
		return wait_time_range.get_midpoint() * wait_time.get_value()
	return wait_time.get_value()


func get_maximum_duration() -> float:
	if random:
		return wait_time_range.get_total() * wait_time.get_value()
	return wait_time.get_value()


#endregion


#region Dev


func report() -> void:
	print_debug("Report for LoudTimer ", self, ":")
	print_debug(" - Wait time: ", wait_time.get_text())
	print_debug(" - Wait time range: ", wait_time_range.get_text())
