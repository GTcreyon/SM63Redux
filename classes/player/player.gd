extends KinematicBody2D

const FPS_MOD = 32.0 / 60.0 # Multiplier to account for 60fps

const SFX_BANK = { # bank of sfx to be played with play_sfx()
	"step": {
		"grass": [
			preload("res://classes/player/sfx/step/grass/step_grass_0.wav"),
			preload("res://classes/player/sfx/step/grass/step_grass_1.wav"),
			preload("res://classes/player/sfx/step/grass/step_grass_2.wav"),
			preload("res://classes/player/sfx/step/grass/step_grass_3.wav"),
		],
		"generic": [
			preload("res://classes/player/sfx/step/generic/step_generic_0.wav"),
			preload("res://classes/player/sfx/step/generic/step_generic_1.wav"),
			preload("res://classes/player/sfx/step/generic/step_generic_2.wav"),
			preload("res://classes/player/sfx/step/generic/step_generic_3.wav"),
			preload("res://classes/player/sfx/step/generic/step_generic_4.wav"),
			preload("res://classes/player/sfx/step/generic/step_generic_5.wav"),
			preload("res://classes/player/sfx/step/generic/step_generic_6.wav"),
			preload("res://classes/player/sfx/step/generic/step_generic_7.wav"),
			preload("res://classes/player/sfx/step/generic/step_generic_8.wav"),
			preload("res://classes/player/sfx/step/generic/step_generic_9.wav"),
			preload("res://classes/player/sfx/step/generic/step_generic_10.wav"),
			preload("res://classes/player/sfx/step/generic/step_generic_11.wav"),
			preload("res://classes/player/sfx/step/generic/step_generic_12.wav"),
			preload("res://classes/player/sfx/step/generic/step_generic_13.wav"),
		],
		"metal": [
			preload("res://classes/player/sfx/step/metal/step_metal_0.wav"),
			preload("res://classes/player/sfx/step/metal/step_metal_1.wav"),
			preload("res://classes/player/sfx/step/metal/step_metal_2.wav"),
			preload("res://classes/player/sfx/step/metal/step_metal_3.wav"),
			preload("res://classes/player/sfx/step/metal/step_metal_4.wav"),
			preload("res://classes/player/sfx/step/metal/step_metal_5.wav"),
			preload("res://classes/player/sfx/step/metal/step_metal_6.wav"),
			preload("res://classes/player/sfx/step/metal/step_metal_7.wav"),
			preload("res://classes/player/sfx/step/metal/step_metal_8.wav"),
			preload("res://classes/player/sfx/step/metal/step_metal_9.wav"),
		],
		"snow": [
			preload("res://classes/player/sfx/step/snow/step_snow_0.wav"),
			preload("res://classes/player/sfx/step/snow/step_snow_1.wav"),
			preload("res://classes/player/sfx/step/snow/step_snow_2.wav"),
			preload("res://classes/player/sfx/step/snow/step_snow_3.wav"),
			preload("res://classes/player/sfx/step/snow/step_snow_4.wav"),
		],
		"cloud": [
			preload("res://classes/player/sfx/step/cloud/step_cloud_0.wav"),
			preload("res://classes/player/sfx/step/cloud/step_cloud_1.wav"),
		],
		"ice": [
			preload("res://classes/player/sfx/step/ice/step_ice_0.wav"),
			preload("res://classes/player/sfx/step/ice/step_ice_1.wav"),
		],
	},
	"voice": {
		"jump1": [
			preload("res://classes/player/sfx/mario/jump_single/jump_single_0.wav"),
			preload("res://classes/player/sfx/mario/jump_single/jump_single_1.wav"),
		],
		"jump2": [
			preload("res://classes/player/sfx/mario/jump_double/jump_double_0.wav"),
			preload("res://classes/player/sfx/mario/jump_double/jump_double_1.wav"),
			preload("res://classes/player/sfx/mario/jump_double/jump_double_2.wav"),
		],
		"jump3": [
			preload("res://classes/player/sfx/mario/jump_triple/jump_triple_0.wav"),
			preload("res://classes/player/sfx/mario/jump_triple/jump_triple_1.wav"),
			preload("res://classes/player/sfx/mario/jump_triple/jump_triple_2.wav"),
			preload("res://classes/player/sfx/mario/jump_triple/jump_triple_3.wav"),
			preload("res://classes/player/sfx/mario/jump_triple/jump_triple_4.wav"),
			preload("res://classes/player/sfx/mario/jump_triple/jump_triple_5.wav"),
			preload("res://classes/player/sfx/mario/jump_triple/jump_triple_6.wav"),
			preload("res://classes/player/sfx/mario/jump_triple/jump_triple_7.wav"),
		],
		"dive": [
			preload("res://classes/player/sfx/mario/dive/dive_0.wav"),
			preload("res://classes/player/sfx/mario/dive/dive_1.wav"),
			preload("res://classes/player/sfx/mario/dive/dive_2.wav"),
			preload("res://classes/player/sfx/mario/dive/dive_3.wav"),
		],
	},
	"pound": {
		"grass": [
			preload("res://classes/player/sfx/pound/pound_grass.wav")
		],
		"generic": [
			preload("res://classes/player/sfx/pound/pound_generic.wav")
		],
		"metal": [
			preload("res://classes/player/sfx/pound/pound_generic.wav")
		],
		"snow": [
			preload("res://classes/player/sfx/pound/pound_snow.wav")
		],
		"cloud": [
			preload("res://classes/player/sfx/pound/pound_cloud.wav")
		],
		"ice": [
			preload("res://classes/player/sfx/pound/pound_generic.wav")
		],
	}
}

onready var base_modifier = BaseModifier.new()
onready var voice = $Voice
onready var step = $Step
onready var thud = $Thud
onready var pound_spin_sfx = $PoundSpin
onready var sprite = $Character
onready var fludd_sprite = $Character/Fludd
onready var camera = $"/root/Main/Player/Camera"
onready var step_check = $StepCheck
onready var angle_cast = $DiveAngling
onready var hitbox =  $Hitbox
onready var water_check = $WaterCheck
onready var bubbles: Particles2D = $"BubbleViewport/Bubbles"
onready var nozzle_fx = $NozzleStream
onready var bubbles_viewport = $BubbleViewport
onready var switch_sfx = $SwitchSFX
onready var hover_sfx = $HoverSFX
onready var hover_loop_sfx = $HoverLoopSFX
onready var dust = $Dust
onready var ground_failsafe_check: Area2D = $GroundFailsafe
onready var feet_area: Area2D = $Feet

var ground_pound_effect = preload("res://classes/player/ground_pound_effect.tscn")

