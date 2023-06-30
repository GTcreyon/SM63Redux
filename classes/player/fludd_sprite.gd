extends AnimatedSprite2D
# Handles FLUDD pack visuals, including orienting the water spray effects.
#
# The heart of this script is the pose management system. Because a few (but
# only a few) player animations don't fit with the default FLUDD orientation,
# the pose system allows overriding FLUDD's animation and placement for a few
# specific player animations.
#
# The system is controlled from the POSE_FRAMES dictionary. Each entry in the
# dictionary is keyed to a player animation name, and contains either a pose
# definition, or an array of pose definitions (one per player animation frame).
#
# A pose definition is an array with the following elements in this order:
# - Animation name, string. The name of the animation FLUDD will use,
#	minus the prefixed nozzle name. E.G. the name "fly" would resolve to
#	the animation "hover_fly", "rocket_fly", or "turbo_fly", depending which
#	nozzle is currently equipped.
# - Offset, Vector2. How much FLUDD's position will be offset relative to the
#	player. The X offset will be inverted when the player's sprite is flipped.
#	E.G. Vector2(-5, 2) puts FLUDD 5px behind and 2px down from the player.
# - Z order, int. How FLUDD sorts relative to the player sprite. Typically
#	this should be set to 0, but if FLUDD should appear in front of the player,
#	a value of 1 should be used.
# - X flip, bool. Whether FLUDD should be flipped horizontally relative to the
#	player. If set, FLUDD is flipped only when the player isn't; if clear, FLUDD
#	is flipped only if the player is.
#		(NOTE: For ease of reading, we suggest setting this field to
#		NO_X_FLIP and X_FLIP rather than false and true.)
# - Sync, bool. When set, FLUDD's current animation is always on the same frame
#	as the player's animation--they become synced.
#	This can be useful for multi-pose animations with a constant offset
#	throughout.
#		(NOTE: For ease of reading, we suggest setting this field to
#		NO_SYNC and SYNC rather than false and true.)

# These are to help make pose definitions more readable.
const NO_X_FLIP = false
const X_FLIP = true

const NO_SYNC = false
const SYNC = true

# Commonly used poses.
# (Named after the player facing direction they go with,
# not the side of FLUDD facing the camera.)
const SPIN_FRONT = ["f", Vector2(0, -1), 0, NO_X_FLIP, NO_SYNC]
const SPIN_FRONT_RIGHT = ["fr", Vector2(-5, -1), 0, NO_X_FLIP, NO_SYNC]
const SPIN_RIGHT = ["r", Vector2(-8, -1), 0, NO_X_FLIP, NO_SYNC]
const SPIN_BACK_RIGHT = ["br", Vector2(-7, -1), 1, NO_X_FLIP, NO_SYNC]
const SPIN_BACK = ["b", Vector2(0, -1), 1, NO_X_FLIP, NO_SYNC]
const SPIN_BACK_LEFT = ["bl", Vector2(7, -1), 1, NO_X_FLIP, NO_SYNC]
const SPIN_LEFT = ["l", Vector2(8, -1), 0, NO_X_FLIP, NO_SYNC]
const SPIN_FRONT_LEFT = ["fl", Vector2(5, -1), 0, NO_X_FLIP, NO_SYNC]
const SPIN_SMEAR_BACK = ["spin_smear", Vector2.ZERO, 0, NO_X_FLIP, NO_SYNC]
const SPIN_SMEAR_FORE = ["spin_smear", Vector2.ZERO, 1, NO_X_FLIP, NO_SYNC]

const DEFAULT_OFFSET = Vector2(-5, 0)
const DEFAULT_POSE = ["fr", DEFAULT_OFFSET, 0, NO_X_FLIP, NO_SYNC]

# FLUDD's orientation is overridden for these player animations.
# Each frame should have one array entry.
const POSE_FRAMES = {
	"back": ["b", Vector2(0, 0), 1, NO_X_FLIP, NO_SYNC],
	"front": ["f", Vector2(0, 0), 0, NO_X_FLIP, NO_SYNC],
	"spin_start": [
		SPIN_SMEAR_BACK,
		SPIN_FRONT_RIGHT,
		SPIN_BACK_LEFT,
		SPIN_FRONT_RIGHT
	],
	"spin_water": SPIN_FRONT_RIGHT,
	"spin_fast": [ # 16 frames (8 identical), starts facing back-right, ccw rotation
		SPIN_BACK_RIGHT,
		SPIN_BACK,
		SPIN_BACK_LEFT,
		SPIN_LEFT,
		SPIN_FRONT_LEFT,
		SPIN_SMEAR_FORE,
		SPIN_FRONT_RIGHT,
		SPIN_RIGHT,
		SPIN_BACK_RIGHT,
		SPIN_BACK,
		SPIN_BACK_LEFT,
		SPIN_LEFT,
		SPIN_FRONT_LEFT,
		SPIN_SMEAR_BACK,
		SPIN_FRONT_RIGHT,
		SPIN_RIGHT,
	],
	"spin_slow": [ # exact duplicate of spin_fast
		SPIN_BACK_RIGHT,
		SPIN_BACK,
		SPIN_BACK_LEFT,
		SPIN_LEFT,
		SPIN_FRONT_LEFT,
		SPIN_FRONT,
		SPIN_FRONT_RIGHT,
		SPIN_RIGHT,
	],
	"crouch_start": ["crouch_start", DEFAULT_OFFSET, 0, NO_X_FLIP, SYNC],
	"crouch_end": ["crouch_end", DEFAULT_OFFSET, 0, NO_X_FLIP, SYNC],
	"dive_start": ["fr", Vector2(-3, 3), 0, NO_X_FLIP, SYNC],
	"dive_air": ["fr", Vector2(-3, 3), 0, NO_X_FLIP, SYNC],
	"dive_ground": ["fr", Vector2(-2, 3), 0, NO_X_FLIP, SYNC],
}
const SPRAY_ORIGIN = Vector2(-9, 6)
const SPRAY_ORIGIN_DIVE = SPRAY_ORIGIN + Vector2(1, 2)
const PLUME_ORIGIN = Vector2(-10, -2)
const PLUME_ORIGIN_DIVE = PLUME_ORIGIN + Vector2(1, 2)

