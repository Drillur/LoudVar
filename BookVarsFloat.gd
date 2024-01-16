class_name BookVarsFloat
extends Resource



@export var pending := 0.0

var added := 0.0
var subtracted := 0.0
var multiplied := 1.0
var divided := 1.0




func add_pending(amount: float) -> void:
	pending += amount


func set_pending(amount: float) -> void:
	pending = amount


func subtract_pending(amount: float) -> void:
	pending -= amount


func add_added(amount: float) -> void:
	added += amount


func set_added(amount: int) -> void:
	added = amount


func subtract_added(amount: float) -> void:
	added -= amount


func add_subtracted(amount: float) -> void:
	subtracted += amount


func set_subtracted(amount: int) -> void:
	subtracted = amount


func subtract_subtracted(amount: float) -> void:
	subtracted -= amount


func add_multiplied(amount: float) -> void:
	multiplied *= amount


func set_multiplied(amount: int) -> void:
	multiplied = amount


func subtract_multiplied(amount: float) -> void:
	multiplied /= amount


func add_divided(amount: float) -> void:
	divided *= amount


func set_divided(amount: int) -> void:
	divided = amount


func subtract_divided(amount: float) -> void:
	divided /= amount



func get_changed_value(base: float) -> float:
	return (base + added - subtracted) * multiplied / divided