# vars to lock mechanics
var invuln_frames: int = 0
var locked: bool = false

# visual vars
var last_step = 0
var invuln_flash: int = 0

func _ready():
	sprite.playing = true
	nozzle_fx.playing = true
	var warp = $"/root/Singleton/Warp"
	switch_state(S.NEUTRAL) # reset state to avoid short mario glitch
	if Singleton.set_location != null:
		position = Singleton.set_location
		warp.set_location = null
		sprite.flip_h = warp.flip


func _process(delta):
	manage_water_audio(delta)


func _physics_process(_delta):
	if locked:
		locked_behaviour()
	else:
		player_physics()
	fixed_visuals()


func _on_BackupAngle_body_entered(_body):
	solid_floors += 1


func _on_BackupAngle_body_exited(_body):
	solid_floors -= 1


var water_areas: int = 0
func _on_WaterCheck_area_entered(_area):
	swimming = true
	switch_state(S.NEUTRAL)
	Singleton.water = max(Singleton.water, 100)
	water_areas += 1


func _on_WaterCheck_area_exited(_area):
	water_areas -= 1
	if water_areas <= 0:
		swimming = false
		if vel.y < 0 and !fludd_strain and !is_spinning():
			vel.y -= 3

# player physics constants
const GP_DIVE_TIME = 6
const GROUND_FAILSAFE_THRESHOLD: int = 10

# player physics var
var vel = Vector2.ZERO
var state = S.NEUTRAL
var fludd_strain = false
var invincible = false

# secondary states
var swimming = false
var bouncing = false

enum S { # state enum
	NEUTRAL = 1 << 0,
	BACKFLIP = 1 << 1,
	SPIN = 1 << 2,
	DIVE = 1 << 3,
	ROLLOUT = 1 << 4,
	POUND = 1 << 5,
	TRIPLE_JUMP = 1 << 6,
	HURT = 1 << 7,
}

enum Pound {
	SPIN,
	FALL,
	LAND,
}

const GRAV: float = FPS_MOD
const JUMP_VEL_1: float = 10 * FPS_MOD
const JUMP_VEL_2: float = 12.5 * FPS_MOD
const JUMP_VEL_3: float = 15 * FPS_MOD
const DOUBLE_JUMP_TIME: int = 8
var grounded: bool = false
var ground_except: bool = false
var dive_resetting: bool = false
var frontflip_dir_left: bool = false
var double_anim_cancel: bool = false
var double_jump_state: int = 0
var double_jump_frames: int = 0
var pound_land_frames: int = 0
var pound_state: int = Pound.SPIN
var solid_floors: int = 0
func player_physics():
	fludd_stale = true
	
	check_ground_state()
	
	manage_invuln()
	manage_buffers()
	manage_dive_recover()
	manage_triple_flip()
	manage_backflip_flip()
	manage_hurt_recover()
	
	if Input.is_action_just_pressed("switch_fludd"):
		switch_fludd()
	
	if swimming:
		Singleton.water = max(Singleton.water, 100)
		Singleton.power = 100

	
	if coyote_frames > 0:
		coyote_behaviour()
	else:
		if !swimming:
			airborne_anim()
		if Input.is_action_pressed("left") == Input.is_action_pressed("right"):
			vel.x = resist(vel.x, 0, 1.001) # Air decel
	
	action_spin()
	
	if bouncing:
		action_bounce()
	else:
		player_fall()
		if swimming:
			action_swim()
		else:
			if Input.is_action_pressed("jump"):
				if coyote_frames > 0:
					player_jump()
				elif jump_vary_frames > 0 and state == S.NEUTRAL:
					vel.y -= GRAV * pow(FPS_MOD, 3) # Variable jump height
	
	player_control_x()
	if swimming:
		adjust_swim_x()
	fludd_control()
	
	action_dive()
	action_pound()
	
	wall_stop()
	
	player_move()
	
	if state == S.POUND and is_on_floor():
		vel.x = 0 # stop sliding down into holes


func start_bounce() -> void:
	bouncing = true
	bounce_frames = 0


var full_bounce: bool = false
var bounce_frames: int = 0
func action_bounce() -> void:
	vel.y = 0
	if Input.is_action_just_pressed("jump"):
		full_bounce = true
	bounce_frames += 1
	if bounce_frames >= 12:
		if state == S.DIVE:
			off_ground()
			dive_correct(-1)
			switch_state(S.ROLLOUT)
			switch_anim("jump")
			frontflip_dir_left = sprite.flip_h
			vel.y = min(-JUMP_VEL_1/1.5, vel.y)
			double_jump_state = 0
		else:
			if Input.is_action_pressed("jump"):
				if full_bounce:
					vel.y = -6.5
				else:
					vel.y = -6
			else:
				vel.y = -5
			switch_state(S.NEUTRAL)
		bouncing = false


var swim_delay: bool = false
func action_swim() -> void:
	if Input.is_action_just_pressed("jump") or Input.is_action_pressed("semi"):
		if state == S.NEUTRAL:
			switch_anim("swim")
			vel.y = min(-4.25, vel.y)
			sprite.frame = 1
			sprite.speed_scale = 1
			swim_delay = true
		elif state == S.SPIN:
			switch_state(S.NEUTRAL)
			vel.y = min(-4.25, vel.y)
			vel.x = min(abs(vel.x) + 1.5, 8) * sign(vel.x)
		elif (
			state == S.DIVE
			and Input.is_action_pressed("jump")
			and (
				(
					(
						int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
					) == 1.0
					and sprite.flip_h
				)
				or
				(
					(
						int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
					) == -1.0
					and !sprite.flip_h
				)
			)
		):
			action_backflip()
	else:
		swim_delay = false
	
	if Input.is_action_pressed("down"):
		vel.y += 0.125


func adjust_swim_x() -> void:
	var swim_adjust = vel.x
	swim_adjust = resist(swim_adjust, 0.05, 1.05)
	vel.x += (swim_adjust - vel.x) * FPS_MOD


