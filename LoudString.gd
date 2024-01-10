class_name LoudString
extends Resource



# Use example: Disguised Monster Name!
# Maybe you've got a sneaky monster in your game which can change its appearance--
# to make it sneakier, you also change its name to further sell the change!
# Connect a method to the 'changed' signal and you can immediately update a label with the new name.



var base: String
var text: String:
	set(val):
		if text != val:
			text = val
			changed.emit()



func _init(_base := "") -> void:
	base = _base
	reset()



#region Action


func reset() -> void:
	text = base


func set_to(val: String) -> void:
	text = val


#endregion



#region Get


func get_value() -> String:
	return text


func get_text() -> String:
	return text


#endregion
