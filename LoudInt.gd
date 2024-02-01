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

var changed_cd := PhysicsCooldown.new(changed)
var increased_cd := PhysicsCooldown.new(increased)
var decreased_cd := PhysicsCooldown.new(decreased)
var renewed_cd := PhysicsCooldown.new(renewed)
var became_non_zero_cd := PhysicsCooldown.new(became_non_zero)
var became_zero_cd := PhysicsCooldown.new(became_zero)
var value_set_cd := PhysicsCooldown.new(value_set)
var value_set_greater_zero_cd := PhysicsCooldown.new(value_set_greater_zero)
var value_set_to_zero_cd := PhysicsCooldown.new(value_set_to_zero)
var set_to_same_value_cd := PhysicsCooldown.new(set_to_same_value)

var base: int
@export var current: int:
	set(val):
		var previous_value := current
		if current != val:
			if val > limit:
				val = limit
			if is_zero_approx(val):
				val = 0
			current = val
			text_requires_update = true
			if is_zero_approx(previous_value):
				became_non_zero_cd.emit()
			elif is_zero_approx(current):
				became_zero_cd.emit()
			if previous_value > val:
				decreased.emit()
			elif previous_value < val:
				increased.emit()
			emit_changed()
		else:
			set_to_same_value_cd.emit()

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
	if current == base:
		return
	current = base



func set_to(amount) -> void:
	current = amount
	value_set_cd.emit()
	if amount > 0:
		value_set_greater_zero_cd.emit()
	elif is_zero_approx(amount):
		value_set_to_zero_cd.emit()


func set_limit(val: int) -> void:
	limit = val


func add(amount) -> void:
	current += amount


func add_one() -> void:
	add(1)


func subtract(amount) -> void:
	current -= amount


func subtract_one() -> void:
	subtract(1)


func multiply(amount) -> void:
	current *= amount


func divide(amount) -> void:
	current /= amount


func sync() -> void:
	set_to(book.sync.call(base))


func edit_change(category: Book.Category, source, amount: float) -> void:
	book.edit_change(category, source, amount)


func edit_added(source, amount: int) -> void:
	edit_change(Book.Category.ADDED, source, amount)


func edit_subtracted(source, amount: int) -> void:
	edit_change(Book.Category.SUBTRACTED, source, amount)


func edit_multiplied(source, amount: int) -> void:
	edit_change(Book.Category.MULTIPLIED, source, amount)


func edit_divided(source, amount: int) -> void:
	edit_change(Book.Category.DIVIDED, source, amount)


func remove_change(category: Book.Category, source) -> void:
	book.remove_change(category, source)


func remove_added(source) -> void:
	remove_change(Book.Category.ADDED, source)


func remove_subtracted(source) -> void:
	remove_change(Book.Category.SUBTRACTED, source)


func remove_multiplied(source) -> void:
	remove_change(Book.Category.MULTIPLIED, source)


func set_default_value(val: int) -> void:
	base = val


func copycat(loud_int: LoudInt) -> void:
	set_default_value(0)
	set_to(0)
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
	printt(variable_name, " LoudInt changed to ", get_text())


func report() -> void:
	print_debug("Report for ", str(self) if variable_name == "" else variable_name)
	book.report()


#endregion