var hover_sound_position = 0
var nozzle_fx_scale = 0
func fixed_visuals() -> void:
	if swimming and state == S.NEUTRAL and !grounded and !Input.is_action_pressed("spin"):
		switch_anim("swim")
		if sprite.frame == 0:
			sprite.speed_scale = 0
	if state == S.DIVE or swimming:
		hover_sfx.stop()
		if fludd_strain:
			if !hover_loop_sfx.playing:
				hover_loop_sfx.play(hover_sound_position)
		else:
			hover_sound_position = hover_loop_sfx.get_playback_position()
			hover_loop_sfx.stop()
	else:
		hover_loop_sfx.stop()
		if Singleton.power > 99:
			hover_sound_position = 0
			hover_sfx.stop()
			
		if fludd_strain:
			if !hover_sfx.playing:
				hover_sfx.play(hover_sound_position)
		else:
			if Singleton.power < 100:
				hover_sound_position = hover_sfx.get_playback_position()
			else:
				hover_sound_position = 0
			if !fludd_spraying():
				hover_sfx.stop()
	
	bubbles.emitting = fludd_strain
	
	if fludd_strain:
		nozzle_fx_scale = min(lerp(0.3, 1, Singleton.power / 100), nozzle_fx_scale + 0.1)
	else:
		nozzle_fx_scale = max(0, nozzle_fx_scale - 0.25)
	nozzle_fx.visible = nozzle_fx_scale > 0
	nozzle_fx.scale = Vector2.ONE * nozzle_fx_scale

	var bubblepos = position
	if state == S.DIVE:
		bubblepos.y += -9
		if sprite.flip_h:
			bubblepos.x += -1
		else:
			bubblepos.x += 1
	else:
		bubblepos.y += -2
		if sprite.flip_h:
			bubblepos.x += 10
		else:
			bubblepos.x += -10
	# offset bubbles to mario's center
	bubbles.position = bubblepos
	# relative to parent unlike bubbles, so make position local
	nozzle_fx.position = bubblepos - position
	
	bubbles.rotation = sprite.rotation
	nozzle_fx.rotation = sprite.rotation
	
	if abs(vel.x) < 2:
		dust.emitting = false
	else:
		dust.emitting = is_on_floor()
		
	if sprite.animation.begins_with("walk"):
		if int(vel.x) == 0:
			sprite.frame = 0
			sprite.speed_scale = 0
			step_sound()
		else:
			if sprite.speed_scale == 0:
				sprite.frame = 1
			sprite.speed_scale = min(abs(vel.x / 3.43), 2)
			step_sound()
		last_step = sprite.frame
	elif !sprite.animation.begins_with("swim"):
		sprite.speed_scale = 1
	
	#$Label.text = str(vel.x)
	if Singleton.hp <= 0:
		Singleton.dead = true
	
	fludd_sprite.flip_h = sprite.flip_h
	if sprite.animation.begins_with("spin"):
		match sprite.frame:
			1:
				if !fludd_sprite.animation.ends_with("front"):
					fludd_sprite.animation = fludd_sprite.animation + "_front"
			2:
				if fludd_sprite.animation.ends_with("front"):
					fludd_sprite.animation = fludd_sprite.animation.substr(0, fludd_sprite.animation.length() - 6)
				fludd_sprite.flip_h = !sprite.flip_h
	if fludd_sprite.animation.ends_with("front"):
		fludd_sprite.offset.x = 0
	else:
		if fludd_sprite.flip_h:
			fludd_sprite.offset.x = 2
		else:
			fludd_sprite.offset.x = -2


const WALL_BOUNCE = 0.19
func wall_stop() -> void:
	if is_on_wall():
		if int(vel.x) != 0:
			if int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")) != sign(int(vel.x)):
				vel.x = -vel.x * WALL_BOUNCE # Bounce off a wall when not intentionally pushing into it
			else:
				vel.x = 0 # Cancel X velocity when intentionally pushing into a wall
	if is_on_ceiling():
		vel.y = max(vel.y, 0.1)


const POUND_TIME_TO_FALL = 15 # Time to move from pound spin to pound fall
const POUND_SPIN_DURATION = 9 # Time the spin animation lasts
const POUND_SPIN_SMOOTHING = 0.5 # Range from 0 to 1
const POUND_SPIN_RISE = 1 # How much the player rises each frame of pound
const POUND_ORIGIN_OFFSET = Vector2(-3,-4) # Sprite origin is set to this during pound spin

var pound_spin_frames: int = 0
func action_pound() -> void:
	if state == S.POUND and pound_state == Pound.SPIN:
		pound_spin_frames += 1
		# Spin frames normalized from 0-1.
		# Min makes it stop after one full spin.
		var pound_spin_factor = min(float(pound_spin_frames) / POUND_SPIN_DURATION, 1)
		# Blend between 0% and 100% smoothed animation.
		pound_spin_factor = lerp(pound_spin_factor, sqrt(pound_spin_factor), POUND_SPIN_SMOOTHING)
		
		# Move sprite origin for nicer rotation animation
		set_rotation_origin(sprite.flip_h, POUND_ORIGIN_OFFSET)
		# Offset origin's X less at the start of the spin. (Looks better!?)
		sprite.dejitter_position *= Vector2(pound_spin_factor, 1)
		# A little rising as we wind up makes it look real nice.
		sprite.dejitter_position.y -= POUND_SPIN_RISE * pound_spin_frames
		
		# Set rotation according to position in the animation.
		sprite.rotation = TAU * pound_spin_factor
		# Adjust rotation depending on our facing direction.
		sprite.rotation *= -1 if sprite.flip_h else 1
		
		# Begin windup state once the spin ends
		if pound_spin_frames == POUND_SPIN_DURATION:
			switch_anim("pound_windup")
		
		# Once spin animation ends, fall.
		if pound_spin_frames >= POUND_TIME_TO_FALL:
			# Reset sprite transforms.
			clear_rotation_origin()
			
			sprite.rotation = 0
			
			pound_state = Pound.FALL
			vel.y = 8


	if Input.is_action_pressed("pound"):
		if state == S.DIVE and gp_dive_timer > 0:
			var mag = vel.length()
			var ang
			if vel.x > 0:
				ang = PI / 5
			else:
				ang = PI - PI / 5
			vel = Vector2(cos(ang) * mag, sin(ang) * mag)
		else:
			if (
				!swimming
				and
				!grounded
				and (
					state & (
						S.NEUTRAL
						| S.TRIPLE_JUMP
						| S.SPIN
						| S.BACKFLIP
						| S.ROLLOUT
					)
					or
					(
						state == S.DIVE
						and Input.is_action_just_pressed("pound")
					)
				)
			):
				switch_state(S.POUND)
				pound_state = Pound.SPIN
				switch_anim("flip")
				sprite.rotation = 0
				pound_spin_frames = 0
				pound_spin_sfx.play()


const SPIN_TIME = 30
var spin_frames = 0
func action_spin() -> void:
	if state == S.SPIN:
		if spin_frames > 0:
			spin_frames -= 1
		elif !Input.is_action_pressed("spin"):
			switch_state(S.NEUTRAL)
			
	if (
		Input.is_action_pressed("spin")
		and (
			state == S.NEUTRAL
			or (state == S.ROLLOUT and Input.is_action_just_pressed("spin"))
		)
		and (vel.y > -3.3 * FPS_MOD or state == S.ROLLOUT or swimming)
	):
		switch_state(S.SPIN)
		switch_anim("spin")
		if !grounded:
			if swimming:
				vel.y = min(-2, vel.y)
			else:
				vel.y = min(-3.5 * FPS_MOD * 1.3, vel.y - 3.5 * FPS_MOD)
		spin_frames = SPIN_TIME


