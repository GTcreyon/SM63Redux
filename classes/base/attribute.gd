extends Property

class_name Attribute

#not much here yet... TODO: Flesh out as needed

var attribute_conditions_met = false


func _ready():
	._ready()
	
func process_property(delta):
	.process_property(delta)
	if attribute_conditions_met == false:
		check_conditions()
		
func check_conditions():
	attribute_conditions_met = true # Override this method


func get_class():
	return "Attribute"
