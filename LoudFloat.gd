class_name LoudFloat
extends Resource



# Use example: Critical Multiplier!
# When you roll for a crit, you also roll for the multiplier, be it x1.5 or x2.0
# When that value changes, you will want to know about it and update labels in your game.
# Connect to the 'changed' signal and you're done!
# Don't forget to check out the super-readable methods like 'is_positive()' and 'less_equal()'



signal changed_with_previous_value(previous_value)
signal increased
signal decreased
signal text_changed
signal renewed

@export var current: float:
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
@export var pending := 0.0

var base: float

var text_requires_update := true
var text: String:
	get:
		if text_requires_update:
			text_requires_update = false
			text = Big.get_float_text(current)
			text_changed.emit()
		return text

var added := 0.0
var subtracted := 0.0
var multiplied := 1.0
var divided := 1.0

# Book tracks every source of edits to the above values.

var book := {
	"added": {},
	"subtracted": {},
	"multiplied": {},
	"divided": {},
	"pending": {},
}



func _init(_base: float) -> void:
	base = _base
	current = base



#region Action


func reset() -> void:
	current = base
	added = 0.0
	subtracted = 0.0
	multiplied = 1.0
	divided = 1.0
	renewed.emit()


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
	new_value += added
	new_value -= subtracted
	new_value *= multiplied
	new_value /= divided
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
	if book[category].has(source):
		if gv.dev_mode:
			print_debug("This source already logged a change for this LoudFloat (", self, ")! Fix your code you hack fraud.")
		return
	book[category][source] = amount
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


# This has the functionality to be the only method of these 3 you'd need to use!
# If you want to multiplicatively increase this float by 1.5,
# call edit_change("multiplied", self, 1.5) -- simple as that!


func edit_change(category: String, source, amount: float) -> void:
	if book[category].has(source):
		remove_change(category, source, false)
	if not is_zero_approx(amount):
		add_change(category, source, amount)


func remove_change(category: String, source, sync_afterwards := true) -> void:
	if not source in book[category].keys():
		return
	var amount: float = book[category][source]
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
	book[category].erase(source)
	if sync_afterwards:
		sync()


#endregion


#region Get

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


#endregion


#region Dev


func report() -> void:
	print("Report for ", self)
	print("    Base: ", base)
	print("    Added: ", added)
	print("    Subtracted: ", subtracted)
	print("    Multiplied: ", multiplied)
	print("    Divided: ", divided)
	print("    == Result: ", get_text())


#endregion