var _fludd_spraying: bool = false
var _fludd_spraying_rising: bool = false
# If _physics_process() never calls player_physics() but checks fludd_spraying(),
# keep initial value as valid to avoid runtime crashes.
var fludd_stale: bool = false

func fludd_spraying(allow_stale: bool = false) -> bool:
	# Every frame, set fludd_stale = true until we process "fludd".
	# When reading "did we hover this frame",
	# ensure we have already processed hovering this frame.
	if !allow_stale:
		assert(!fludd_stale)
	return _fludd_spraying


func fludd_spraying_rising(allow_stale: bool = false) -> bool:
	if !allow_stale:
		assert(!fludd_stale)
	return _fludd_spraying_rising

var rocket_charge: int = 0
func fludd_control():
	fludd_stale = false
	_fludd_spraying = false
	_fludd_spraying_rising = false
	
	if grounded:
		Singleton.power = 100 # TODO: multi fludd
	elif !Input.is_action_pressed("fludd") and Singleton.nozzle != Singleton.n.hover:
		Singleton.power = min(Singleton.power + FPS_MOD, 100)
	if (
		Input.is_action_pressed("fludd")
		and Singleton.power > 0
		and Singleton.water > 0
		and state & (
				S.NEUTRAL
				| S.BACKFLIP
				| S.TRIPLE_JUMP
				| S.DIVE
			)
	):
		_fludd_spraying = true
		match Singleton.nozzle:
			Singleton.n.hover:
				fludd_strain = true
				double_anim_cancel = true
				if state != S.DIVE:
					_fludd_spraying_rising = true
				if state != S.TRIPLE_JUMP or (abs(sprite.rotation_degrees) < 90 or abs(sprite.rotation_degrees) > 270):
					if state & (S.DIVE | S.TRIPLE_JUMP):
						vel.y *= 1 - 0.02 * FPS_MOD
						vel.x *= 1 - 0.03 * FPS_MOD
						if grounded:
							vel.x += cos(sprite.rotation - PI / 2)*pow(FPS_MOD, 2)
						elif state == S.DIVE:
							vel.y += sin(sprite.rotation - PI / 2)*0.92*pow(FPS_MOD, 2)
							vel.x += cos(sprite.rotation - PI / 2)/2*pow(FPS_MOD, 2)
						else:
							if sprite.flip_h:
								vel.y += sin(-sprite.rotation - PI / 2)*0.92*pow(FPS_MOD, 2)
								vel.x -= cos(-sprite.rotation - PI / 2)*0.92/2*pow(FPS_MOD, 2)
							else:
								vel.y += sin(sprite.rotation - PI / 2)*0.92*pow(FPS_MOD, 2)
								vel.x += cos(sprite.rotation - PI / 2)*0.92/2*pow(FPS_MOD, 2)
					else:
						if Singleton.power == 100 and !swimming:
							vel.y -= 2
						
						if Input.is_action_pressed("jump"):
							vel.y *= 1 - (0.13 * FPS_MOD)
						else:
							vel.y *= 1 - (0.2 * FPS_MOD)
						if swimming:
							vel.y -= 0.75
						else:
							vel.y -= (((-4*Singleton.power*vel.y * FPS_MOD * FPS_MOD) + (-525*vel.y * FPS_MOD) + (368*Singleton.power * FPS_MOD * FPS_MOD) + (48300)) / 7000) * pow(FPS_MOD, 5)
						vel.x = resist(vel.x, 0.05, 1.03)
					if !swimming:
						Singleton.water = max(0, Singleton.water - 0.07 * FPS_MOD)
						Singleton.power -= 1.5 * FPS_MOD
			Singleton.n.rocket:
				if Singleton.power == 100:
					fludd_strain = true
					rocket_charge += 1
				else:
					fludd_strain = false
				if rocket_charge >= 14 / FPS_MOD and (state != S.TRIPLE_JUMP or ((abs(sprite.rotation_degrees) < 20 or abs(sprite.rotation_degrees) > 340))):
					_fludd_spraying_rising = true
					if state == S.DIVE:
						# set sign of velocity (could use ternary but they're icky)
						var multiplier = 1
						if sprite.flip_h:
							multiplier = -1
						if grounded:
							multiplier *= 2 # Double power when grounded to counteract friction
						vel += Vector2(cos(sprite.rotation)*25*FPS_MOD * FPS_MOD * multiplier, -sin(sprite.rotation - PI / 2) * 25 * FPS_MOD * FPS_MOD)
					else:
						vel.y = min(max((vel.y/3),0) - 15.3, vel.y)
						vel.y -= 0.5 * FPS_MOD
					
					rocket_charge = 0
					
					if !swimming:
						Singleton.water = max(Singleton.water - 5, 0)
						Singleton.power = 0
	else:
		fludd_strain = false
		rocket_charge = 0


const WALK_ACCEL: float = 1.1 * FPS_MOD
const AIR_ACCEL: float = 5.0 * FPS_MOD # Functions differently to WALK_ACCEL
const AIR_SPEED_CAP: float = 20.0 * FPS_MOD
func player_control_x() -> void:
	var i_right = Input.is_action_pressed("right")
	var i_left = Input.is_action_pressed("left")
	if i_left != i_right:
		var dir = int(i_right) - int(i_left)
		if state != S.POUND or pound_state != Pound.SPIN:
			if (
				state & (
					S.NEUTRAL
					| S.SPIN
					| S.TRIPLE_JUMP
					| S.ROLLOUT
				)
			):
				sprite.flip_h = dir == -1 # flip sprite according to direction
			if (grounded or (state & (S.ROLLOUT | S.BACKFLIP | S.DIVE | S.NEUTRAL) and ground_except)) and !swimming:
				if state == S.POUND:
					vel.x = 0
				elif state != S.DIVE:
					vel.x += dir * WALK_ACCEL
			else:
				var core_vel = dir * max((AIR_ACCEL - dir * vel.x) / (AIR_SPEED_CAP / (3 * FPS_MOD)), 0)
				if state & (S.TRIPLE_JUMP | S.SPIN | S.BACKFLIP | S.HURT):
					vel.x += core_vel / (1.5 / FPS_MOD)
				elif state & (S.DIVE | S.ROLLOUT):
					vel.x += core_vel / (8 / FPS_MOD)
				elif state == S.POUND:
					vel.x += core_vel / (2 / FPS_MOD)
				else:
					vel.x += core_vel


