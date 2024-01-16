class_name BookVarsInt
extends Resource



@export var pending := 0

var added := 0
var subtracted := 0
var multiplied := 1
var divided := 1



func add_pending(amount: int) -> void:
	pending += amount


func set_pending(amount: int) -> void:
	pending = amount


func subtract_pending(amount: int) -> void:
	pending -= amount


func add_added(amount: int) -> void:
	added += amount


func set_added(amount: int) -> void:
	added = amount


func subtract_added(amount: int) -> void:
	added -= amount


func add_subtracted(amount: int) -> void:
	subtracted += amount


func set_subtracted(amount: int) -> void:
	subtracted = amount


func subtract_subtracted(amount: int) -> void:
	subtracted -= amount


func add_multiplied(amount: int) -> void:
	multiplied *= amount


func set_multiplied(amount: int) -> void:
	multiplied = amount


func subtract_multiplied(amount: int) -> void:
	multiplied /= amount


func add_divided(amount: int) -> void:
	divided *= amount


func set_divided(amount: int) -> void:
	divided = amount


func subtract_divided(amount: int) -> void:
	divided /= amount



func get_changed_value(base: int) -> int:
	return (base + added - subtracted) * multiplied / divided
