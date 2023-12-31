class_name LoudBool
extends Resource


const saved_vars := [
	"current",
]

signal became_true
signal became_false

signal reset_value_changed
signal reset_value_became_true
signal reset_value_became_false

var base: bool

@export var current: bool:
	set(val):
		if current != val:
			current = val
			emit_changed()
			if val:
				became_true.emit()
			else:
				became_false.emit()

var reset_value := false:
	set(val):
		if reset_value != val:
			reset_value = val
			reset_value_changed.emit()
			if val:
				reset_value_became_true.emit()
			else:
				reset_value_became_false.emit()


func _init(_base: bool = false) -> void:
	base = _base
	current = _base



# - Action


func invert() -> void:
	set_to(not current)


func set_true() -> void:
	set_to(true)


func set_false() -> void:
	set_to(false)


func set_to(val: bool) -> void:
	current = val


func set_reset_value_true() -> void:
	set_reset_value(true)


func set_reset_value_false() -> void:
	set_reset_value(false)


func set_reset_value(val: bool) -> void:
	reset_value = val


func set_default_value(val: bool) -> void:
	base = val
	reset_value = val


func prestige() -> void:
	current = reset_value


func reset() -> void:
	current = base
	reset_value = base



func connect_and_call(sig: String, method: Callable) -> void:
	get(sig).connect(method)
	method.call()



# - Get


func is_true() -> bool:
	return true if current else false


func is_not_false() -> bool:
	return is_true()


func is_false() -> bool:
	return not is_true()


func is_not_true() -> bool:
	return is_false()


func is_true_on_reset() -> bool:
	return true if reset_value else false


func is_false_on_reset() -> bool:
	return not is_true_on_reset()


func is_true_by_default() -> bool:
	return true if base else false


func is_false_by_default() -> bool:
	return not is_true_by_default()


func get_value() -> bool:
	return current


func get_default_value() -> bool:
	return base


func get_reset_value() -> bool:
	return reset_value
