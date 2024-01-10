class_name LoudBoolPair
extends Resource



signal became_opposite
signal became_true
signal became_false

@export var left: LoudBool
@export var right: LoudBool

var left_reminder: String
var right_reminder: String



func _init(
		left_bool: bool,
		right_bool: bool,
		_left_reminder := "",
		_right_reminder := ""
	) -> void:
	left = LoudBool.new(left_bool)
	right = LoudBool.new(right_bool)
	left_reminder = _left_reminder
	right_reminder = _right_reminder
	left.changed.connect(left_or_right_changed)
	right.changed.connect(left_or_right_changed)


#region Signals


func left_or_right_changed() -> void:
	if are_true():
		became_true.emit()
	elif are_opposite():
		became_opposite.emit()
	elif are_false():
		became_false.emit()
	emit_changed()


#endregion


#region Action


func set_left(value: bool) -> void:
	left.set_to(value)


func set_right(value: bool) -> void:
	right.set_to(value)


func set_to(value: bool) -> void:
	set_left(value)
	set_right(value)


func invert() -> void:
	left.invert()
	right.invert()


func set_to_left() -> void:
	set_right(get_left())


func set_to_right() -> void:
	set_left(get_right())


func set_opposing_left(left_value := get_left()) -> void:
	set_left(left_value)
	set_right(not left_value)


func set_opposing_right(right_value := get_right()) -> void:
	set_right(right_value)
	set_left(not right_value)


#endregion


#region Get


func get_left() -> bool:
	return left.get_value()


func get_right() -> bool:
	return right.get_value()


func left_is_and_right_isnt() -> bool:
	return left.is_true() and right.is_false()


func right_is_and_left_isnt() -> bool:
	return right.is_true() and left.is_false()


func are_either_true() -> bool:
	return left.is_true() or right.is_true()


func are_either_false() -> bool:
	return left.is_false() or right.is_false()


func are_true() -> bool:
	return left.is_true() and right.is_true()


func are_opposite() -> bool:
	return (
		left_is_and_right_isnt()
	) or (
		right_is_and_left_isnt()
	)


func are_false() -> bool:
	return left.is_false() and right.is_false()


#endregion


#region Dev


func remind_me() -> void:
	print("Reminder for LoudBoolPair ", self, ":")
	print(" - Left bool: ", left_reminder)
	print(" - Right bool: ", right_reminder)


#endregion
