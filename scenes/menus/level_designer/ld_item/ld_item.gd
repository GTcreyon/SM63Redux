class_name LDPlacedItem
extends Sprite2D

const GLOW_MATERIAL = preload("res://shaders/glow.tres")
## Dictionary of all active selection glow materials, keyed by atlas settings.[br]
##
## As of Godot 4.1, 2D materials cannot have properties set per usage.
## Thus, every item with unique atlas settings must have its own material.[br]
## 
## [br][b]Terms[/b][br]
## Atlas settings are currently defined as how many total cels are in the
## atlas texture before it's cut down to one cel,
## assuming the texture has a grid layout. 
## Eventually, it may be possible to set sprite offsets for each item's
## placed texture. At this point, atlas settings will have to also include
## sprite offsets.[br]
## A cel is one single sprite in a grid of sprites.[br]
## 
## [br][b]Typing[/b][br]
## As mentioned above, the dictionary is keyed by atlas settings. It does not
## store [Material] values, however--instead, it stores [WeakRef]s to materials.
## This way, the dictionary does not contribute to the materials' reference
## count, and thus a material with no items using it will be unloaded.
## The point of this dictionary is memory efficiency, after all--it wouldn't do
## to leak unused materials![br]
##
## [br][b]Why a dictionary?[/b][br]
## The naive method would be to give every selected object its own material.
## However, this would lead to duplicated materials en masse, since many objects
## share the same one-cel-per-texture atlas settings.
##
## To avoid memory waste, this dictionary stores existing glow material variants
## so that every item with the same atlas settings can reuse the same material.
## [br]
##
## [br][b]Considerations for the future[/b][br]
## As mentioned above, 2D materials may support per-instance uniforms at some
## point in the future. At that point, this dictionary can be removed.[br]
## 
static var active_glow_mats = {}

var item_id: int

var glow_factor = 1
var pulse = 0
var ghost = false # If true, item has not been placed yet.
var properties: Dictionary = {}

@onready var cam = $"/root/Main/Camera"
@onready var main = $"/root/Main"
@onready var control = $"/root/Main/UILayer/LDUI"
@onready var property_menu = $"/root/Main/UILayer/PropertyMenu"


func _ready():
	if ghost:
		modulate.a = 0.5
		position = main.snap_vector(get_global_mouse_position())
	
	# Size my hitbox to match my texture
	$ClickArea/CollisionShape2D.shape.size = texture.get_size()


func _input(event):
	# Instead of this guard, can we like disconnect the _input event?
	if !ghost:
		return
	
	if event.is_action_released("ld_place"):
		if Input.is_action_pressed("ld_keep_place"):
			# Copy this item in place
			var placed = duplicate()
			placed.item_id = item_id
			placed.properties = properties
			placed.position = position
			
			# Un-ghost the copy
			placed.modulate.a = 1
			placed.ghost = false
			
			# Put the copy in the scene
			get_parent().add_child(placed)
		else:
			# Un-ghost myself
			modulate.a = 1
			ghost = false
			# End placing-object state
			main.editor_state = main.EDITOR_STATE.IDLE
	elif event.is_action_released("ld_cancel_placement"):
		# Cancel placing me - delete myself and end placing state
		queue_free()
		main.editor_state = main.EDITOR_STATE.IDLE


func _process(_delta):
	if ghost:
		# Update my position to match the mouse
		position = main.snap_vector(get_global_mouse_position())
		properties["Position"] = position
	
	# If I have a glow material, apply visual effects.
	if material != null:
		# Make the glow outline pulse slowly.
		pulse = fmod((pulse + 0.1), 2 * PI)
		material.set_shader_parameter("outline_color", Color(1, 1, 1, (sin(pulse) * 0.25 + 0.5) * glow_factor))


func set_property(label, value) -> void:
	properties[label] = value
	update_visual_property(label, value)


func update_visual_property(label, value) -> void:
	match label:
		"Disabled":
			item_disabled_tint(value)
		"Scale":
			scale = value
		"Position":
			position = value
		"Rotation":
			rotation_degrees = float(value)
		"Mirror":
			flip_h = value


func set_glowing(should_glow):
	if should_glow:
		# Glow material needed. Fetch the properly configured one from the
		# materials dictionary.
		
		# In order to index into the glow materials dictionary,
		# we need to know how many cels there are in this sprite's
		# texture atlas.
		# So, begin by calculating that.
		
		# Set cel count (# of rows/columns) based on what type the texture is.
		# By default, assume entire image is one cel.
		var cel_count := Vector2.ONE
		# If the source image is from an atlas, instead calculate the number of
		# cels based on atlas and cel sizes.
		if texture is AtlasTexture:
			var trimmed_tex = texture as AtlasTexture
			cel_count = trimmed_tex.atlas.get_size() / trimmed_tex.get_size()
		
		# Index into the dictionary of loaded material variants.
		var loaded_mat: WeakRef = active_glow_mats.get(cel_count)
		
		# If the material isn't preloaded, create it and add to the dictionary.
		if loaded_mat == null or loaded_mat.get_ref() == null:
			var new_mat = GLOW_MATERIAL.duplicate(false)
			# Set the material's cel count--this is why we use multiple mats
			# in the first place!
			new_mat.set_shader_parameter("cel_count", cel_count)
			# Apply the new material now so the reference stays alive.
			material = new_mat
			# Save the new material to the global dictionary.
			active_glow_mats[cel_count] = weakref(new_mat)
		# If it is preloaded, use it, of course!
		else:
			material = loaded_mat.get_ref()
	else:
		# Glow material no longer needed.
		# Thankfully, removing it is much less of an ordeal.
		material = null


func item_disabled_tint(disabled) -> void:
	var val = 0.5 if disabled else 1.0
	modulate.r = val
	modulate.g = val
	modulate.b = val
