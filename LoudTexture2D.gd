class_name LoudTexture2D
extends Resource



signal renewed

var base: Texture2D
var icon: Texture2D:
	set(val):
		if icon != val:
			icon = val
			changed.emit()



func _init(_base := Texture2D.new()) -> void:
	base = _base
	icon = base



#region Action


func reset() -> void:
	icon = base
	renewed.emit()


func set_to(val: Texture2D) -> void:
	icon = val


#endregion



#region Get


func get_value() -> Texture2D:
	return icon


func get_icon() -> Texture2D:
	return icon


#endregion
