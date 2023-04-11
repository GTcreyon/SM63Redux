extends AnimatedSprite
# FLUDD pack visuals

# Commonly used poses.
# (Named after the player facing direction they go with,
# not the side of FLUDD facing the camera.)
const POSE_FRONT = ["f", Vector2(0,-2), 0, false, false]
const POSE_FRONT_RIGHT = ["fr", Vector2(-2,-2), 0, false, false]
const POSE_RIGHT = ["r", Vector2(-8,-2), 0, false, false]
const POSE_BACK_RIGHT = ["br", Vector2(-2,-2), 1, false, false]
const POSE_BACK = ["b", Vector2(0,-2), 1, false, false]
const POSE_BACK_LEFT = ["bl", Vector2(2,-2), 1, true, false]
const POSE_LEFT = ["l", Vector2(8,-2), 1, true, false]
const POSE_FRONT_LEFT = ["fl", Vector2(2,-2), 1, true, false]

const DEFAULT_POSE = POSE_FRONT_RIGHT

# FLUDD's orientation is overridden for these player animations.
# Each frame should have one array entry.
# (NOTE: No reason to include the non-FLUDD variants, since FLUDD is
# hidden when those are in use!)
const POSE_FRAMES = {
	"back_fludd": POSE_BACK,
	"front_fludd": POSE_FRONT,
	"spin_fast_fludd": [ # 3 frames
		POSE_FRONT_RIGHT,
		POSE_FRONT,
		POSE_FRONT_LEFT
	],
	"spin_slow_fludd": [ # 8 frames, starts facing back, ccw rotation
		POSE_BACK,
		POSE_BACK_LEFT,
		POSE_LEFT,
		POSE_FRONT_LEFT,
		POSE_FRONT,
		POSE_FRONT_RIGHT,
		POSE_RIGHT,
		POSE_BACK_RIGHT,
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
	
	# Load offset from the pose.
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


func _pose_name(pose: Array) -> String:
	return pose[0]


func _pose_offset(pose: Array) -> Vector2:
	return pose[1]


func _pose_z(pose: Array) -> int:
	return pose[2]


func _pose_flip_x(pose: Array) -> bool:
	return pose[3]


func _pose_flip_y(pose: Array) -> bool:
	return pose[4]
