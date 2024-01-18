class_name LoudDict
extends Resource



 # Sorry if you're using LoudVars but not Big numbers! LoudDict will not work for you. Delete it.



@export var data := {}
var base := {}

var sum := Big.new(0)



func _init(_data := {}) -> void:
	data = _data
	base = data
	for value in data.values():
		add_to_sum(value)



#region Internal


func add_to_sum(value) -> void:
	if value is int or value is float or value is Big:
		sum.a(value)


func subtract_from_sum(value) -> void:
	if value is int or value is float or value is Big:
		sum.s(value)


#endregion


#region Signals





#endregion


#region Action


func reset() -> void:
	data.clear()
	data = base.duplicate()


func add(key, value) -> void:
	data[key] = value
	add_to_sum(value)
	emit_changed()


func erase(key) -> void:
	var value = data[key]
	data.erase(key)
	subtract_from_sum(value)
	emit_changed()


#endregion


#region Get


func has(key) -> bool:
	return data.has(key)


func get_value(key):
	if has(key):
		return data[key]


func keys() -> Array:
	return data.keys()


func size() -> int:
	return data.size()


#endregion


#region Dev





#endregion
