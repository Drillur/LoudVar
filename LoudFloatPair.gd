class_name FloatPair
extends Resource



const saved_vars := [
	"current",
	"total"
]

signal filled
signal emptied

var current: LoudFloat
var total: LoudFloat

var text: String
var text_requires_update := true
var limit_to_zero := true
var limit_to_total := true



func _init(base_value: float, base_total: float):
	current = LoudFloat.new(base_value)
	total = LoudFloat.new(base_total)
	current.text_changed.connect(text_changed)
	total.text_changed.connect(text_changed)
	current.changed.connect(emit_changed)
	total.changed.connect(emit_changed)


func do_not_limit_to_total() -> void:
	limit_to_total = false


func do_not_limit_to_zero() -> void:
	limit_to_zero = false


func text_changed() -> void:
	text_requires_update = true



func add(amount: float) -> void:
	current.add(amount)
	clamp_current()
	if current.equal(total.get_value()):
		filled.emit()


func subtract(amount: float) -> void:
	current.subtract(amount)
	clamp_current()
	if current.equal(0):
		emptied.emit()


func clamp_current() -> void:
	if limit_to_total:
		if limit_to_zero:
			current.current = clampf(get_current(), 0.0, get_total())
		else:
			current.current = minf(get_current(), get_total())
	else:
		if limit_to_zero:
			current.current = maxf(get_current(), 0.0)


func fill() -> void:
	if is_not_full():
		current.set_to(get_total())
		current.increased.emit()
		filled.emit()



# - Get


func get_value() -> float:
	return current.get_value()


func get_current() -> float:
	return get_value()


func get_total() -> float:
	return total.get_value()


func get_current_percent() -> float:
	return get_value() / get_total()


func get_surplus(amount: float) -> float:
	if is_full() or get_value() + amount > get_total():
		return (get_value() + amount) - get_total()
	return 0.0


func get_text() -> String:
	if text_requires_update:
		text_requires_update = false
		text = current.get_text() + "/" + total.get_text()
	return text


func is_full() -> bool:
	return is_equal_approx(get_current(), get_total())


func is_not_full() -> bool:
	return not is_full()
