class_name LoudColor
extends Resource



# This one is useful because you can store it as a reference on a node somewhere,
# and then whenever the color changes, it will emit 'changed' and alert that node immediately
# (after you connect it, of course)!
# Except for that, this one sucks. It's only useful for the signal potential.



signal changed_with_color(color)

var base: Color

@export var current: Color:
	set(val):
		if current != val:
			current = val
			emit_changed()
			changed_with_color.emit(val)



func _init(r, g := 1.0, b := 1.0, a := 1.0) -> void:
	if r is Color:
		base = r
	else:
		base = Color(r, g, b, a)
	current = base



#region Action


func set_to(val: Color) -> void:
	current = val


func set_default_value(val: Color) -> void:
	base = val


func reset() -> void:
	current = base


#endregion



#region Get


func get_value() -> Color:
	return current


#endregion
