class_name LoudInt
extends Resource



# Use example: Unit Level!
# Knowing when a unit levels up is vitally important! So, connect 'increased' or
# 'changed' to a method and then you can increase that unit's stats the instant
# his level changes!
# This also has functionality to grant a unit temporary levels! See the 'book'
# dictionary and 'edit_change()' below!



signal increased
signal decreased
signal renewed

var base: int
@export var current: int:
	set(val):
		if current != val:
			if val > limit:
				val = limit
			var previous_value := current
			current = val
			text_requires_update = true
			if previous_value > val:
				decreased.emit()
			elif previous_value < val:
				increased.emit()
			emit_changed()
@export var pending := 0

var limit: int = 9223372036854775807

var added := 0
var subtracted := 0
var multiplied := 1
var divided := 1

# Book tracks every source of edits to the above values.

var book := {
	"added": {},
	"subtracted": {},
	"multiplied": {},
	"divided": {},
	"pending": {},
}

var text_requires_update := true
var text: String:
	get:
		if text_requires_update:
			text_requires_update = false
			text = Big.get_float_text(current)
		return text



func _init(_base: int) -> void:
	base = _base
	current = base



#region Action


func reset() -> void:
	current = base
	added = 0
	subtracted = 0
	multiplied = 1
	divided = 1
	renewed.emit()



func set_to(amount) -> void:
	current = amount


func set_limit(val: int) -> void:
	limit = val


func add(amount) -> void:
	current += amount


func subtract(amount) -> void:
	current -= amount


func multiply(amount) -> void:
	current *= amount


func divide(amount) -> void:
	current /= amount


func sync() -> void:
	var new_value := base
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


func add_change(category: String, source, amount) -> void:
	if book[category].has(source):
		if gv.dev_mode:
			print_debug("This source already logged a change for this LoudInt (", self, ")! Fix your code you hack fraud.")
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
# If you want to temporarily add 3 to this int,
# call edit_change("added", self, 3) -- simple as that!

# Note that specifically for this class, multiplying by a float could be pretty weird!
# But because the book tracks the logs, it will be fine once you remove_change().
# Also beware this int's limit!


func edit_change(category: String, source, amount) -> void:
	if book[category].has(source):
		remove_change(category, source, false)
	if not is_zero_approx(amount):
		add_change(category, source, amount)


func remove_change(category: String, source, sync_afterwards := true) -> void:
	if not source in book[category].keys():
		return
	var amount: int = book[category][source]
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


func get_text() -> String:
	return text


func get_value() -> int:
	return current


func is_positive() -> bool:
	return current >= 0


func is_not_negative() -> bool:
	return is_positive()


func is_negative() -> bool:
	return not is_positive()


func is_not_positive() -> bool:
	return is_negative()


func at_limit() -> bool:
	return equal(limit)


func less_than_limit() -> bool:
	return less(limit)


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
