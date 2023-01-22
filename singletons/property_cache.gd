extends GlobalObject

export(String) var properties_file_path = "res://properties"
export(String) var bodytype_directory = "/bodytypes"
export(String) var attribute_directory = "/attributes"

var property_cache: Dictionary = {"BodyType": {}, "Attribute": {}}

var dir = Directory.new()
func _ready():
	load_bodytypes()
	load_attributes()
	print("All Properties Loaded!")

#As much as I hate duplicated code, this has to stay. 
#Godot can't pass a class type as a function paramater (for now), 
#so we have to have two different functions to load both types of properties.

#TODO: USE ResourceInteractiveLoader INSTEAD OF load()!!

func load_attributes():
	for i in list_files_in_directory(properties_file_path + attribute_directory):
		if i == null: break
		var script = load(properties_file_path + attribute_directory + "/" + i)
		var attribute_node : Attribute = Attribute.new()
		attribute_node.set_script(script)
		property_cache["Attribute"][i.get_basename()] = attribute_node
	print("All Attributes Loaded!")


func load_bodytypes():
	for i in list_files_in_directory(properties_file_path + bodytype_directory):
		if i == null: break
		var script = load(properties_file_path + attribute_directory + "/" + i)
		var bodytype_node : BodyType = BodyType.new()
		bodytype_node.set_script(script)
		property_cache["BodyType"][i.get_basename()] = bodytype_node
	print("All BodyTypes Loaded!")

func get_available_properties(include_bodytypes: bool, include_attributes: bool) -> Array:
	var result: Array = []
	if include_bodytypes:
		var bodytype: Array = []
		for i in property_cache["BodyType"].keys():
			bodytype.append(i)
			result.append(bodytype)
	if include_attributes:
		var attrib: Array = []
		for i in property_cache["Attribute"].keys():
			attrib.append(i)
			result.append(attrib)
			
	return result
