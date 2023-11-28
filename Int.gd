class_name LoudInt
extends Resource



const saved_vars := [
	"current",
]

signal increased
signal decreased

var base: int
var current: int:
	set(val):
		if current != val:
			var previous_value = current
			current = val
			text_requires_update = true
			if previous_value > val:
				decreased.emit()
			elif previous_value < val:
				increased.emit()
			emit_changed()

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



func reset() -> void:
	current = base



func set_to(amount) -> void:
	current = amount


func add(amount) -> void:
	current += amount


func subtract(amount) -> void:
	current -= amount


func multiply(amount) -> void:
	current *= amount


func divide(amount) -> void:
	current /= amount



# - Get


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


