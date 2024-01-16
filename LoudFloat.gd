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
			if val < minimum_limit:
				val = minimum_limit
			current = val
			text_requires_update = true
			if prev_cur > val:
				increased.emit()
			elif prev_cur < val:
				decreased.emit()
			emit_changed()
			changed_with_previous_value.emit(prev_cur)
@export var book := Book.new(Book.Type.FLOAT)

var base: float
var text_requires_update := true
var text: String:
	get:
		if text_requires_update:
			text_requires_update = false
			text = Big.get_float_text(current)
			text_changed.emit()
		return text
var minimum_limit := -1.79769e308
var copycat_var: LoudFloat



func _init(_base: float) -> void:
	book.changed.connect(sync)
	base = _base
	current = base



#region Action


func reset() -> void:
	book.reset()
	current = base
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
	set_to(
		book.get_changed_value(base)
	)


func edit_change(category: Book.Category, source, amount: float) -> void:
	book.edit_change(category, source, amount)


func edit_added(source, amount: float) -> void:
	edit_change(Book.Category.ADDED, source, amount)


func edit_subtracted(source, amount: float) -> void:
	edit_change(Book.Category.SUBTRACTED, source, amount)


func edit_multiplied(source, amount: float) -> void:
	edit_change(Book.Category.MULTIPLIED, source, amount)


func remove_change(category: Book.Category, source) -> void:
	book.remove_change(category, source, true)


func remove_added(source) -> void:
	remove_change(Book.Category.ADDED, source)


func remove_subtracted(source) -> void:
	remove_change(Book.Category.SUBTRACTED, source)


func remove_multiplied(source) -> void:
	remove_change(Book.Category.MULTIPLIED, source)


func set_default_value(val: float) -> void:
	base = val
	set_to(val)


func copycat(loud_float: LoudFloat) -> void:
	set_default_value(0.0)
	copycat_var = loud_float
	copycat_var.changed.connect(copycat_changed)
	copycat_changed()


func copycat_changed() -> void:
	book.edit_change(Book.Category.ADDED, copycat_var, copycat_var.get_value())


#endregion


#region Get

func get_value() -> float:
	return current


func get_effective_value() -> float:
	return current + book.pending


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


var variable_name: String


func report_on_changed(_variable_name: String):
	variable_name = _variable_name
	changed.connect(simple_report)


func simple_report() -> void:
	print(variable_name, " LoudFloat changed to ", get_text())


func report() -> void:
	print_debug("Report for ", self if variable_name == "" else variable_name)
	print_debug(" - Base: ", base)
	print_debug(" - Added: ", book.get_bv_added())
	print_debug(" - Subtracted: ", book.get_bv_subtracted())
	print_debug(" - Multiplied: ", book.get_bv_multiplied())
	print_debug(" - Divided: ", book.get_bv_divided())
	print_debug(" - == Result: ", get_text())


#endregion
