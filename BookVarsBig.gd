class_name BookVarsBig
extends Resource



@export var pending := Big.new(0.0)

var added := Big.new(0.0)
var subtracted := Big.new(0.0)
var multiplied := Big.new(1.0)
var divided := Big.new(1.0)




func add_pending(amount) -> void:
	pending.a(amount)


func set_pending(amount) -> void:
	pending.set_to(amount)


func subtract_pending(amount) -> void:
	pending.s(amount)


func add_added(amount) -> void:
	added.a(amount)


func set_added(amount) -> void:
	added.set_to(amount)


func subtract_added(amount) -> void:
	added.s(amount)


func set_subtracted(amount) -> void:
	subtracted.set_to(amount)


func add_subtracted(amount) -> void:
	subtracted.a(amount)


func subtract_subtracted(amount) -> void:
	subtracted.s(amount)


func add_multiplied(amount) -> void:
	multiplied.m(amount)


func set_multiplied(amount) -> void:
	multiplied.set_to(amount)


func subtract_multiplied(amount) -> void:
	multiplied.d(amount)


func add_divided(amount) -> void:
	divided.m(amount)


func set_divided(amount) -> void:
	divided.set_to(amount)


func subtract_divided(amount) -> void:
	divided.d(amount)



func get_changed_value(base) -> Big:
	return Big.new(base).a(added).s(subtracted).m(multiplied).d(divided)
