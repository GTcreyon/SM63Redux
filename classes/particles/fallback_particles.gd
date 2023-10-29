class_name FallbackParticles
extends GPUParticles2D
## Compatibility class that swaps GPU particles out for CPU particles on devices that don't support it.
## Might be worth making an engine proposal for this kind of thing, since this is somewhat hacky.

## Flags that ensure that the property is editor-accessible and also stored in the scene file.
## If it's not both of those, then there's no point copying it over.
const USAGE_FLAGS = 6

## The replacement CPUParticles2D node.
var _replacement: CPUParticles2D = null

## If true, _set() and _get() will not redirect to the replacement.
var _dont_redirect: bool = false


func _ready():
	# Check if the device is missing a video adapter (GPU)
	if OS.get_video_adapter_driver_info().is_empty():
		# Temporarily disable redirection so we can work.
		_dont_redirect = true
		
		# Create a CPU node and copy properties over.
		_replacement = CPUParticles2D.new()
		_copy_properties()
		
		# Replace this node.
		replace_by.call_deferred(_replacement)
		
		# Rename the replacement to hide the change.
		_replacement.name = name
		
		# Re-enable redirection.
		_dont_redirect = false


## Copy properties from the current node to the replacement.
func _copy_properties() -> void:
	_replacement.convert_from_particles(self)
	
	for property in get_property_list():
		var prop_name = property.name
		if property.usage != USAGE_FLAGS:
			continue
		if prop_name in _replacement:
			_replacement.set(prop_name, get(prop_name))


## Redirect property setting to the replacement node.
func _set(property, value):
	if property == &"_dont_redirect":
		return false
	
	if _replacement == null:
		return false
	
	_replacement.set(property, value)
	return true


## Redirect property getting to the replacement node.
func _get(property):
	if property == &"_dont_redirect":
		return null
	
	if _dont_redirect:
		return null
	
	if _replacement == null:
		return null
	
	if !property in _replacement:
		return null
	
	for prop in get_property_list():
		if prop.name != property:
			continue
		
		if prop.usage != USAGE_FLAGS:
			return null
	
	return _replacement.get(property)
