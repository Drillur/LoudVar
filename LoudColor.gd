class_name LoudColor
extends Resource



const saved_vars := [
	"current",
]

signal changed_with_color(color)

var base: Color

var current: Color:
	set(val):
		if current != val:
			current = val
			emit_changed()
			changed_with_color.emit(val)



func _init(_base: Color) -> void:
	base = _base
	current = _base



#region Action


func set_to(val: Color) -> void:
	current = val


func reset() -> void:
	current = base


#endregion



#region Get


func get_value() -> Color:
	return current


#endregion