const TRIPLE_FLIP_TIME: int = 54
var triple_flip_frames: int = 0
func manage_triple_flip() -> void:
	if state == S.TRIPLE_JUMP:
		triple_flip_frames += 1
		var dir = 1
		if sprite.flip_h:
			dir = -1
		var multiplier = 1
		if Singleton.nozzle == Singleton.n.none:
			multiplier = 2
		sprite.rotation = dir * multiplier * TAU * ease_out_quart(float(triple_flip_frames) / TRIPLE_FLIP_TIME)
		if triple_flip_frames >= TRIPLE_FLIP_TIME:
			switch_state(S.NEUTRAL)
			sprite.rotation = 0


func player_jump() -> void:
	if state == S.DIVE:
		if (
			(
				(
					int(Input.is_action_pressed("right"))
					- int(Input.is_action_pressed("left")) != -1
				)
				and
				!sprite.flip_h
			)
			or
			(
				(
					int(Input.is_action_pressed("right"))
					- int(Input.is_action_pressed("left")) != 1
				)
				and
				sprite.flip_h
			)
		):
			if !dive_resetting and abs(vel.x) >= 1 and !is_on_wall(): # prevents static dive recover
				action_rollout()
		else:
			action_backflip()
	elif (jump_buffer_frames > 0
		and
		state &
			(
				S.NEUTRAL
				| S.BACKFLIP
				| S.ROLLOUT
				| S.BACKFLIP
				| S.TRIPLE_JUMP
				| S.SPIN
			)
		):
		action_jump()


const TRIPLE_JUMP_DEADZONE = 2.0 * FPS_MOD
func action_jump() -> void:
	jump_buffer_frames = 0
	jump_vary_frames = JUMP_VARY_TIME
	double_jump_frames = DOUBLE_JUMP_TIME
	off_ground()
	match double_jump_state:
		0: # Single
			switch_state(S.NEUTRAL)
			play_sfx("voice", "jump1")
			vel.y = -JUMP_VEL_1
			double_jump_state += 1
		1: # Double
			switch_state(S.NEUTRAL)
			vel.y = -JUMP_VEL_2
			play_sfx("voice", "jump2")
			double_jump_state += 1
		2: # Triple
			if abs(vel.x) > TRIPLE_JUMP_DEADZONE:
				vel.y = -JUMP_VEL_3
				vel.x += (vel.x + 15 * FPS_MOD * sign(vel.x)) / 5 * FPS_MOD
				double_jump_state = 0
				switch_state(S.TRIPLE_JUMP)
				play_sfx("voice", "jump3")
				triple_flip_frames = 0
				frontflip_dir_left = sprite.flip_h
			else:
				vel.y = -JUMP_VEL_2
				play_sfx("voice", "jump2")
	
	# warning-ignore:return_value_discarded
	move_and_collide(Vector2(0, -3)) # helps jumps feel more responsive


func ease_out_quart(x: float) -> float: # for replacing tweens
	return 1 - pow(1 - x, 4) # https://easings.net/#easeOutQuart <3


const BACKFLIP_FLIP_TIME: int = 36
var backflip_flip_frames: int = 0
func manage_backflip_flip() -> void:
	if state == S.BACKFLIP:
		backflip_flip_frames += 1
		var dir = -1
		if sprite.flip_h:
			dir = 1
		sprite.rotation = dir * TAU * sin(((float(backflip_flip_frames) / BACKFLIP_FLIP_TIME) * PI) / 2)
		if backflip_flip_frames >= BACKFLIP_FLIP_TIME:
			switch_state(S.NEUTRAL)
			sprite.rotation = 0


func action_backflip() -> void:
	if !dive_resetting:
		dive_correct(-1)
	off_ground()
	switch_state(S.BACKFLIP)
	vel.y = min(-JUMP_VEL_1 - 2.5 * FPS_MOD, vel.y)
	if sprite.flip_h:
		vel.x += (30.0 - abs(vel.x)) / (5 / FPS_MOD)
	else:
		vel.x -= (30.0 - abs(vel.x)) / (5 / FPS_MOD)
	dive_resetting = false
	backflip_flip_frames = 0
	switch_anim("jump")
	frontflip_dir_left = sprite.flip_h


func action_rollout() -> void:
	off_ground()
	dive_correct(-1)
	switch_state(S.ROLLOUT)
	vel.y = min(-JUMP_VEL_1/1.5, vel.y)
	switch_anim("jump")
	frontflip_dir_left = sprite.flip_h


func coyote_behaviour() -> void:
	double_anim_cancel = false
				
	if state == S.NEUTRAL:
		switch_anim("walk")
	
	# warning-ignore:narrowing_conversion
	double_jump_frames = max(double_jump_frames - 1, 0)
	if double_jump_frames <= 0:
		double_jump_state = 0
	
	if grounded: # specifically apply to when actually on the ground, not coyote time
		manage_pound_recover()
		vel.y = 0
		if swimming:
			if state == S.DIVE:
				vel.x = resist(vel.x, 0.2, 1.02) # Floor friction
		else:
			ground_friction()
	
		if state & (S.TRIPLE_JUMP | S.BACKFLIP): # Reset state when landing
			switch_state(S.NEUTRAL)
			sprite.rotation = 0
		
		if state == S.DIVE and abs(vel.x) < 1 and !Input.is_action_pressed("dive") and !dive_resetting:
			reset_dive()


var hurt_timer = 0
func manage_hurt_recover():
	if state == S.HURT:
		if grounded or hurt_timer <= 0:
			switch_state(S.NEUTRAL)
			switch_anim("walk")
		else:
			hurt_timer -= 1


var cancel_ground: bool = false
func check_ground_state() -> void:
	if cancel_ground:
		grounded = false
		cancel_ground = false
	else:
		# failsafe to prevent getting stuck between slopes
		if (
			vel.y < 0
			or is_on_floor()
			or fludd_spraying_rising(true)
			or (state == S.POUND and pound_state == Pound.SPIN)
			or state == S.HURT
			or swimming
			or bouncing
			or ground_failsafe_check.get_overlapping_bodies().size() <= 0
		):
			ground_failsafe_timer = 0
		grounded = is_on_floor() or ground_failsafe_timer >= GROUND_FAILSAFE_THRESHOLD
	ground_except = grounded


