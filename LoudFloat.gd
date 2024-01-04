class_name LoudFloat
extends Resource



const saved_vars := [
	"current",
]

signal changed_with_previous_value(previous_value)
signal increased
signal decreased
signal text_changed

var base: float
var current: float:
	set(val):
		if current != val:
			var prev_cur = current
			current = val
			text_requires_update = true
			if prev_cur > val:
				increased.emit()
			elif prev_cur < val:
				decreased.emit()
			emit_changed()
			changed_with_previous_value.emit(prev_cur)

var text_requires_update := true
var text: String:
	get:
		if text_requires_update:
			text_requires_update = false
			text = Big.get_float_text(current)
			text_changed.emit()
		return text

var pending := 0.0

var added := 0.0
var subtracted := 0.0
var multiplied := 1.0
var divided := 1.0

var log := {
	"added": {},
	"subtracted": {},
	"multiplied": {},
	"divided": {},
	"pending": {},
}



func _init(_base: float) -> void:
	base = _base
	current = base



func reset() -> void:
	current = base
	added = 0.0
	subtracted = 0.0
	multiplied = 1.0
	divided = 1.0



func set_to(amount) -> void:
	current = amount


func add(amount) -> void:
	if amount == 0.0:
		return
	current += amount


func subtract(amount) -> void:
	if amount == 0.0:
		return
	current -= amount


func multiply(amount) -> void:
	if amount == 1.0:
		return
	current *= amount


func divide(amount) -> void:
	if amount == 1.0:
		return
	current /= amount


func sync() -> void:
	var new_value = base
	new_value *= multiplied
	new_value /= divided
	new_value += added
	new_value -= subtracted
	set_to(new_value)


func increase_added(amount) -> void:
	added += amount
	sync()


func decrease_added(amount) -> void:
	added -= amount
	sync()


func increase_subtracted(amount) -> void:
	subtracted += amount
	sync()


func decrease_subtracted(amount) -> void:
	subtracted -= amount
	sync()


func increase_multiplied(amount) -> void:
	multiplied *= amount
	sync()


func decrease_multiplied(amount) -> void:
	multiplied /= amount
	sync()


func increase_divided(amount) -> void:
	divided *= amount
	sync()


func decrease_divided(amount) -> void:
	divided /= amount
	sync()


func add_change(category: String, source, amount: float) -> void:
	if log[category].has(source):
		if gv.dev_mode:
			print_debug("This source already logged a change for this Value! Fix your code.")
		return
	log[category][source] = amount
	match category:
		"added":
			increase_added(amount)
		"subtracted":
			increase_subtracted(amount)
		"multiplied":
			increase_multiplied(amount)
		"divided":
			increase_divided(amount)
		"pending":
			pending += amount


func edit_change(category: String, source, amount: float) -> void:
	if log[category].has(source):
		remove_change(category, source, false)
	add_change(category, source, amount)


func remove_change(category: String, source, sync_afterwards := true) -> void:
	if not source in log[category].keys():
		return
	var amount: float = log[category][source]
	match category:
		"added":
			added -= amount
		"subtracted":
			subtracted -= amount
		"multiplied":
			multiplied /= amount
		"divided":
			divided /= amount
		"pending":
			pending -= amount
	log[category].erase(source)
	if sync_afterwards:
		sync()





# - Get

func get_value() -> float:
	return current


func get_effective_value() -> float:
	return current + pending


func get_text() -> String:
	return text


func is_positive() -> bool:
	return current >= 0


func is_not_negative() -> bool:
	return is_positive()


func is_negative() -> bool:
	return not is_positive()


func is_not_positive() -> bool:
	return is_negative()


func greater(val) -> bool:
	return not less_equal(val)


func greater_equal(val) -> bool:
	return not less(val)


func equal(val) -> bool:
	return is_equal_approx(current, val)


func not_equal(val) -> bool:
	return not equal(val)


func less_equal(val) -> bool:
	return less(val) or equal(val)


func less(val) -> bool:
	return current < val




# - Dev


func report() -> void:
	print("Report for ", self)
	print("    Base: ", base)
	print("    Added: ", added)
	print("    Subtracted: ", subtracted)
	print("    Multiplied: ", multiplied)
	print("    Divided: ", divided)
	print("    == Result: ", get_text())
