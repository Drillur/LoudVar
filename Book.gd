class_name Book
extends Resource



enum Category {
	NONE,
	ADDED,
	SUBTRACTED,
	MULTIPLIED,
	DIVIDED,
	PENDING,
}
enum Type {
	INT,
	FLOAT,
	BIG,
}

signal renewed

var type: Type

var book := {
	Book.Category.ADDED: {},
	Book.Category.SUBTRACTED: {},
	Book.Category.MULTIPLIED: {},
	Book.Category.DIVIDED: {},
	Book.Category.PENDING: {},
}

@export var book_vars_i: BookVarsInt
@export var book_vars_f: BookVarsFloat
@export var book_vars_b: BookVarsBig



func _init(_type: Type):
	type = _type
	match type:
		Type.INT:
			book_vars_i = BookVarsInt.new()
		Type.FLOAT:
			book_vars_f = BookVarsFloat.new()
		Type.BIG:
			book_vars_b = BookVarsBig.new()



#region Internal


# This ridiculous section may not be necessary, but I wanted to use the Book class
# with my game which uses the Big number class by ChronoDK on GitHub. So, to 
# handle 3 separate number types, this was my first idea on how to do it.


func get_bv_added():
	match type:
		Type.INT:
			return book_vars_i.added
		Type.FLOAT:
			return book_vars_f.added
		Type.BIG:
			return book_vars_b.added


func add_added(value):
	match type:
		Type.INT:
			book_vars_i.added += value
		Type.FLOAT:
			book_vars_f.added += value
		Type.BIG:
			book_vars_b.added.a(value)


func subtract_added(value):
	match type:
		Type.INT:
			book_vars_i.added -= value
		Type.FLOAT:
			book_vars_f.added -= value
		Type.BIG:
			book_vars_b.added.s(value)


func set_added(value):
	match type:
		Type.INT:
			book_vars_i.added = value
		Type.FLOAT:
			book_vars_f.added = value
		Type.BIG:
			book_vars_b.added.set_to(value)


func get_bv_subtracted():
	match type:
		Type.INT:
			return book_vars_i.subtracted
		Type.FLOAT:
			return book_vars_f.subtracted
		Type.BIG:
			return book_vars_b.subtracted


func add_subtracted(value):
	match type:
		Type.INT:
			book_vars_i.subtracted += value
		Type.FLOAT:
			book_vars_f.subtracted += value
		Type.BIG:
			book_vars_b.subtracted.a(value)


func subtract_subtracted(value):
	match type:
		Type.INT:
			book_vars_i.subtracted -= value
		Type.FLOAT:
			book_vars_f.subtracted -= value
		Type.BIG:
			book_vars_b.subtracted.s(value)


func set_subtracted(value):
	match type:
		Type.INT:
			book_vars_i.subtracted = value
		Type.FLOAT:
			book_vars_f.subtracted = value
		Type.BIG:
			book_vars_b.subtracted.set_to(value)


func get_bv_multiplied():
	match type:
		Type.INT:
			return book_vars_i.multiplied
		Type.FLOAT:
			return book_vars_f.multiplied
		Type.BIG:
			return book_vars_b.multiplied


func add_multiplied(value):
	match type:
		Type.INT:
			book_vars_i.multiplied *= value
		Type.FLOAT:
			book_vars_f.multiplied *= value
		Type.BIG:
			book_vars_b.multiplied.m(value)


func subtract_multiplied(value):
	match type:
		Type.INT:
			book_vars_i.multiplied /= value
		Type.FLOAT:
			book_vars_f.multiplied /= value
		Type.BIG:
			book_vars_b.multiplied.d(value)


func set_multiplied(value):
	match type:
		Type.INT:
			book_vars_i.multiplied = value
		Type.FLOAT:
			book_vars_f.multiplied = value
		Type.BIG:
			book_vars_b.multiplied.set_to(value)


func get_bv_divided():
	match type:
		Type.INT:
			return book_vars_i.divided
		Type.FLOAT:
			return book_vars_f.divided
		Type.BIG:
			return book_vars_b.divided


func add_divided(value):
	match type:
		Type.INT:
			book_vars_i.divided *= value
		Type.FLOAT:
			book_vars_f.divided *= value
		Type.BIG:
			book_vars_b.divided.m(value)


func subtract_divided(value):
	match type:
		Type.INT:
			book_vars_i.divided /= value
		Type.FLOAT:
			book_vars_f.divided /= value
		Type.BIG:
			book_vars_b.divided.d(value)


