class_name LoudFloat
extends Resource



# Use example: Critical Multiplier!
# When you roll for a crit, you also roll for the multiplier, be it x1.5 or x2.0
# When that value changes, you will want to know about it and update labels in your game.
# Connect to the 'changed' signal and you're done!
# Don't forget to check out the super-readable methods like 'is_positive()' and 'less_equal()'



signal increased
signal decreased
signal text_changed
signal renewed
signal amount_increased(amount)

var changed_cd := PhysicsCooldown.new(changed)
var increased_cd := PhysicsCooldown.new(increased)
var decreased_cd := PhysicsCooldown.new(decreased)
var text_changed_cd := PhysicsCooldown.new(text_changed)
var renewed_cd := PhysicsCooldown.new(renewed)


@export var current: float:
	set(val):
		var previous_value := current
		if current != val:
			if val < minimum_limit:
				val = minimum_limit
			if is_zero_approx(val):
				val = 0.0
			current = val
			text_requires_update = true
			if previous_value > val:
				decreased_cd.emit()
			elif previous_value < val:
				increased_cd.emit()
			changed_cd.emit()
var book := Book.new(Book.Type.FLOAT)

var base: float
var text_requires_update := true
var text: String:
	get:
		if text_requires_update:
			text_requires_update = false
			text = Big.get_float_text(current)
			text_changed_cd.emit()
		return text
var minimum_limit := -1.79769e308



func _init(_base: float) -> void:
	base = _base
	current = base
	book.changed.connect(sync)



#region Action


func reset() -> void:
	book.reset()
	if current == base:
		return
	current = base
	renewed_cd.emit()


func set_to(amount) -> void:
	current = amount


func add(amount) -> void:
	if amount == 0.0:
		return
	current += amount
	amount_increased.emit(amount)


func add_one() -> void:
	add(1.0)


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
	set_to(book.sync.call(base))


func edit_change(category: Book.Category, source, amount: float) -> void:
	book.edit_change(category, source, amount)


func edit_added(source, amount: float) -> void:
	edit_change(Book.Category.ADDED, source, amount)


func edit_subtracted(source, amount: float) -> void:
	edit_change(Book.Category.SUBTRACTED, source, amount)


func edit_multiplied(source, amount: float) -> void:
	edit_change(Book.Category.MULTIPLIED, source, amount)


func edit_divided(source, amount: float) -> void:
	edit_change(Book.Category.DIVIDED, source, amount)


func remove_change(category: Book.Category, source) -> void:
	book.remove_change(category, source)


func remove_added(source) -> void:
	remove_change(Book.Category.ADDED, source)


func remove_subtracted(source) -> void:
	remove_change(Book.Category.SUBTRACTED, source)


func remove_multiplied(source) -> void:
	remove_change(Book.Category.MULTIPLIED, source)


func set_default_value(val: float) -> void:
	base = val


func copycat(cat: Resource) -> void:
	set_default_value(0.0)
	set_to(0.0)
	var copy = func():
		book.edit_change(Book.Category.ADDED, cat, cat.get_value())
	copy.call()
	cat.changed.connect(copy)


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
	printt(variable_name, " LoudFloat changed to ", get_text())


func report() -> void:
	printt("Report for ", str(self) if variable_name == "" else variable_name)
	printt(" - Base: ", base)
	book.report()


#endregion
