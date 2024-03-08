class_name LoudDict
extends Resource



# Readme!
# If values will be ints only, do LoudDict.Int.new({"multiplicative": false})
# Otherwise, use LoudDict.Float.new({"multiplicative": true or false}) if not using Big numbers.
# Sum will be updated as you add() or erase() values.



class Int:
	extends LoudDict
	
	
	var sum := 0
	
	
	func _init(_data := {}) -> void:
		super(_data)
		if multiplicative:
			add_to_sum = func(value):
				sum *= value
			subtract_from_sum = func(value):
				sum /= value
			reset_sum = func():
				sum = 1
		else:
			add_to_sum = func(value):
				sum += value
			subtract_from_sum = func(value):
				sum -= value
			reset_sum = func():
				sum = 0
		reset_sum.call()


class Float:
	extends LoudDict
	
	
	var sum := 0.0
	
	
	func _init(_data := {}) -> void:
		super(_data)
		if multiplicative:
			add_to_sum = func(value):
				sum *= value
			subtract_from_sum = func(value):
				sum /= value
			reset_sum = func():
				sum = 1.0
		else:
			add_to_sum = func(value):
				sum += value
			subtract_from_sum = func(value):
				sum -= value
			reset_sum = func():
				sum = 0.0
		reset_sum.call()


class _Big:
	extends LoudDict
	
	
	var sum := Big.new(0.0)
	
	
	func _init(_data := {}) -> void:
		super(_data)
		reset_sum = func():
			sum.reset()
		if multiplicative:
			sum.set_default_value(1.0)
			add_to_sum = func(value):
				sum.multiply(value)
			subtract_from_sum = func(value):
				sum.divide(value)
		else:
			add_to_sum = func(value):
				sum.add(value)
			subtract_from_sum = func(value):
				sum.subtract(value)


var data := {}
var base := {}
var multiplicative: bool
#var used_for_numbers: bool
var add_to_sum: Callable
var subtract_from_sum: Callable
var reset_sum: Callable
var is_value_redundant: Callable
var would_divide_by_zero: Callable



func _init(_data := {}) -> void:
	multiplicative = _data.get("multiplicative")
	#used_for_numbers = _data.erase("multiplicative")
	base = _data
	data = base
	if multiplicative:
		is_value_redundant = func(value) -> bool:
			match typeof(value):
				TYPE_INT, TYPE_FLOAT:
					return is_equal_approx(value, 1)
				_:
					return value.equal(1)
		would_divide_by_zero = func(value) -> bool:
			match typeof(value):
				TYPE_INT, TYPE_FLOAT:
					return is_zero_approx(value)
				_:
					return value.equal(0)
	else:
		is_value_redundant = func(value) -> bool:
			match typeof(value):
				TYPE_INT, TYPE_FLOAT:
					return is_zero_approx(value)
				_:
					return value.equal(0)
		would_divide_by_zero = func(_value) -> bool:
			return false


#region Internal


func recalculate_sum() -> void:
	reset_sum.call()
	for value in data.values():
		add_to_sum.call(value)


func are_values_equal(value1, value2) -> bool:
	match typeof(value1):
		TYPE_INT, TYPE_FLOAT:
			match typeof(value2):
				TYPE_INT, TYPE_FLOAT:
					return is_equal_approx(value1, value2)
				_:
					return value2.equal(value1)
		_:
			return value1.equal(value2)


#endregion


#region Action


func reset() -> void:
	data.clear()
	for x in base.keys():
		data[x] = base[x]
	recalculate_sum()


func add(key, value) -> void:
	if is_value_redundant.call(value):
		return
	if value is Big:
		data[key] = Big.new(value)
	else:
		data[key] = value
	add_to_sum.call(value)


func edit(key, value) -> void:
	if key in data.keys():
		if are_values_equal(get_value(key), value):
			return
		erase(key)
	add(key, value)


func erase(key) -> void:
	if not key in data:
		return
	if would_divide_by_zero.call(get_value(key)):
		data.erase(key)
		recalculate_sum()
		return
	var value = get_value(key)
	subtract_from_sum.call(value)
	data.erase(key)


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


func report() -> void:
	for x in data:
		match typeof(get_value(x)):
			TYPE_INT, TYPE_FLOAT:
				printt(x, get_value(x))
			_:
				printt(x, get_value(x).text)


#endregion
