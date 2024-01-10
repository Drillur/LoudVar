class_name LoudFloatPair
extends Resource



# Use example: Current and Total Experience!
# I use the 'filled' signal below to know when a unit has gained enough xp to level up!
# I would also ensure that limit_to_total is false, or your unit might waste xp.
# Methods like 'get_current_percent()' and 'get_midpoint()' make this class invaluable.
# You're currently wishing you had thought of this like I was when I was thinking of it!



signal filled
signal emptied

@export var current: LoudFloat
var total: LoudFloat

var full := LoudBool.new(false)
var empty := LoudBool.new(false)

var text: String
var text_requires_update := true
var limit_to_zero := true
var limit_to_total := true



func _init(base_value: float, base_total: float, _limit_to_total = true):
	current = LoudFloat.new(base_value)
	total = LoudFloat.new(base_total)
	limit_to_total = _limit_to_total
	if current.equal(total.get_value()):
		full.set_default_value(true)
		full.reset()
	elif current.equal(0):
		empty.set_default_value(true)
		empty.reset()
	current.text_changed.connect(text_changed)
	total.text_changed.connect(text_changed)
	current.changed.connect(check_if_full)
	total.changed.connect(check_if_full)
	current.changed.connect(emit_changed)
	total.changed.connect(emit_changed)
	full.changed.connect(full_changed)
	empty.changed.connect(empty_changed)



#region Internal


func text_changed() -> void:
	text_requires_update = true


func full_changed() -> void:
	if full.is_true():
		filled.emit()


func empty_changed() -> void:
	if empty.is_true():
		emptied.emit()


func check_if_full() -> void:
	if current.equal(get_total()):
		full.set_to(true)
	else:
		full.set_to(false)


#endregion


#region Action


func do_not_limit_to_total() -> LoudFloatPair:
	limit_to_total = false
	return self


func do_not_limit_to_zero() -> LoudFloatPair:
	limit_to_zero = false
	return self


func add(amount: float) -> void:
	if limit_to_total and full.is_true():
		return
	current.add(amount)
	clamp_current()
	if empty.is_true():
		empty.set_to(false)
	if current.greater_equal(total.get_value()):
		full.set_to(true)


func subtract(amount: float) -> void:
	if limit_to_zero and empty.is_true():
		return
	current.subtract(amount)
	clamp_current()
	if full.is_true():
		full.set_to(false)
	if current.equal(0):
		empty.set_to(true)


func clamp_current() -> void:
	if limit_to_total:
		if limit_to_zero:
			current.current = clampf(get_current(), 0.0, get_total())
		else:
			current.current = minf(get_current(), get_total())
	else:
		if limit_to_zero:
			current.current = maxf(get_current(), 0.0)


func fill() -> void:
	if full.is_false():
		add(get_deficit())


func dump() -> void:
	if empty.is_false():
		subtract(get_current())


#endregion


#region Get


func get_value() -> float:
	return current.get_value()


func get_current() -> float:
	return get_value()


func get_total() -> float:
	return total.get_value()


func get_current_percent() -> float:
	return get_value() / get_total()


func get_deficit() -> float:
	return abs(get_total() - get_current())


func get_surplus(amount: float) -> float:
	if full.is_true() or get_value() + amount > get_total():
		return (get_current() + amount) - get_total()
	return 0.0


func get_midpoint() -> float:
	if is_full():
		return get_total()
	return (get_current() + get_total()) / 2


func get_random_point() -> float:
	if is_full():
		return get_total()
	return randf_range(get_current(), get_total())


func get_text() -> String:
	if text_requires_update:
		text_requires_update = false
		text = get_current_text() + "/" + get_total_text()
	return text


func get_current_text() -> String:
	return current.get_text()


func get_total_text() -> String:
	return total.get_text()


func is_full() -> bool:
	return full.is_true()


func is_not_full() -> bool:
	return full.is_false()


func is_empty() -> bool:
	return empty.is_true()


func is_not_empty() -> bool:
	return empty.is_false()

#endregion


#region Dev


func report() -> void:
	print("Report for ", self)
	print("Current:")
	current.report()
	print("Total:")
	total.report()


#endregion
