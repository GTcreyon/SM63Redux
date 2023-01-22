extends BaseObject

class_name Property

signal enable_property

var enabled: bool = false

var parent_object: GameObject = null


func _ready():
	if parent_object == null:
		yield(self, "enable_property")
	pass #use this to initialize your property, but make sure to also use ._ready()!!

func process_property(delta):
	#treat this like _physics_process()
	if enabled == false:
		pass
