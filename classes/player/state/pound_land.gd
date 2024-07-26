extends PlayerState

const DURATION: int = 15

@export var effect_scene: PackedScene

var time: int


func _on_enter(_h):
	time = 0
	_anim(&"pound_land")
	# Dispatch star effect
	var fx = effect_scene.instantiate()
	get_parent().add_child(fx)
	fx.position = actor.position + Vector2.DOWN * 11
	fx.find_child("StarsAnim").play("GroundPound")
	
	# Dispatch pound thud
	# Begin by checking center for a collider
	actor = actor as CharacterBody2D
	var collider = actor.get_last_slide_collision().get_collider()
	
	# If a collider was found, play the thud.
	# TODO: SFX
	#if collider != null:
		# TODO: Put `terrain_typestring()` somewhere else. Not sure where yet.
		#play_sfx("pound", actor.terrain_typestring(collider))
	
	# TODO: Camera shake
	#camera.offset = Vector2(0, POUND_SHAKE_INITIAL)


func _all_ticks():
	time += 1


func _trans_rules():
	if time > DURATION:
		return &"Idle"
	return &""
