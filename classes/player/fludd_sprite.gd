extends AnimatedSprite
# FLUDD pack visuals

# Data about FLUDD's orientation
enum Orient {
	# "Meaning bits" - components of facing directions
	X_FLIP = 1, # flip opposite player sprite, instead of with
	SORT_ABOVE = 2,
	SIDE = 4, # hover heads are exactly aligned, only one visible
	FACING = 8, # hover heads are on the camera plane - used for back too
	THREE_QTR = 4 | 8,
	
	# Definitions of FLUDD's placement for each player orientation
	# For these, facing right = unflipped.
	FRONT = 8,
	FRONT_RIGHT = 4 | 8,
	RIGHT = 4,
	BACK_RIGHT = 4 | 8 | 2,
	BACK = 8 | 2,
	BACK_LEFT = 4 | 8 | 1 | 2,
	LEFT = 4 | 1,
	FRONT_LEFT = 4 | 8 | 1,
}

const DEFAULT_ORIENT = Orient.FRONT_RIGHT
const DEFAULT_OFFSET = Vector2(-2, -2)

# FLUDD's orientation is overridden for these player animations.
# Each frame should have one array entry.
# (NOTE: No reason to include the non-FLUDD variants, since FLUDD is
# hidden when those are in use!)
const ORIENT_FRAMES = {
	"back_fludd": Orient.BACK,
	"front_fludd": Orient.FRONT,
	"spin_fast_fludd": [ # 3 frames
		Orient.FRONT_RIGHT,
		Orient.FRONT,
		Orient.FRONT_LEFT
	],
	"spin_slow_fludd": [ # 8 frames, starts facing back, ccw rotation
		Orient.BACK,
		Orient.BACK_LEFT,
		Orient.LEFT,
		Orient.FRONT_LEFT,
		Orient.FRONT,
		Orient.FRONT_RIGHT,
		Orient.RIGHT,
		Orient.BACK_RIGHT,
	],
}
const SPRAY_ORIGIN = Vector2(-9, 6)
const PLUME_ORIGIN = Vector2(-10, -2)

onready var player_sprite: AnimatedSprite = $".."
onready var player_body: KinematicBody2D = $"../../.."
onready var hover_sfx = $HoverSFX
onready var hover_loop_sfx = $HoverLoopSFX
onready var spray_particles = $"../../../SprayViewport/SprayParticles"
onready var spray_plume = $"../../../SprayPlume"

var _nozzle: String = "hover"
var nozzle_fx_scale = 0
var hover_sound_position = 0


func _process(_delta) -> void:
	# Visible if a nozzle is out
	visible = player_body.current_nozzle != Singleton.Nozzles.NONE
	
	# Flip based on character orientation
	flip_h = player_sprite.flip_h
	# Behind the player sprite by default
	z_index = 0
	
	# Lookup orientation overrides using player animation
	# (If FLUDD is visible, player animation will definitely end in "_fludd"--
	# so indexing with the raw anim name will be fine.)
	# Use default if no override is found.
	var cur_orient = ORIENT_FRAMES.get(player_sprite.animation, DEFAULT_ORIENT)
	# Table entries can be arrays--index by frame in that case.
	if cur_orient is Array:
		cur_orient = cur_orient[player_sprite.frame]
	
	# Now, we can set FLUDD's appearance from looked-up orientation.
	
	# Clear offset so we're always starting from the right place.
	offset = DEFAULT_OFFSET
	
	# Set Z index by in-front flag.
	if (cur_orient & Orient.SORT_ABOVE) != 0:
		z_index = 1
	
	# Determine which sprite should be shown.
	# (Explanation: Orient.THREE_QTR has two bits set, so masking by it will
	#  return both side and facing bits.
	#  The sprites will only trigger if, even with both bits in the mask,
	#  ONLY their bit is found to be set.)
	var facing_front: bool = cur_orient & Orient.THREE_QTR == Orient.FACING
	var facing_side: bool = cur_orient & Orient.THREE_QTR == Orient.SIDE
	
	# Set proper sprite and offset from direction.
	if facing_front:
		if z_index == 1:
			animation = _nozzle + "_back"
		else:
			animation = _nozzle + "_front"
		offset.x = 0
	elif facing_side:
		animation = _nozzle + "_side"
		offset.x = -8
	else: # 3-quarter view, default
		if z_index == 1:
			animation = _nozzle + "_sideback"
		else:
			animation = _nozzle
		# Don't set offset, let default value remain.
	
	# Factor in player sprite offset, which is known to change per animation.
	offset += player_sprite.offset
	
	# Apply sprite flip flag.
	if (cur_orient & Orient.X_FLIP) != 0:
		# Use the opposite of what the player has.
		flip_h = !flip_h
	# Invert X offset if sprite is flipped, even if by default.
	if flip_h:
		offset.x = -offset.x
	
	if player_body.state == player_body.S.DIVE:
		rotation = PI / 2
	else:
		rotation = 0
	
	_hover_spray()


