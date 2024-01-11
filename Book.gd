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

signal renewed

var book := {
	Book.Category.ADDED: {},
	Book.Category.SUBTRACTED: {},
	Book.Category.MULTIPLIED: {},
	Book.Category.DIVIDED: {},
	Book.Category.PENDING: {},
}

@export var pending := 0.0

var added := 0.0
var subtracted := 0.0
var multiplied := 1.0
var divided := 1.0



#region Action


func reset() -> void:
	book.clear()
	added = 0.0
	subtracted = 0.0
	multiplied = 1.0
	divided = 1.0
	pending = 0.0
	renewed.emit()
	emit_changed()


func add_change(category: Book.Category, source, amount: float) -> void:
	if book[category].has(source):
		if gv.dev_mode:
			print_debug("This source already logged a change for this LoudInt (", self, ")! Fix your code you hack fraud.")
		return
	book[category][source] = amount
	match category:
		Book.Category.ADDED:
			added += amount
		Book.Category.SUBTRACTED:
			subtracted += amount
		Book.Category.MULTIPLIED:
			multiplied *= amount
		Book.Category.DIVIDED:
			divided /= amount
		Book.Category.PENDING:
			pending += amount
	emit_changed()


# This has the functionality to be the only method of these 3 you'd need to use!
# If you want to temporarily add 3 to this int,
# call edit_change(Book.Category.ADDED, self, 3) -- simple as that!

# Note that specifically for this class, multiplying by a float could be pretty weird!
# But because the book tracks the logs, it will be fine once you remove_change().
# Also beware this int's limit!


func edit_change(category: Book.Category, source, amount) -> void:
	var effectively_removing := false
	if category in [Book.Category.MULTIPLIED, Book.Category.DIVIDED] and is_equal_approx(amount, 1.0):
		effectively_removing = true
	elif category in [Book.Category.ADDED, Book.Category.SUBTRACTED] and is_zero_approx(amount):
		effectively_removing = true
	
	if book[category].has(source):
		remove_change(category, source, effectively_removing)
	if not effectively_removing:
		add_change(category, source, amount)


func remove_change(category: Book.Category, source, sync_afterwards := true) -> void:
	if not source in book[category].keys():
		return
	var amount: int = book[category][source]
	match category:
		Book.Category.ADDED:
			added -= amount
		Book.Category.SUBTRACTED:
			subtracted -= amount
		Book.Category.MULTIPLIED:
			multiplied /= amount
		Book.Category.DIVIDED:
			divided /= amount
		Book.Category.PENDING:
			pending -= amount
	book[category].erase(source)
	if sync_afterwards:
		emit_changed()


#endregion


#region Get


func get_changed_value_int(base: int) -> int:
	return int((base + added - subtracted) * multiplied / divided)


func get_changed_value_float(base: float) -> float:
	return (base + added - subtracted) * multiplied / divided


func get_changed_value_big(base: Dictionary) -> Big:
	# remove if not using a Big number class
	return Big.new(base).a(added).s(subtracted).m(multiplied).d(divided)


#endregion
