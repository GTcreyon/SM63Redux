extends Node2D
class_name BaseModifier

var _id = 0
func get_id():
	_id += 1
	return _id

var items = {}

#calculate the total and set that as the property
func set_calculated_value(item, property):
	var value = items[item][property].base
	for mod in items[item][property].add:
		value += mod
	for mod in items[item][property].mul:
		value *= mod
	item[property] = value

#set the base value for a property
func set_base(item, property, base):
	if !items.has(item):
		items[item] = {}
	items[item][property] = {
		base = base,
		add = {},
		mul = {}
	}
	set_calculated_value(item, property)

#add a additive modifier
func add_modifier(item, property, add):
	if !items.has(item):
		set_base(item, property, item[property])
	var id = get_id()
	items[item][property].add[id] = add
	set_calculated_value(item, property)
	return id
	
#add a multiplying modifier
func mul_modifier(item, property, mul):
	if !items.has(item):
		set_base(item, property, item[property])
	var id = get_id()
	items[item][property].mul[id] = mul
	set_calculated_value(item, property)
	return id

#remove a property modifier
func remove_modifier(item, property, id):
	if !items.has(item):
		set_base(item, property, item[property])
	items[item][property].mul.erase(id)
	items[item][property].add.erase(id)
