class_name PhysicsCooldown
extends RefCounted



signal cooldown_ended

var sig: Signal
var on_cooldown := false
var queued := false



func _init(_sig: Signal) -> void:
	sig = _sig
	if gv.root_ready.is_false():
		gv.root_ready.became_true.connect(root_became_ready)


func root_became_ready() -> void:
	if queued:
		queued = false
		emit()


func end_cooldown() -> void:
	on_cooldown = false
	if queued:
		queued = false
		emit()
	else:
		gv.get_tree().physics_frame.disconnect(end_cooldown)
	cooldown_ended.emit()


func emit() -> void:
	if queued:
		return
	if gv.root_ready.is_false():
		queued = true
		return
	if on_cooldown:
		queued = true
		return
	sig.emit()
	on_cooldown = true
	if not gv.get_tree().physics_frame.is_connected(end_cooldown):
		gv.get_tree().physics_frame.connect(end_cooldown)


func is_on_cooldown() -> bool:
	return on_cooldown