func _hover_spray() -> void:
	if player_body.state == player_body.S.DIVE or player_body.swimming:
		hover_sfx.stop()
		if player_body.fludd_strain:
			if !hover_loop_sfx.playing:
				hover_loop_sfx.play(hover_sound_position)
		else:
			hover_sound_position = hover_loop_sfx.get_playback_position()
			hover_loop_sfx.stop()
	else:
		hover_loop_sfx.stop()
		if player_body.fludd_power > 99:
			hover_sound_position = 0
			hover_sfx.stop()
			
		if player_body.fludd_strain:
			if !hover_sfx.playing:
				hover_sfx.play(hover_sound_position)
		else:
			if player_body.fludd_power < 100:
				hover_sound_position = hover_sfx.get_playback_position()
			else:
				hover_sound_position = 0
			if !player_body.fludd_spraying():
				hover_sfx.stop()
	
	spray_particles.emitting = player_body.fludd_strain
	if player_body.fludd_strain:
		nozzle_fx_scale = min(lerp(0.3, 1, player_body.fludd_power / 100), nozzle_fx_scale + 0.1)
	else:
		nozzle_fx_scale = max(0, nozzle_fx_scale - 0.25)
	spray_plume.visible = nozzle_fx_scale > 0
	spray_plume.scale = Vector2.ONE * nozzle_fx_scale

	var spray_pos: Vector2
	var plume_pos: Vector2
	# Offset spray effect relative to player's center
	spray_pos = SPRAY_ORIGIN
	plume_pos = PLUME_ORIGIN
	# Factor in facing direction
	spray_pos *= Vector2(player_body.facing_direction, 1)
	plume_pos *= Vector2(player_body.facing_direction, 1)
	# Rotate positions with sprite, so they stay aligned
	var rot = player_sprite.rotation
	if player_body.state == player_body.S.DIVE:
		rot += PI / 2 * player_body.facing_direction
		# Offset position when diving
		var offset_amount = 7 * player_body.facing_direction
		spray_pos.x += offset_amount
		plume_pos.x += offset_amount
	spray_pos = spray_pos.rotated(rot)
	plume_pos = plume_pos.rotated(rot)
	# Particles are in global space, move them to player-relative position
	spray_pos += player_body.position
	# Apply spray and plume positions
	spray_particles.position = spray_pos
	spray_plume.position = plume_pos
	# Apply rotations
	spray_particles.rotation = rot
	spray_plume.rotation = rot


func switch_nozzle(current_nozzle: int) -> void:
	match current_nozzle:
		Singleton.Nozzles.HOVER:
			_nozzle = "hover"
		Singleton.Nozzles.ROCKET:
			_nozzle = "rocket"
		Singleton.Nozzles.TURBO:
			_nozzle = "turbo"
