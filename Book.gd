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

@export var book_vars: Resource



func _init(_type: Type):
	type = _type
	match type:
		Type.INT:
			book_vars = BookVarsInt.new()
		Type.FLOAT:
			book_vars = BookVarsFloat.new()
		Type.BIG:
			book_vars = BookVarsBig.new()



#region Internal


func get_bv_added():
	return book_vars.added


func get_bv_subtracted():
	return book_vars.subtracted


func get_bv_multiplied():
	return book_vars.multiplied


func get_bv_divided():
	return book_vars.divided


func get_bv_pending():
	return book_vars.pending


func change_would_be_redundant(category: Book.Category, amount) -> bool:
	if Book.is_category_multiplicative(category):
		if typeof(amount) in [TYPE_FLOAT, TYPE_INT]:
			if is_equal_approx(amount, 1.0):
				return true
		else:
			if amount.equal(1):
				return true
	else:
		if typeof(amount) in [TYPE_FLOAT, TYPE_INT]:
			if is_zero_approx(amount):
				return true
		else:
			if amount.equal(0):
				return true
	return false


func would_effectively_remove(category: Book.Category, amount) -> bool:
	if category == Book.Category.PENDING:
		return false
	match type:
		Type.INT, Type.FLOAT:
			if Book.is_category_multiplicative(category):
				if is_equal_approx(amount, 1.0):
					return true
			else:
				if is_zero_approx(amount):
					return true
		Type.BIG:
			if not amount is Big:
				amount = Big.new(amount)
			if Book.is_category_multiplicative(category):
				if amount.equal(1):
					return true
			else:
				if amount.equal(0):
					return true
	return false


func would_divide_by_zero(category: Book.Category, value) -> bool:
	if Book.is_category_multiplicative(category):
		match type:
			Type.INT, Type.FLOAT:
				if is_zero_approx(value):
					return true
			Type.BIG:
				if not value is Big:
					value = Big.new(value)
				if value.equal(0):
					return true
	return false


#endregion


#region Action


func reset() -> void:
	for category in book:
		book[category].clear()
	book_vars.set_added(0)
	book_vars.set_subtracted(0)
	book_vars.set_multiplied(1)
	book_vars.set_divided(1)
	book_vars.set_pending(0)
	renewed.emit()
	#emit_changed()


func add_change(category: Book.Category, source, amount) -> void:
	if book[category].has(source):
		if gv.dev_mode:
			print_debug("This source already logged a change for this LoudInt (", self, ")! Fix your code you hack fraud.")
		return
	if change_would_be_redundant(category, amount):
		return
	
	if amount is Big:
		amount = Big.new(amount)
	book[category][source] = amount
	match category:
		Book.Category.ADDED:
			book_vars.add_added(amount)
		Book.Category.SUBTRACTED:
			book_vars.add_subtracted(amount)
		Book.Category.MULTIPLIED:
			book_vars.add_multiplied(amount)
		Book.Category.DIVIDED:
			book_vars.add_divided(amount)
		Book.Category.PENDING:
			book_vars.add_pending(amount)
	if category == Book.Category.PENDING:
		return
	emit_changed()


# This has the functionality to be the only method of these 3 you'd need to use!
# If you want to temporarily add 3 to this int,
# call edit_change(Book.Category.ADDED, self, 3) -- simple as that!

# Note that specifically for this class, multiplying by a float could be pretty weird!
# But because the book tracks the logs, it will be fine once you remove_change().
# Also beware this int's limit!


func edit_change(category: Book.Category, source, amount) -> void:
	var effectively_removing := false
	if book[category].has(source):
		effectively_removing = would_effectively_remove(category, amount)
		remove_change(category, source, effectively_removing)
	if not effectively_removing:
		add_change(category, source, amount)


