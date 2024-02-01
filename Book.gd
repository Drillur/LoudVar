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

signal pending_changed

var type: Type
var sync: Callable

var book := {}



func _init(_type: Type):
	type = _type
	match type:
		Type.INT:
			book = {
				Book.Category.ADDED: LoudDict.Int.new({"multiplicative": false}),
				Book.Category.SUBTRACTED: LoudDict.Int.new({"multiplicative": false}),
				Book.Category.MULTIPLIED: LoudDict.Int.new({"multiplicative": true}),
				Book.Category.DIVIDED: LoudDict.Int.new({"multiplicative": true}),
				Book.Category.PENDING: LoudDict.Int.new({"multiplicative": false}),
			}
			sync = func(base) -> int:
				return (base + get_added() - get_subtracted()) * get_multiplied() / get_divided()
		Type.FLOAT:
			book = {
				Book.Category.ADDED: LoudDict.Float.new({"multiplicative": false}),
				Book.Category.SUBTRACTED: LoudDict.Float.new({"multiplicative": false}),
				Book.Category.MULTIPLIED: LoudDict.Float.new({"multiplicative": true}),
				Book.Category.DIVIDED: LoudDict.Float.new({"multiplicative": true}),
				Book.Category.PENDING: LoudDict.Float.new({"multiplicative": false}),
			}
			sync = func(base) -> float:
				return (base + get_added() - get_subtracted()) * get_multiplied() / get_divided()
		Type.BIG:
			book = {
				Book.Category.ADDED: LoudDict._Big.new({"multiplicative": false}),
				Book.Category.SUBTRACTED: LoudDict._Big.new({"multiplicative": false}),
				Book.Category.MULTIPLIED: LoudDict._Big.new({"multiplicative": true}),
				Book.Category.DIVIDED: LoudDict._Big.new({"multiplicative": true}),
				Book.Category.PENDING: LoudDict._Big.new({"multiplicative": false}),
			}
			sync = func(base) -> Big:
				return Big.new(base).add(get_added()).subtract(get_subtracted()).multiply(get_multiplied()).divide(get_divided())



#region Internal


#endregion


#region Action


func reset() -> void:
	for category in book:
		book[category].reset()
	#changed_cd.emit()


func edit_change(category: Book.Category, source, amount) -> void:
	book[category].edit(source, amount)
	if category != Book.Category.PENDING:
		emit_changed()
	else:
		pending_changed.emit()


func remove_change(category: Book.Category, source) -> void:
	book[category].erase(source)
	if category != Book.Category.PENDING:
		emit_changed()
	else:
		pending_changed.emit()


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


func add_powerer(base: Resource, exponent: Resource, offset := 0) -> void:
	var power_up = func():
		#printt("powering up. m: ", base.get_value(), " e: ", exponent.get_value() + offset, " == ", Big.new(base.get_value()).power(exponent.get_value() + offset).text)
		edit_change(
			Book.Category.MULTIPLIED,
			base,
			Big.new(base.get_value()).power(
				max(0, exponent.get_value() + offset)
			)
		)
	power_up.call()
	base.changed.connect(power_up)
	exponent.changed.connect(power_up)


#endregion


#region Get


func get_added():
	return book[Book.Category.ADDED].sum


func get_subtracted():
	return book[Book.Category.SUBTRACTED].sum


func get_multiplied():
	return book[Book.Category.MULTIPLIED].sum


func get_divided():
	return book[Book.Category.DIVIDED].sum


func get_pending():
	return book[Book.Category.PENDING].sum


static func is_category_multiplicative(_category: Book.Category) -> bool:
	return _category in [Book.Category.MULTIPLIED, Book.Category.DIVIDED]


static func is_category_additive(_category: Book.Category) -> bool:
	return _category in [Book.Category.ADDED, Book.Category.SUBTRACTED]


#endregion


#region Dev


func report() -> void:
	printt("Book Report (", self, ")")
	for category in book:
		var bv = call("get_" + Category.keys()[category].to_lower())
		if bv is Big:
			bv = bv.get_text()
		printt(" - ", Category.keys()[category], "(" + str(bv) + ")")
		for source in book[category].data.keys():
			if type == Type.BIG:
				printt("    - ", book[category].get_value(source).text, "(" + str(source) + ")")
			else:
				printt("    - ", book[category].get_value(source), "(" + str(source) + ")")