func player_fall() -> void:
	var fall_adjust = vel.y # used to adjust downward acceleration to account for framerate difference
	if state == S.POUND and pound_state == Pound.SPIN:
		vel = Vector2.ZERO
	else:
		if state == S.POUND and pound_state == Pound.FALL:
			fall_adjust += 0.814
		else:
			if swimming:
				if !Input.is_action_pressed("spin"):
					fall_adjust += GRAV / 3.0
			else:
				fall_adjust += GRAV
		
		if !grounded:
			if swimming:
				fall_adjust = water_resistance(fall_adjust)
			else:
				fall_adjust = air_resistance(fall_adjust)
		
		vel.y += (fall_adjust - vel.y) * FPS_MOD # Adjust the Y velocity according to the framerate


func ground_friction() -> void:
	if state == S.DIVE:
		if double_jump_frames >= DOUBLE_JUMP_TIME - 1:
			vel.x = resist(vel.x, 0.2, 1.02) # Double friction on landing
		vel.x = resist(vel.x, 0.2, 1.02) # Floor friction
		if !dive_resetting:
			manage_dive_angle()
	else:
		if double_jump_frames >= DOUBLE_JUMP_TIME - 1:
			vel.x = resist(vel.x, 0.3, 1.15) # Double friction on landing
		vel.x = resist(vel.x, 0.3, 1.15) # Floor friction


func water_resistance(fall_adjust) -> float:
	# classic source black box
	fall_adjust = resist(fall_adjust, 0.05, 1.01);
	fall_adjust = resist(fall_adjust, ((GRAV/FPS_MOD)/5), 1.05)
	fall_adjust = resist(fall_adjust, 0, 1.001)
	
	vel.x = resist(vel.x, 0, 1.001)
	if Input.is_action_pressed("left") == Input.is_action_pressed("right") or state == S.DIVE:
		vel.x = resist(vel.x, 0, 1.001)
		
	return fall_adjust


func air_resistance(fall_adjust) -> float:
	if state == S.POUND and pound_state == Pound.FALL:
		pound_land_frames = 15
	if fall_adjust > 0:
		fall_adjust = resist(fall_adjust, ((GRAV/FPS_MOD)/5), 1.05)
	fall_adjust = resist(fall_adjust, 0, 1.001)
	if state == S.SPIN:
		fall_adjust = resist(fall_adjust, 0.1, 1.03)
	vel.x = resist(vel.x, 0, 1.001) # Air friction
	return fall_adjust


func manage_dive_angle() -> void:
	if angle_cast.is_colliding():
		var angle_offset = 0
		if sprite.flip_h:
			angle_offset = 0
		else:
			angle_offset = PI
		sprite.rotation = lerp_angle(sprite.rotation, angle_cast.get_collision_normal().angle() + angle_offset, 0.5)
	elif solid_floors > 0:
		if sprite.flip_h:
			sprite.rotation = -PI / 2
		else:
			sprite.rotation = PI / 2


func reset_dive() -> void:
	sprite.rotation = 0
	dive_resetting = true
	dive_reset_frames = 0


func airborne_anim() -> void:
	if state == S.TRIPLE_JUMP:
		if Singleton.nozzle == Singleton.n.none:
			if abs(sprite.rotation_degrees) < 700:
				switch_anim("flip")
			else:
				switch_anim("fall")
		else:
			if abs(sprite.rotation_degrees) < 340:
				switch_anim("flip")
			else:
				switch_anim("fall")
	elif state == S.NEUTRAL:
		if vel.y > 0:
			switch_anim("fall")
		else:
			if double_jump_state == 2 and !double_anim_cancel:
				switch_anim("jump_double")
			else:
				switch_anim("jump")
	elif state == S.POUND and pound_state == Pound.FALL:
		switch_anim("pound_fall")
	elif state == S.DIVE:
		if sprite.flip_h:
			sprite.rotation = lerp_angle(sprite.rotation, -atan2(vel.y, -vel.x) - PI / 2, 0.5)
		else:
			sprite.rotation = lerp_angle(sprite.rotation, atan2(vel.y, vel.x) + PI / 2, 0.5)

const POUND_LAND_DURATION = 12
const POUND_SHAKE_INITIAL = 4
const POUND_SHAKE_MULTIPLIER = 0.75
func manage_pound_recover() -> void:
	if state == S.POUND:
		if pound_land_frames == 12: # just hit ground
			pound_state = Pound.LAND
			switch_anim("flip")
			
			# Dispatch star effect
			var fx = ground_pound_effect.instance()
			get_parent().add_child(fx)
			fx.global_position = sprite.global_position + Vector2.DOWN * 11
			fx.find_node("StarsAnim").play("GroundPound")
			
			# Dispatch pound thud
			var collider: CollisionObject2D = step_check.get_collider()
			if collider != null:
				play_sfx("pound", terrain_typestring(collider))
			
			# Jolt camera downwards
			camera.offset = Vector2(0, POUND_SHAKE_INITIAL)
		elif pound_land_frames <= 0: # impact ended, get up
			switch_state(S.NEUTRAL)
			# Nullify all camera shake.
			camera.offset = Vector2.ZERO
		else: # just handle camera shake
			# Shake goes up on even frames, down on odd frames.
			var shake_sign = 1 if pound_land_frames % 2 else -1
			# Shake is less strong every frame that passes.
			# (Another branch takes the land_frames == 0 case--
			# no illegal divisions here!)
			var shake_magnitude = float(pound_land_frames) / POUND_LAND_DURATION
			# But a square-root falloff lets you feel it longer.
			shake_magnitude = sqrt(shake_magnitude)
			
			shake_magnitude *= POUND_SHAKE_INITIAL
			camera.offset = Vector2(0, shake_magnitude * shake_sign)
		# warning-ignore:narrowing_conversion
		pound_land_frames = max(0, pound_land_frames - 1)


func player_move() -> void:
	var snap = get_snap()
	
	# store the current position in advance
	var save_pos = position
	# warning-ignore:return_value_discarded
	move_and_slide_with_snap(vel * 60.0, snap, Vector2(0, -1), true)
	
	# check how far that moved the player
	var slide_vec = position-save_pos
	# if the player isn't grounded despite being stopped moving downwards, increment the failsafe
	if abs(slide_vec.y) < 0.5 and vel.y > 0 and !is_on_floor() and ground_failsafe_check.get_overlapping_bodies().size() > 0:
		# warning-ignore:narrowing_conversion
		ground_failsafe_timer = min(ground_failsafe_timer + 1, GROUND_FAILSAFE_THRESHOLD)
	
	# ensure the player moves the intended horizontal distance
	if (
		slide_vec.x >= 0.5
		and is_on_floor()
	):
		position = save_pos
		# warning-ignore:return_value_discarded
		move_and_slide_with_snap(Vector2(vel.x * 60.0 * (vel.x / slide_vec.x), vel.y * 60.0), snap, Vector2(0, -1), true, 4, deg2rad(47))