func set_divided(value):
	match type:
		Type.INT:
			book_vars_i.divided = value
		Type.FLOAT:
			book_vars_f.divided = value
		Type.BIG:
			book_vars_b.divided.set_to(value)


func get_bv_pending():
	match type:
		Type.INT:
			return book_vars_i.pending
		Type.FLOAT:
			return book_vars_f.pending
		Type.BIG:
			return book_vars_b.pending


func add_pending(value):
	match type:
		Type.INT:
			book_vars_i.pending += value
		Type.FLOAT:
			book_vars_f.pending += value
		Type.BIG:
			book_vars_b.pending.a(value)


func subtract_pending(value):
	match type:
		Type.INT:
			book_vars_i.pending -= value
		Type.FLOAT:
			book_vars_f.pending -= value
		Type.BIG:
			book_vars_b.pending.s(value)


func set_pending(value):
	match type:
		Type.INT:
			book_vars_i.pending = value
		Type.FLOAT:
			book_vars_f.pending = value
		Type.BIG:
			book_vars_b.pending.set_to(value)


#endregion


#region Action


func reset() -> void:
	book.clear()
	set_added(0)
	set_subtracted(0)
	set_multiplied(1)
	set_divided(1)
	set_pending(0)
	renewed.emit()
	emit_changed()


func add_change(category: Book.Category, source, amount) -> void:
	if book[category].has(source):
		if gv.dev_mode:
			print_debug("This source already logged a change for this LoudInt (", self, ")! Fix your code you hack fraud.")
		return
	book[category][source] = amount
	match category:
		Book.Category.ADDED:
			add_added(amount)
		Book.Category.SUBTRACTED:
			add_subtracted(amount)
		Book.Category.MULTIPLIED:
			add_multiplied(amount)
		Book.Category.DIVIDED:
			add_divided(amount)
		Book.Category.PENDING:
			add_pending(amount)
	if category != Book.Category.PENDING:
		emit_changed()


# This has the functionality to be the only method of these 3 you'd need to use!
# If you want to temporarily add 3 to this int,
# call edit_change(Book.Category.ADDED, self, 3) -- simple as that!

# Note that specifically for this class, multiplying by a float could be pretty weird!
# But because the book tracks the logs, it will be fine once you remove_change().
# Also beware this int's limit!


func edit_change(category: Book.Category, source, amount) -> void:
	var effectively_removing := false
	if (
		category in [Book.Category.MULTIPLIED, Book.Category.DIVIDED]
		and (
			(amount is Big and amount.equal(1.0))
			or (not amount is Big and is_equal_approx(amount, 1.0))
		)
	):
		effectively_removing = true
	elif (
		category in [Book.Category.ADDED, Book.Category.SUBTRACTED]
		and (
			(amount is Big and amount.equal(0))
			or is_zero_approx(amount)
		)
	):
		effectively_removing = true
	
	if book[category].has(source):
		remove_change(category, source, effectively_removing)
	if not effectively_removing:
		add_change(category, source, amount)


func remove_change(category: Book.Category, source, sync_afterwards := true) -> void:
	if not source in book[category].keys():
		return
	var amount = book[category][source]
	match category:
		Book.Category.ADDED:
			subtract_added(amount)
		Book.Category.SUBTRACTED:
			subtract_subtracted(amount)
		Book.Category.MULTIPLIED:
			subtract_multiplied(amount)
		Book.Category.DIVIDED:
			subtract_divided(amount)
		Book.Category.PENDING:
			subtract_pending(amount)
	book[category].erase(source)
	if sync_afterwards and category != Book.Category.PENDING:
		emit_changed()


#endregion


#region Get


func get_changed_value_int(base: int) -> int:
	return int(
		(
			base + get_bv_added() - get_bv_subtracted()
		) * get_bv_multiplied() / get_bv_divided()
	)


func get_changed_value_float(base: float) -> float:
	return (
		base + get_bv_added() - get_bv_subtracted()
	) * get_bv_multiplied() / get_bv_divided()


func get_changed_value_big(base: Dictionary) -> Big:
	# remove if not using a Big number class
	return Big.new(base).a(get_bv_added()).s(
		get_bv_subtracted()
	).m(get_bv_multiplied()).d(get_bv_divided())


func get_pending() -> Big:
	return book_vars_b.pending


#endregion
