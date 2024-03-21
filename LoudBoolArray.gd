class_name LoudBoolArray
extends Resource



# Nothing in this class is saved! All of the values here are are a reflection of other bools.



signal became_true
signal became_false

var consensus := LoudBool.new(false)
var bool_pool: Array[LoudBool]


func _init(bools: Array[LoudBool]) -> void:
	set_bools(bools)
	consensus.became_true.connect(func(): became_true.emit())
	consensus.became_false.connect(func(): became_false.emit())
	consensus.changed.connect(emit_changed)



#region Signals


func update_consensus() -> void:
	if are_all_true():
		consensus.set_true()
	else:
		consensus.set_false()


#endregion


#region Internal


# These are internal because they're in a loop! I hate loops, they frighten me!
# Use is_true() or is_false(), that's all you'd need (probably)


func are_all_true() -> bool:
	for _bool in bool_pool:
		if _bool.is_false():
			return false
	return true


func are_all_false() -> bool:
	for _bool in bool_pool:
		if _bool.is_true():
			return false
	return true


#endregion


#region Action


func set_bools(bools: Array[LoudBool]) -> void:
	bool_pool = bools
	for _bool in bool_pool:
		_bool.changed.connect(update_consensus)
	update_consensus()


func set_to(value: bool) -> void:
	for x in bool_pool:
		x.set_to(value)


#endregion


#region Get


func get_value() -> bool:
	return is_true()


func is_true() -> bool:
	return consensus.is_true()


func is_false() -> bool:
	return is_even_a_little_false()


func is_somewhat_true() -> bool:
	if consensus.is_true():
		return true
	if not are_all_false():
		return true
	return false


func is_somewhat_false() -> bool:
	if consensus.is_false():
		return true
	if not are_all_true():
		return true
	return false


func is_even_a_little_false() -> bool:
	return is_somewhat_false()


func are_any_true() -> bool:
	return is_somewhat_true()


func are_any_false() -> bool:
	return is_somewhat_false()


func get_values() -> Array[bool]:
	var a: Array[bool]
	for _bool in bool_pool:
		a.append(_bool.get_value())
	return a


#endregion


#region Dev


func report() -> void:
	printt("Report for LoudBoolArray ", self, ":")
	printt("-", "Consensus:", consensus.get_value())
	var i = 0
	for _bool in bool_pool:
		printt("-", "- " + str(i), _bool, _bool.get_value())
		i += 1


func report_on_changed(var_name: String) -> void:
	var i := 0
	for _bool in bool_pool:
		_bool.changed.connect(
			func():
				printt("LoudBoolArray %s bool %s changed to %s." % [
					var_name,
					str(i),
					str(_bool.get_value())
				])
		)


#endregion
