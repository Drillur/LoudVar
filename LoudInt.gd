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
signal became_non_zero
signal became_zero
signal value_set
signal value_set_greater_zero
signal value_set_to_zero
signal set_to_same_value

var base: int
@export var current: int:
	set(val):
		var previous_value := current
		if current != val:
			if val > limit:
				val = limit
			current = val
			text_requires_update = true
			if is_zero_approx(previous_value):
				became_non_zero.emit()
			elif is_zero_approx(current):
				became_zero.emit()
			if previous_value > val:
				decreased.emit()
			elif previous_value < val:
				increased.emit()
			emit_changed()
		else:
			set_to_same_value.emit()

var copycat_var: LoudInt
var limit: int = 9223372036854775807
@export var book := Book.new(Book.Type.INT)

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
	value_set.emit()
	if amount > 0:
		value_set_greater_zero.emit()
	elif is_zero_approx(amount):
		value_set_to_zero.emit()


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
		book.get_changed_value(base)
	)


func edit_change(category: Book.Category, source, amount: float) -> void:
	book.edit_change(category, source, amount)


func remove_change(category: Book.Category, source) -> void:
	book.remove_change(category, source, true)


func set_default_value(val: int) -> void:
	base = val
	set_to(val)


func copycat(loud_int: LoudInt) -> void:
	set_default_value(0.0)
	copycat_var = loud_int
	copycat_var.changed.connect(copycat_changed)
	copycat_changed()


func copycat_changed() -> void:
	book.edit_change(Book.Category.ADDED, copycat_var, copycat_var.get_value())


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


#region Dev


var variable_name: String


func report_on_changed(_variable_name: String):
	variable_name = _variable_name
	changed.connect(simple_report)


func simple_report() -> void:
	print(variable_name, " LoudInt changed to ", get_text())


func report() -> void:
	print_debug("Report for ", self if variable_name == "" else variable_name)
	print_debug(" - Base: ", base)
	print_debug(" - Added: ", book.get_bv_added())
	print_debug(" - Subtracted: ", book.get_bv_subtracted())
	print_debug(" - Multiplied: ", book.get_bv_multiplied())
	print_debug(" - Divided: ", book.get_bv_divided())
	print_debug(" - == Result: ", get_text())


#endregion