func remove_change(category: Book.Category, source, sync_afterwards := true) -> void:
	if not source in book[category].keys():
		return
	var amount = book[category][source]
	if would_divide_by_zero(category, amount):
		# if amount == 0, just stop here and then do a complete re-sync of everything in the book. but erase source first.
		book[category].erase(source)
		full_resync()
		return
	match category:
		Book.Category.ADDED:
			book_vars.subtract_added(amount)
		Book.Category.SUBTRACTED:
			book_vars.subtract_subtracted(amount)
		Book.Category.MULTIPLIED:
			book_vars.subtract_multiplied(amount)
		Book.Category.DIVIDED:
			book_vars.subtract_divided(amount)
		Book.Category.PENDING:
			book_vars.subtract_pending(amount)
	book[category].erase(source)
	if category == Book.Category.PENDING:
		return
	if sync_afterwards:
		emit_changed()


func add_changer(category: Book.Category, object: Resource) -> void:
	match category:
		Book.Category.ADDED:
			add_adder(object)
		Book.Category.SUBTRACTED:
			add_subtracter(object)
		Book.Category.MULTIPLIED:
			add_multiplier(object)
		Book.Category.DIVIDED:
			add_divider(object)


func add_adder(object: Resource) -> void:
	edit_change(Book.Category.ADDED, object, object.get_value())
	object.changed.connect(
		func():
			edit_change(Book.Category.ADDED, object, object.get_value())
	)


func add_subtracter(object: Resource) -> void:
	edit_change(Book.Category.SUBTRACTED, object, object.get_value())
	object.changed.connect(
		func():
			edit_change(Book.Category.SUBTRACTED, object, object.get_value())
	)


func add_multiplier(object: Resource) -> void:
	edit_change(Book.Category.MULTIPLIED, object, object.get_value())
	object.changed.connect(
		func():
			edit_change(Book.Category.MULTIPLIED, object, object.get_value())
	)


func add_divider(object: Resource) -> void:
	edit_change(Book.Category.DIVIDED, object, object.get_value())
	object.changed.connect(
		func():
			edit_change(Book.Category.DIVIDED, object, object.get_value())
	)


func add_powerer(mantissa: Resource, exponent: Resource, offset := 0) -> void:
	var power_up = func():
		#printt("powering up. m: ", mantissa.get_value(), " e: ", exponent.get_value() + offset, " == ", Big.new(mantissa.get_value()).power(exponent.get_value() + offset).text)
		edit_change(
			Book.Category.MULTIPLIED,
			mantissa,
			Big.new(mantissa.get_value()).power(
				max(0, exponent.get_value() + offset)
			)
		)
		
	power_up.call()
	mantissa.changed.connect(power_up)
	exponent.changed.connect(power_up)


func full_resync() -> void:
	book_vars.set_added(0)
	book_vars.set_subtracted(0)
	book_vars.set_multiplied(1)
	book_vars.set_divided(1)
	for value in book[Category.ADDED].values():
		book_vars.add_added(value)
	for value in book[Category.SUBTRACTED].values():
		book_vars.add_subtracted(value)
	for value in book[Category.MULTIPLIED].values():
		book_vars.add_multiplied(value)
	for value in book[Category.DIVIDED].values():
		book_vars.add_divided(value)
	emit_changed()


#endregion


#region Get


func get_pending():
	return get_bv_pending()


func get_changed_value(base):
	return book_vars.get_changed_value(base)


static func is_category_multiplicative(_category: Book.Category) -> bool:
	return _category in [Book.Category.MULTIPLIED, Book.Category.DIVIDED]


static func is_category_additive(_category: Book.Category) -> bool:
	return _category in [Book.Category.ADDED, Book.Category.SUBTRACTED]


#endregion


#region Dev


func report() -> void:
	printt("Book Report (", self, ")")
	for category in book:
		var bv = call("get_bv_" + Category.keys()[category].to_lower())
		if bv is Big:
			bv = bv.get_text()
		printt(" - ", Category.keys()[category], "(" + bv + ")")
		for source in book[category]:
			if type == Type.BIG:
				printt("    - ", source, ": ", book[category][source].get_text())
			else:
				printt("    - ", source, ": ", book[category][source])