@onready var player_sprite: AnimatedSprite2D = $".."
@onready var player_body: CharacterBody2D = $"../../.."
@onready var hover_sfx = $HoverSFX
@onready var hover_loop_sfx = $HoverLoopSFX
@onready var spray_particles = $"../../../SprayViewport/SprayParticles"
@onready var spray_plume = $"../../../SprayPlume"

var _nozzle: String = "hover"
var nozzle_fx_scale = 0
var hover_sound_position = 0


func _process(_delta) -> void:
	# FLUDD is visible if a nozzle is out
	visible = player_body.current_nozzle != Singleton.Nozzles.NONE
	
	# Lookup pose data using player animation
	# Use default if no pose is found.
	var cur_pose = POSE_FRAMES.get(player_sprite.animation, DEFAULT_POSE)
	# Table entries can be nested arrays--index by frame in that case.
	if cur_pose[0] is Array:
		cur_pose = cur_pose[player_sprite.frame]
	
	# Now, we can set FLUDD's appearance from looked-up orientation.
	
	# Load animation.
	animation = _nozzle + "_" + _pose_name(cur_pose)
	# If pose is set to sync with player, copy player's current frame.
	if _pose_sync_frames(cur_pose):
		frame = player_sprite.frame
	
	# Load sprite offset from the pose.
	offset = _pose_offset(cur_pose)
	
	# Flip based on character orientation
	flip_h = player_sprite.flip_h
	# Apply sprite flip flag.
	if _pose_flip_x(cur_pose):
		# Use the opposite of what the player has.
		flip_h = !flip_h
	
	# Invert X offset if sprite is flipped, even if by default.
	if flip_h:
		offset.x = -offset.x
	# Factor in player sprite offset, which is known to change per animation.
	offset += player_sprite.offset
	
	# Load Z override from the pose.
	z_index = _pose_z(cur_pose)	
	
	# Special rotation behavior if the player is diving.
	if player_body.state == player_body.S.DIVE:
		rotation = PI / 2 * player_body.facing_direction
	else:
		rotation = 0
	
	_hover_spray()


func _hover_spray() -> void:
	var is_hover_fludd = player_body.current_nozzle == Singleton.Nozzles.HOVER
	
	# Spray can last forever if diving or swimming; play looping sound.
	if player_body.state == player_body.S.DIVE or player_body.swimming:
		# Ensure that the non-looping sound doesn't play.
		hover_sfx.stop()
		
		# Spray is going. Play the sound.
		if player_body.fludd_strain and is_hover_fludd:
			if !hover_loop_sfx.playing:
				hover_loop_sfx.play(hover_sound_position)
		# Spray is not going. Don't play, but remember position in loop.
		else:
			hover_sound_position = hover_loop_sfx.get_playback_position()
			hover_loop_sfx.stop()
	# Spray lasts a finite duration in midair; play sound which ends.
	else:
		# Ensure that the looping sound doesn't play.
		hover_loop_sfx.stop()
		
		# Reset sound when reaching the end of the power bar,
		# or when switching off of the hover nozzle.
		if player_body.fludd_power > 99 or !is_hover_fludd:
			hover_sound_position = 0
			hover_sfx.stop()
		
		# Play sound if appropriate.
		if player_body.fludd_strain:
			if !hover_sfx.playing:
				hover_sfx.play(hover_sound_position)
		# Stop sound. Remember where we stopped, if midway through the power bar.
		else:
			# Memorize position, or reset it if power is maxed out.
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
	if player_body.state == player_body.S.DIVE:
		spray_pos = SPRAY_ORIGIN_DIVE
		plume_pos = PLUME_ORIGIN_DIVE
	else:
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


func _pose_name(pose: Array) -> String:
	return pose[0]


func _pose_offset(pose: Array) -> Vector2:
	return pose[1]


func _pose_z(pose: Array) -> int:
	return pose[2]


func _pose_flip_x(pose: Array) -> bool:
	return pose[3]


func _pose_sync_frames(pose: Array) -> bool:
	return pose[4]