func get_snap() -> Vector2:
	if (
		!grounded
		or Input.is_action_just_pressed("jump")
		or jump_buffer_frames > 0
		or state == S.ROLLOUT
		or state == S.HURT
		or fludd_spraying_rising()
		or
		(
			swimming
			and Input.is_action_pressed("semi")
		)
	):
		return Vector2.ZERO
	else:
		return Vector2(0, 4)


const DIVE_VEL = 35.0 * FPS_MOD
func action_dive():
	if (
		Input.is_action_pressed("dive")
		and
		(
			state & (
				S.TRIPLE_JUMP
				| S.NEUTRAL
				| S.BACKFLIP
			)
			or
			(
				Input.is_action_just_pressed("dive")
				and
				(
					(
						state == S.ROLLOUT # allows for tighter dive turns
						and sprite.flip_h != frontflip_dir_left
					)
					or
					state == S.SPIN
				)
			)
		)
		and
		(
			!swimming
			or
			grounded
		)
	):
		if !swimming and coyote_frames > 0 and Input.is_action_pressed("jump") and abs(vel.x) > 1: # auto rollout
			off_ground()
			dive_correct(-1)
			switch_state(S.ROLLOUT)
			switch_anim("jump")
			frontflip_dir_left = sprite.flip_h
			vel.y = min(-JUMP_VEL_1/1.5, vel.y)
			double_jump_state = 0
		elif (
			state & (
				S.NEUTRAL
				| S.SPIN
				| S.TRIPLE_JUMP
			)
			or
			(
				state == S.BACKFLIP
				and abs(sprite.rotation) > PI / 2 * 3
			)
		):
			if !grounded:
				gp_dive_timer = 6
				off_ground()
				if state != S.TRIPLE_JUMP:
					play_sfx("voice", "dive")
				var multiplier = 1
				if state == S.BACKFLIP:
					multiplier = 2 # allows dives out of backflips to be more responsive
				if sprite.flip_h: # idrk how this works
					vel.x -= (DIVE_VEL - abs(vel.x / FPS_MOD)) / (5 / FPS_MOD) / FPS_MOD * multiplier
				else:
					vel.x += (DIVE_VEL - abs(vel.x / FPS_MOD)) / (5 / FPS_MOD) / FPS_MOD * multiplier
				if state == S.NEUTRAL:
					vel.y = max(-3, vel.y + 3.0 * FPS_MOD)
				else:
					vel.y += 3.0 * FPS_MOD
			if (!grounded or vel.y >= 0) and (!swimming or grounded):
				switch_state(S.DIVE)
				if sprite.flip_h:
					sprite.rotation = -PI / 2
				else:
					sprite.rotation = PI / 2
				switch_anim("dive")
				double_jump_state = 0
				dive_correct(1)


const FADE_TIME = 10
var fade_timer = 0
onready var lowpass = AudioServer.get_bus_effect(0, 0)
onready var reverb: AudioEffectReverb = AudioServer.get_bus_effect(0, 1)
func manage_water_audio(delta):
	if swimming:
		fade_timer = min(fade_timer + delta * 60, FADE_TIME)
	else:
		fade_timer = max(fade_timer - delta * 60, 0)
	reverb.wet = 0.25 * fade_timer / FADE_TIME
	lowpass.cutoff_hz = int((2000 - 20500) * fade_timer / FADE_TIME + 20500)
	AudioServer.set_bus_effect_enabled(0, 0, fade_timer != 0)
	AudioServer.set_bus_effect_enabled(0, 1, fade_timer != 0)


const ROLLOUT_TIME: int = 18
const DIVE_RESET_TIME: int = 8
var rollout_frames: int = 0
var dive_reset_frames: int = 0
func manage_dive_recover():
	if state == S.ROLLOUT:
		rollout_frames += 1
		if sprite.flip_h:
			sprite.rotation = -rollout_frames * TAU / ROLLOUT_TIME
		else:
			sprite.rotation = rollout_frames * TAU / ROLLOUT_TIME
		if rollout_frames >= ROLLOUT_TIME or grounded:
			switch_state(S.NEUTRAL)
			sprite.rotation = 0
			rollout_frames = 0
	elif dive_resetting:
		dive_reset_frames += 1
		# warning-ignore:integer_division
		if dive_reset_frames >= DIVE_RESET_TIME / 2:
			if !sprite.animation.begins_with("jump"):
				switch_anim("jump")
				dive_correct(-1)
				hitbox.position = STAND_BOX_POS
				hitbox.shape.extents = STAND_BOX_EXTENTS
			if sprite.flip_h:
				sprite.rotation = dive_reset_frames * PI / 2 / DIVE_RESET_TIME - PI / 2
			else:
				sprite.rotation = -dive_reset_frames * PI / 2 / DIVE_RESET_TIME + PI / 2
			if dive_reset_frames >= DIVE_RESET_TIME:
				dive_resetting = false
				switch_state(S.NEUTRAL)
				sprite.rotation = 0
		else:
			if sprite.flip_h:
				sprite.rotation = dive_reset_frames * PI / 2 / DIVE_RESET_TIME
			else:
				sprite.rotation = -dive_reset_frames * PI / 2 / DIVE_RESET_TIME


func switch_fludd():
	var save_nozzle = Singleton.nozzle
	Singleton.nozzle += 1
	while (
		(
			Singleton.nozzle < 4
			and !Singleton.collected_nozzles[(Singleton.nozzle - 1) % 3]
		)
		or Singleton.nozzle == 0
	):
		Singleton.nozzle += 1
	if Singleton.nozzle == 4:
		Singleton.nozzle = 0
	if Singleton.nozzle != save_nozzle:
		# lazy way to refresh fludd anim
		var anim = sprite.animation.replace("_fludd", "")
		switch_anim(anim)
		fludd_strain = false
		switch_sfx.play()


const COYOTE_TIME: int = 5
const JUMP_VARY_TIME: int = 13
var sign_frames: int = 0
var ground_failsafe_timer: int = 0
var gp_dive_timer: int = 0
var coyote_frames: int = 0
var jump_buffer_frames: int = 0
var jump_vary_frames: int = 0
# manage "buffers" - coyote time, buffered jumps
func manage_buffers():
	# warning-ignore:narrowing_conversion
	sign_frames = max(sign_frames - 1, 0)
	
	if grounded:
		coyote_frames = COYOTE_TIME
	else:
		# warning-ignore:narrowing_conversion
		coyote_frames = max(coyote_frames - 1, 0)
	
	# warning-ignore:narrowing_conversion
	gp_dive_timer = max(gp_dive_timer - 1, 0)
	
	if Input.is_action_pressed("jump"):
		# warning-ignore:narrowing_conversion
		jump_buffer_frames = max(jump_buffer_frames - 1, 0)
		if Input.is_action_just_pressed("jump"):
			jump_buffer_frames = 6
	else:
		jump_buffer_frames = 0
		
	# warning-ignore:narrowing_conversion
	jump_vary_frames = max(jump_vary_frames - 1, -1)


