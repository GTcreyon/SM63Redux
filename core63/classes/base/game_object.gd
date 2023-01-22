extends Node
class_name GameObject

#TODO: GameObject is getting divided up.
#Duplicate these variables and functions and move them to the new game object classes.

var attributes: Array = []
var body_types: Array = []
var property_queue: Array = [] #ordered list of properties to be executed on the current frame
var default_properties: PoolStringArray = []

func _physics_process(delta):
	pass

func add_property(property): #property can be either a single string or a PoolStringArray
	if property.get_class() == "String":
		pass
	elif property.get_class() == "Array":
		pass
