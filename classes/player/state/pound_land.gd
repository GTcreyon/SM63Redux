extends PlayerState

const SPRITE_OFFSET: float = 3
const DURATION: int = 15

@export var effect_scene: PackedScene
@export var pound_hitbox: Hitbox = null

var time: int


func _on_enter(_h):
	actor.sprite.offset.y = SPRITE_OFFSET

	# Start a short hit so breakable floors can break properly.
	pound_hitbox.start_hit()
	time = 0
	_anim(&"pound_land")
	# Dispatch star effect
	var fx = effect_scene.instantiate()
	get_parent().add_child(fx)
	fx.position = actor.position + Vector2.DOWN * 11
	fx.find_child("StarsAnim").play("GroundPound")
	
	# Dispatch pound thud
	# Begin by checking for a collider
	actor = actor as CharacterBody2D
	var collider = actor.get_last_slide_collision().get_collider()
	
	# If a collider was found, play the thud.
	# TODO: SFX
	#if collider != null:
		# TODO: Put `terrain_typestring()` somewhere else. Not sure where yet.
		#play_sfx("pound", actor.terrain_typestring(collider))
	
	actor.camera.shake(Vector2(0, 6), 3.0, 10.0)


func _all_ticks():
	time += 1
	if time > 1:
		pound_hitbox.stop_hit()


func _on_exit():
	actor.sprite.offset.y = 0


func _trans_rules():
	if input.buffered_input(&"jump"):
		return &"JumpDouble"
	if not actor.is_on_floor():
		return &"PoundFall"
	if time > DURATION:
		return &"Idle"
	return &""
