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
var book := Book.new()


# Book tracks every source of edits to the above values.

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
	book.changed.connect(sync)



#region Action


func reset() -> void:
	book.reset()
	current = base
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
	set_to(
		book.get_changed_value_int(base)
	)


func edit_change(category: Book.Category, source, amount: float) -> void:
	book.edit_change(category, source, amount)


func remove_change(category: Book.Category, source) -> void:
	book.remove_change(category, source, true)


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