var collect_frames: int = 0
var collect_pos_init = Vector2.INF
var collect_pos_final = Vector2.INF
var read_pos_x: float = INF
func locked_behaviour():
	if read_pos_x != INF:
		global_position.x = read_pos_x + (global_position.x - read_pos_x) * 0.75
	if collect_pos_final != Vector2.INF:
		switch_anim("spin")
		position = collect_pos_init + sin(min(collect_frames / 230.0, 1) * PI / 2) * (collect_pos_final - collect_pos_init)
		collect_frames += 1
		if collect_frames >= 230:
			switch_anim("shine")
			if collect_frames >= 310:
				$"/root/Singleton/WindowWarp".warp(Vector2(), "res://scenes/title/title.tscn", 40)


func manage_invuln():
	if invuln_frames > 0:
		invuln_frames -= 1
		modulate.a = (sin(2 * PI * invuln_flash / 10.0) + 3) / 4
		invuln_flash += 1
	else:
		modulate.a = 1
		invuln_flash = 0


const STAND_BOX_POS = Vector2(0, 1.5)
const STAND_BOX_EXTENTS = Vector2(6, 14.5)
const DIVE_BOX_POS = Vector2(0, 3)
const DIVE_BOX_EXTENTS = Vector2(6, 6)
func switch_state(new_state):
	state = new_state
	sprite.rotation_degrees = 0
	match state:
		S.DIVE:
			hitbox.position = DIVE_BOX_POS
			hitbox.shape.extents = DIVE_BOX_EXTENTS
		S.POUND:
			hitbox.position = STAND_BOX_POS
			hitbox.shape.extents = STAND_BOX_EXTENTS
			camera.smoothing_speed = 10
		_:
			hitbox.position = STAND_BOX_POS
			hitbox.shape.extents = STAND_BOX_EXTENTS
			camera.smoothing_speed = 5
			clear_rotation_origin()


func switch_anim(new_anim):
	var fludd_anim
	var anim
	if new_anim == "fall":
		last_step = 1 # ensures that the step sound will be made when hitting the ground
	anim = new_anim
	
	if Singleton.nozzle == Singleton.n.none:
		fludd_sprite.visible = false # hides the fludd sprite
	else:
		fludd_sprite.visible = true
		fludd_anim = new_anim + "_fludd"
		if sprite.frames.has_animation(fludd_anim): # ensures the belt animation exists
			anim = fludd_anim
		else:
			anim = new_anim
			Singleton.log_msg("Missing animation: " + fludd_anim, Singleton.LogType.ERROR)
	
	match Singleton.nozzle: # TODO - multi fludd
		Singleton.n.hover:
			fludd_sprite.animation = "hover"
		Singleton.n.rocket:
			fludd_sprite.animation = "rocket"
		Singleton.n.turbo:
			fludd_sprite.animation = "turbo"
	
	sprite.animation = anim


func take_damage(amount):
	if invuln_frames <= 0 and !locked:
		Singleton.hp = clamp(Singleton.hp - amount, 0, 8) # TODO - multi HP
		invuln_frames = 180


func take_damage_shove(amount, direction):
	if invuln_frames <= 0 and !locked:
		take_damage(amount)
		switch_state(S.HURT)
		hurt_timer = 30
		switch_anim("hurt")
		clear_rotation_origin()
		vel = Vector2(4 * direction, -3)
		sprite.flip_h = direction == 1
		off_ground()


func off_ground():
	coyote_frames = 0
	grounded = false
	cancel_ground = true


func recieve_health(amount):
	Singleton.hp = clamp(Singleton.hp + amount, 0, 8) # TODO - multi HP


const DIVE_CORRECTION = 7
func dive_correct(factor): # Correct the player's origin position when diving
	# warning-ignore:return_value_discarded
	move_and_slide(Vector2(0, DIVE_CORRECTION * factor * 60), Vector2(0, -1))
	if factor == -1:
		dust.position.y = 11.5
		ground_failsafe_check.position.y = 17
	else:
		dust.position.y = 11.5 - DIVE_CORRECTION
		ground_failsafe_check.position.y = 17 - DIVE_CORRECTION
#	base_modifier.add_modifier(
#		camera,
#		"position",
#		"dive_correction",
#		Vector2(
#			0,
#			min(0, -DIVE_CORRECTION * factor)
#		)
#	)
	# camera.position.y = min(0, -set_dive_correct * factor)


func play_sfx(type, group):
	var sound_set = SFX_BANK[type][group]
	var sound = sound_set[randi() % sound_set.size()]
	match type:
		"voice":
			voice.stream = sound
			voice.play(0)
		"step":
			step.stream = sound
			step.play(0)
		"pound":
			thud.stream = sound
			thud.play(0)


const TERRAIN_MASK = 0b111111110000000000000000
func terrain_typestring(collider: CollisionObject2D) -> String:
	var layer = (collider.collision_layer & TERRAIN_MASK) >> 16
	match layer:
		0b10000000:
			return "grass"
		0b01000000:
			return "metal"
		0b00100000:
			return "snow"
		0b00010000:
			return "cloud"
		0b00001000:
			return "ice"
		_:
			return "generic"


func step_sound():
	if sprite.frame == 0 and last_step == 1:
		var collider: CollisionObject2D = step_check.get_collider()
		if collider != null:
			play_sfx("step", terrain_typestring(collider))


func invincibility_on_effect():
	invincible = true


func is_spinning(allow_continued: bool = false):
	return state == S.SPIN and (spin_frames > 0 or allow_continued)


func is_diving(allow_rollout):
	return (state == S.DIVE or (state == S.ROLLOUT and allow_rollout))


func resist(val, sub, div): # ripped from source
	val = val / FPS_MOD
	var vel_sign = sign(val)
	val = abs(val)
	val -= sub
	val = max(0, val)
	val /= div
	val *= vel_sign
	return val * FPS_MOD


func set_rotation_origin (face_left: bool, origin: Vector2):
	# Vector to flip the offset's X, as appropriate.
	var facing = Vector2(
		-1 if face_left else 1, # Convert 0 to -1
		1)
	
	sprite.offset = origin * facing
	fludd_sprite.position = origin * facing
	sprite.dejitter_position = -origin * facing


func clear_rotation_origin ():
	set_rotation_origin(false, Vector2.ZERO)
