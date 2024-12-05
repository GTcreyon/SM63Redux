class_name PlayerCharacter
extends CharacterBody2D

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
			preload("res://classes/player/sfx/step/snow/step_snow_3.wav"),
			preload("res://classes/player/sfx/step/snow/step_snow_1.wav"),
			preload("res://classes/player/sfx/step/snow/step_snow_2.wav"),
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
		"sand": [
			preload("res://classes/player/sfx/step/generic/step_generic_0.wav"),			
		],
		"wood": [
			preload("res://classes/player/sfx/step/generic/step_generic_0.wav"),			
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
		"sand": [
			preload("res://classes/player/sfx/pound/pound_sand.wav")
		],
		"wood": [
			preload("res://classes/player/sfx/pound/pound_generic.wav")
		],
	},
	"spin": {
		"air": [
			preload("res://classes/player/sfx/spin_air_1.wav"),
			preload("res://classes/player/sfx/spin_air_2.wav"),
			preload("res://classes/player/sfx/spin_air_3.wav"),
		],
		"water": [
			preload("res://classes/player/sfx/spin_water_1.wav")
		]
	},
	"spin_end": {
		"water": [
			preload("res://classes/player/sfx/spin_water_end.wav")
		]
	}
}

var ground_pound_effect = preload("res://classes/player/ground_pound_effect.tscn")

# vars to lock mechanics
var invuln_frames: int = 0
var locked: bool = false

# visual vars
var last_step = 0
var invuln_flash: int = 0

# health vars
var hp = 8
var life_meter = 8 # apparently unused
var coins_toward_health = 0 # If it hits 5, gets reset

# FLUDD state vars
var collected_nozzles: Array = [false, false, false]
var current_nozzle: int = 0
var water: float = 100.0
var fludd_power = 100

var dead: bool = false
var facing_direction: int = 1 # -1 if facing left, 1 if facing right
var body_rotation: float = 0 # Rotation of the body sprite

@onready var base_modifier = BaseModifier.new()
@onready var voice: AudioStreamPlayer = $Voice
@onready var step: AudioStreamPlayer = $Step
@onready var spin_sfx: AudioStreamPlayer = $SpinSFX
@onready var thud: AudioStreamPlayer = $Thud
@onready var pound_spin_sfx: AudioStreamPlayer = $PoundSpin
@onready var character_group: DejitterGroup = $CharacterGroup
@onready var sprite = $CharacterGroup/CharacterSprite
@onready var fludd_sprite = $CharacterGroup/CharacterSprite/Fludd
@onready var camera = $"/root/Main/Player/Camera"
@onready var step_check: RayCast2D = $StepCheck
@onready var pound_check_l: RayCast2D = $PoundCheckL
@onready var pound_check_r: RayCast2D = $PoundCheckR
@onready var angle_cast: RayCast2D = $DiveAngling
@onready var hitbox: CollisionShape2D =  $Hitbox
@onready var water_check: Area2D = $WaterCheck
@onready var switch_sfx: AudioStreamPlayer = $SwitchSFX
@onready var ground_failsafe_check: Area2D = $GroundFailsafe
@onready var feet_area: Area2D = $Feet


func _ready():
	
	switch_state(S.NEUTRAL) # reset state to avoid short mario glitch
	
	# If we came from another scene, load our data from that scene.
	if Singleton.warp_location != null:
		position = Singleton.warp_location
		#Singleton.warp_location = null # Used when respawning, shouldn't clear
	
	if Singleton.warp_data != null:
		facing_direction = Singleton.warp_data.facing_direction

		hp = Singleton.warp_data.hp
		coins_toward_health = Singleton.warp_data.coins_toward_health
		
		collected_nozzles = Singleton.warp_data.collected_nozzles
		current_nozzle = Singleton.warp_data.current_nozzle
		water = Singleton.warp_data.water
		fludd_power = Singleton.warp_data.fludd_power # is this one necessary?

		# Warp data's served its purpose, go ahead and delete it.
		Singleton.warp_data = null


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
	water_areas += 1
	# Reset state to normal
	switch_state(S.NEUTRAL)
	# Refill FLUDD
	water = max(water, 100)
	
	# Reset reverb effect. This clears any reverb tail left in the buffer
	# from last time in water (or from the title screen, when the bus is on).
	Singleton.reset_bus_effect(Singleton.WATER_VRB_BUS, 0)


func _on_WaterCheck_area_exited(_area):
	water_areas -= 1
	
	# Only run exit-water code if we're now in NO water
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
	CROUCH = 1 << 8,
}

enum Pound {
	NONE,
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
var crouch_resetting: bool = false
var frontflip_direction: int = false
var double_anim_cancel: bool = false
var double_jump_state: int = 0
var double_jump_frames: int = 0
var pound_land_frames: int = 0
var pound_state: int = Pound.NONE
var solid_floors: int = 0
func player_physics():
	if OS.is_debug_build():
		assertions()
	fludd_stale = true
	
	update_ground_state()
	
	manage_invuln()
	manage_buffers()
	manage_dive_recover()
	manage_crouch_reset()
	if state == S.TRIPLE_JUMP:
		triple_jump_spin_anim()
	if state == S.BACKFLIP:
		backflip_spin_anim()
	manage_hurt_recover()
	
	if Input.is_action_just_pressed("switch_fludd"):
		switch_fludd()
	
	if swimming:
		water = max(water, 100)
		fludd_power = 100

	
	if can_jump():
		coyote_behaviour()
	else:
		if !swimming:
			airborne_anim()
		if get_walk_direction() == 0:
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
				if can_jump():
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
		vel.x = 0 # Stop sliding down into holes


func assertions() -> void:
	# Value of facing_direction never becomes 0, or anything unexpected
	assert(facing_direction == -1 or facing_direction == 1)
	# Pound state is always NONE if we are not pounding
	assert(state == S.POUND or pound_state == Pound.NONE)
	# Never be resetting while not in the state
	assert(state == S.DIVE or !dive_resetting)
	assert(state == S.CROUCH or !crouch_resetting)


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
			switch_state(S.ROLLOUT)
			frontflip_direction = facing_direction
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
	if swim_input():
		# Just jumped.
		if state == S.NEUTRAL:
			# State is neutral. Begin upward stroke.
			vel.y = min(-4.25, vel.y)
			swim_delay = true
		elif state == S.SPIN:
			# Stroke out of a spin.
			# Switch to neutral state so spin has to restart.
			switch_state(S.NEUTRAL)
			
			vel.y = min(-4.25, vel.y)
			# Take an X velocity boost.
			vel.x = min(abs(vel.x) + 1.5, 8) * sign(vel.x)
		elif (
			state & (S.DIVE | S.CROUCH)
			and Input.is_action_pressed("jump")
			and _can_backflip()
		):
			action_backflip()
	else:
		swim_delay = false
	
	# Sink faster if down is held
	if Input.is_action_pressed("down"):
		vel.y += 0.125


# Returns true if a swim input has been pressed
func swim_input() -> bool:
	return Input.is_action_just_pressed("jump") or Input.is_action_pressed("semi")


func adjust_swim_x() -> void:
	var swim_adjust = vel.x
	swim_adjust = resist(swim_adjust, 0.05, 1.05)
	vel.x += (swim_adjust - vel.x) * FPS_MOD


func fixed_visuals() -> void:
	if hp <= 0:
		dead = true
		Singleton.get_node("DeathManager").register_player_death(self)


const WALL_BOUNCE = 0.19
func wall_stop() -> void:
	if is_on_wall():
		if int(vel.x) != 0:
			if get_walk_direction() != sign(int(vel.x)):
				vel.x = -vel.x * WALL_BOUNCE # Bounce off a wall when not intentionally pushing into it
			else:
				vel.x = 0 # Cancel X velocity when intentionally pushing into a wall
	if is_on_ceiling():
		vel.y = max(vel.y, 0.1)


const POUND_TIME_TO_FALL = 18 # Time to move from pound spin to pound fall
const _POUND_HANG_TIME = 9
const POUND_SPIN_DURATION = POUND_TIME_TO_FALL - _POUND_HANG_TIME # Time the spin animation lasts
## How many frames the player will rise during the pound spin.
const POUND_SPIN_RISE_TIME = 15
## How much the player rises each frame of the pound spin.
const POUND_SPIN_RISE_AMOUNT = 1
const POUND_SPIN_SMOOTHING = 0.5 # Range from 0 to 1

var pound_spin_frames: int = 0
var pound_spin_factor: float = 0.0
func action_pound() -> void:
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
				body_rotation = 0
				pound_spin_frames = 0
				pound_spin_sfx.play()
	
	if state == S.POUND and pound_state == Pound.SPIN:
		off_ground()
		pound_spin_frames += 1
		# Spin frames normalized from 0-1.
		# Min makes it stop after one full spin.
		pound_spin_factor = min(float(pound_spin_frames) / POUND_SPIN_DURATION, 1)
		# Blend between 0% and 100% smoothed animation.
		pound_spin_factor = lerp(pound_spin_factor, sqrt(pound_spin_factor), POUND_SPIN_SMOOTHING)
		
		# Set rotation according to position in the animation.
		body_rotation = TAU * pound_spin_factor
		# Adjust rotation depending on our facing direction.
		body_rotation *= facing_direction
		
		# Once spin animation ends, fall.
		if pound_spin_frames >= POUND_TIME_TO_FALL:
			# Reset sprite transforms.
			clear_rotation_origin()
			
			body_rotation = 0
			
			pound_state = Pound.FALL
			pound_land_frames = 15
			vel.y = 8


const SPIN_TIME = 30
var spin_frames = 0
func action_spin() -> void:
	if state == S.SPIN:
		if spin_frames > 0:
			# Tick spin state
			spin_frames -= 1
		elif !Input.is_action_pressed("spin"):
			end_spin()
	if (
		Input.is_action_pressed("spin")
		and (
			state == S.NEUTRAL
			or (state == S.ROLLOUT and Input.is_action_just_pressed("spin"))
		)
		and (vel.y > -3.3 * FPS_MOD or state == S.ROLLOUT or swimming)
	):
		# begin spin
		switch_state(S.SPIN)
		# switch_state stops spin_sfx; always play it again after state switch.
		if swimming:
			play_sfx("spin", "water")
		else:
			play_sfx("spin", "air")
		if !grounded:
			if swimming:
				vel.y = min(-2, vel.y)
			else:
				vel.y = min(-3.5 * FPS_MOD * 1.3, vel.y - 3.5 * FPS_MOD)
		spin_frames = SPIN_TIME


func end_spin():
	switch_state(S.NEUTRAL)


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
		fludd_power = 100 # TODO: multi fludd
	elif !Input.is_action_pressed("fludd") and current_nozzle != Singleton.Nozzles.HOVER:
		fludd_power = min(fludd_power + FPS_MOD, 100)
	
	if (
		Input.is_action_pressed("fludd")
		and fludd_power > 0
		and water > 0
		and state & (
				S.NEUTRAL
				| S.BACKFLIP
				| S.TRIPLE_JUMP
				| S.DIVE
			)
	):
		_fludd_spraying = true
		match current_nozzle:
			Singleton.Nozzles.HOVER:
				fludd_strain = true
				double_anim_cancel = true
				if state != S.DIVE:
					_fludd_spraying_rising = true
				if state != S.TRIPLE_JUMP or (abs(body_rotation) < PI / 2 or abs(body_rotation) > PI / 2 * 3):
					if state & (S.DIVE | S.TRIPLE_JUMP):
						vel.y *= 1 - 0.02 * FPS_MOD
						vel.x *= 1 - 0.03 * FPS_MOD
						if grounded:
							vel.x += cos(body_rotation)*pow(FPS_MOD, 2) * facing_direction
						elif state == S.DIVE:
							vel.y += sin(body_rotation)*0.92*pow(FPS_MOD, 2) * facing_direction
							vel.x += cos(body_rotation)/2*pow(FPS_MOD, 2) * facing_direction
						else:
							vel.y += sin(body_rotation * facing_direction - PI / 2)*0.92*pow(FPS_MOD, 2)
							vel.x += cos(body_rotation * facing_direction - PI / 2)*0.46*pow(FPS_MOD, 2) * facing_direction
					else:
						if fludd_power == 100 and !swimming:
							vel.y -= 2
						
						if Input.is_action_pressed("jump"):
							vel.y *= 1 - (0.13 * FPS_MOD)
						else:
							vel.y *= 1 - (0.2 * FPS_MOD)
						if swimming:
							vel.y -= 0.75
						else:
							vel.y -= (((-4*fludd_power*vel.y * FPS_MOD * FPS_MOD) + (-525*vel.y * FPS_MOD) + (368*fludd_power * FPS_MOD * FPS_MOD) + (48300)) / 7000) * pow(FPS_MOD, 5)
						vel.x = resist(vel.x, 0.05, 1.03)
					if !swimming:
						water = max(0, water - 0.07 * FPS_MOD)
						fludd_power -= 1.5 * FPS_MOD
			Singleton.Nozzles.ROCKET:
				if fludd_power == 100:
					fludd_strain = true
					rocket_charge += 1
				else:
					fludd_strain = false
				if rocket_charge >= 14 / FPS_MOD and (state != S.TRIPLE_JUMP or ((abs(body_rotation) < deg_to_rad(20) or abs(body_rotation) > deg_to_rad(340)))):
					_fludd_spraying_rising = true
					if state == S.DIVE:
						var multiplier = 1
						multiplier *= facing_direction
						if grounded:
							multiplier *= 2 # Double power when grounded to counteract friction
						vel += Vector2(cos(body_rotation)*25*FPS_MOD * FPS_MOD * multiplier, -sin(body_rotation - PI / 2) * 25 * FPS_MOD * FPS_MOD)
					else:
						vel.y = min(max((vel.y/3),0) - 15.3, vel.y)
						vel.y -= 0.5 * FPS_MOD
					
					rocket_charge = 0
					
					if !swimming:
						water = max(water - 5, 0)
						fludd_power = 0
	else:
		end_fludd()


# Ends fludd and resets charge
func end_fludd():
	fludd_strain = false
	rocket_charge = 0


const WALK_ACCEL: float = 1.1 * FPS_MOD
const AIR_ACCEL: float = 5.0 * FPS_MOD # Functions differently to WALK_ACCEL
const AIR_SPEED_CAP: float = 20.0 * FPS_MOD
func player_control_x() -> void:
	var dir = get_walk_direction()
	if dir != 0:
		if pound_state != Pound.SPIN and (state != S.CROUCH or crouch_resetting):
			var can_turn_around: bool = state & (
					S.NEUTRAL
					| S.SPIN
					| S.TRIPLE_JUMP
					| S.ROLLOUT
				) or crouch_resetting
			if can_turn_around:
				facing_direction = dir # Will never be 0
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


func get_walk_direction() -> int:
	var i_right = Input.is_action_pressed("right")
	var i_left = Input.is_action_pressed("left")
	return int(i_right) - int(i_left)


const TRIPLE_FLIP_TIME: int = 54
var triple_flip_frames: int = 0
func triple_jump_spin_anim() -> void:
	# Tick triple flip timer
	triple_flip_frames += 1
	
	var spin_speed = 1
	# Flip faster if not wearing FLUDD
	if current_nozzle == Singleton.Nozzles.NONE:
		spin_speed = 2
	
	# Set rotation a little further than last frame.
	body_rotation = facing_direction * spin_speed * TAU * \
		ease_out_quart(float(triple_flip_frames) / TRIPLE_FLIP_TIME)
	
	# When timer rings, end the triple jump.
	if triple_flip_frames >= TRIPLE_FLIP_TIME:
		switch_state(S.NEUTRAL)
		body_rotation = 0


func player_jump() -> void:
	if state & (S.DIVE | S.CROUCH):
		if _can_backflip():
			action_backflip()
		elif state == S.DIVE and !dive_resetting and abs(vel.x) >= 1 and !is_on_wall(): # Prevents static dive recover
			action_rollout()
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
				# Set triple-jumping state
				switch_state(S.TRIPLE_JUMP)
				double_jump_state = 0
				triple_flip_frames = 0
				frontflip_direction = facing_direction
				
				# Apply triple jump impulse
				vel.y = -JUMP_VEL_3
				# ...which goes forward too
				vel.x += (vel.x + 15 * FPS_MOD * sign(vel.x)) / 5 * FPS_MOD
				
				# Apply triple jump aesthetic effects
				play_sfx("voice", "jump3")
			else:
				vel.y = -JUMP_VEL_2
				play_sfx("voice", "jump2")
	
	# warning-ignore:return_value_discarded
	move_and_collide(Vector2(0, -3)) # helps jumps feel more responsive


func ease_out_quart(x: float) -> float: # for replacing tweens
	return 1 - pow(1 - x, 4) # https://easings.net/#easeOutQuart <3


const BACKFLIP_FLIP_TIME: int = 36
var backflip_flip_frames: int = 0
func backflip_spin_anim() -> void:
	backflip_flip_frames += 1
	var dir = -facing_direction
	body_rotation = dir * TAU * sin(((float(backflip_flip_frames) / BACKFLIP_FLIP_TIME) * PI) / 2)
	if backflip_flip_frames >= BACKFLIP_FLIP_TIME:
		switch_state(S.NEUTRAL)
		body_rotation = 0


func _can_backflip() -> bool:
	return (
		(
			get_walk_direction()
		) == -facing_direction
		or state == S.CROUCH
	)


func action_backflip() -> void:
	off_ground()
	switch_state(S.BACKFLIP)
	vel.y = min(-JUMP_VEL_1 - 2.5 * FPS_MOD, vel.y)
	vel.x += (30.0 - abs(vel.x)) / (5 / FPS_MOD) * -facing_direction
	dive_resetting = false
	crouch_resetting = false
	backflip_flip_frames = 0
	frontflip_direction = facing_direction


func action_rollout() -> void:
	off_ground()
	switch_state(S.ROLLOUT)
	vel.y = min(-JUMP_VEL_1/1.5, vel.y)
	frontflip_direction = facing_direction


func coyote_behaviour() -> void:
	double_anim_cancel = false
	
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
			body_rotation = 0
		
		if !Input.is_action_pressed("dive"):
			if state == S.DIVE and abs(vel.x) < 1 and !dive_resetting:
				reset_dive()
			
			if state == S.CROUCH and !crouch_resetting:
				reset_crouch()


var hurt_timer = 0
func manage_hurt_recover():
	if state == S.HURT:
		if grounded or hurt_timer <= 0:
			switch_state(S.NEUTRAL)
		else:
			hurt_timer -= 1


var cancel_ground: bool = false
func update_ground_state() -> void:
	if cancel_ground:
		grounded = false
		cancel_ground = false
	else:
		# Failsafe to prevent getting stuck between slopes
		if ground_failsafe_condition():
			ground_failsafe_timer = 0
		grounded = get_ground_state()
	ground_except = grounded


# Get a live-updating grounded state, incase the `ground` variable is outdated
func get_ground_state() -> bool:
	return is_on_floor() or (!ground_failsafe_condition() and ground_failsafe_timer >= GROUND_FAILSAFE_THRESHOLD)


func can_jump() -> bool:
	return coyote_frames > 0


func ground_failsafe_condition() -> bool:
	return (
		vel.y < 0
		or is_on_floor()
		or fludd_spraying_rising(true)
		or (state == S.POUND and pound_state == Pound.SPIN)
		or state == S.HURT
		or swimming
		or bouncing
		or ground_failsafe_check.get_overlapping_bodies().size() <= 0
	)


func player_fall() -> void:
	var fall_adjust = vel.y # used to adjust downward acceleration to account for framerate difference
	if state == S.POUND and pound_state == Pound.SPIN:
		# Don't move during the pound spin.
		vel = Vector2.ZERO
		# A little rising during the wind-up makes it look real nice.
		if pound_spin_frames <= POUND_SPIN_RISE_TIME:
			vel.y = -POUND_SPIN_RISE_AMOUNT
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
	if get_walk_direction() == 0 or state == S.DIVE:
		vel.x = resist(vel.x, 0, 1.001)
		
	return fall_adjust


func air_resistance(fall_adjust) -> float:
	if fall_adjust > 0:
		fall_adjust = resist(fall_adjust, ((GRAV/FPS_MOD)/5), 1.05)
	fall_adjust = resist(fall_adjust, 0, 1.001)
	if state == S.SPIN:
		fall_adjust = resist(fall_adjust, 0.1, 1.03)
	vel.x = resist(vel.x, 0, 1.001) # Air friction
	return fall_adjust


func manage_dive_angle() -> void:
	if angle_cast.is_colliding():
		var target = _get_slide_angle()
		body_rotation = lerp_angle(body_rotation, target, 0.5)
	elif solid_floors > 0:
		body_rotation = PI / 2


func reset_dive() -> void:
	body_rotation = 0
	dive_resetting = true
	dive_reset_frames = 0


func reset_crouch() -> void:
	crouch_resetting = true
	crouch_reset_frames = 0


const TRIPLE_JUMP_ORIGIN_OFFSET_START = Vector2(-2, -4)
const TRIPLE_JUMP_ORIGIN_OFFSET = Vector2(1, -2)
const TRIPLE_JUMP_ORIGIN_OFFSET_FAST = Vector2(-1, -6)
func airborne_anim() -> void:
	if state == S.TRIPLE_JUMP:
		if triple_flip_frames > 3:
			if current_nozzle == Singleton.Nozzles.NONE:
				set_rotation_origin(facing_direction, TRIPLE_JUMP_ORIGIN_OFFSET_FAST)
			else:
				set_rotation_origin(facing_direction, TRIPLE_JUMP_ORIGIN_OFFSET)
		else:
			set_rotation_origin(facing_direction, TRIPLE_JUMP_ORIGIN_OFFSET_START)
	elif state == S.DIVE:
		var target = atan2(vel.y, vel.x) + PI / 2 * (1 - facing_direction)
		body_rotation = lerp_angle(body_rotation, target, 0.5)


const POUND_LAND_DURATION = 12
const POUND_SHAKE_INITIAL = 4
const POUND_SHAKE_MULTIPLIER = 0.75
func manage_pound_recover() -> void:
	if state == S.POUND:
		if pound_land_frames == 12: # just hit ground
			pound_state = Pound.LAND
			
			# Dispatch star effect
			var fx = ground_pound_effect.instantiate()
			get_parent().add_child(fx)
			fx.global_position = sprite.global_position + Vector2.DOWN * 11
			fx.find_child("StarsAnim").play("GroundPound")
			
			# Dispatch pound thud
			# Begin by checking center for a collider
			var collider: CollisionObject2D = step_check.get_collider()
			if collider == null:
				# Center check failed, check right side.
				collider = pound_check_r.get_collider()
			if collider == null:
				# Right check failed, check left side.
				collider = pound_check_l.get_collider()
			# If a collider was found, play the thud.
			if collider != null:
				play_sfx("pound", terrain_typestring(collider))
			
			# Jolt camera downwards
			camera.offset = Vector2(0, POUND_SHAKE_INITIAL)
		elif pound_land_frames <= 0: # impact ended, get up
			pound_state = Pound.NONE
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
	set_velocity(vel * 60.0)
	floor_snap_length = snap
	set_up_direction(Vector2(0, -1))
	set_floor_stop_on_slope_enabled(true)
	move_and_slide()
	
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
		set_velocity(Vector2(vel.x * 60.0 * (vel.x / slide_vec.x), vel.y * 60.0))
		floor_snap_length = snap
		set_up_direction(Vector2(0, -1))
		set_floor_stop_on_slope_enabled(true)
		set_max_slides(4)
		set_floor_max_angle(deg_to_rad(47))
		move_and_slide()


func get_snap() -> float:
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
		return 0
	else:
		return 4


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
						and facing_direction != frontflip_direction
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
		if !swimming and can_jump() and Input.is_action_pressed("jump") and abs(vel.x) > 1: # auto rollout
			off_ground()
			switch_state(S.ROLLOUT)
			frontflip_direction = facing_direction
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
				and abs(body_rotation) > PI / 2 * 3
			)
		):
			if !grounded or vel.y >= 0:
				if !grounded:
					gp_dive_timer = 6
					off_ground()
					if state != S.TRIPLE_JUMP:
						play_sfx("voice", "dive")
					var multiplier = 1
					if state == S.BACKFLIP:
						multiplier = 2 # Allows dives out of backflips to be more responsive
					vel.x += (
						(
							DIVE_VEL - abs(
								vel.x / FPS_MOD
							)
						)
						/ (
							5 / FPS_MOD
						)
						/ FPS_MOD * multiplier * facing_direction
					)
					if state == S.NEUTRAL:
						vel.y = max(-3, vel.y + 3.0 * FPS_MOD)
					else:
						vel.y += 3.0 * FPS_MOD
				if abs(vel.x) <= 0.5 and grounded:
					switch_state(S.CROUCH)
					crouch_resetting = false
					crouch_reset_frames = 0
				else:
					switch_state(S.DIVE)
					body_rotation = 0
					if angle_cast.is_colliding() and grounded:
						body_rotation = _get_slide_angle()
					double_jump_state = 0
					dive_resetting = false
					dive_reset_frames = 0


# Returns the angle that the dive slide should be at
func _get_slide_angle() -> float:
	return angle_cast.get_collision_normal().angle() + PI / 2


const FADE_TIME = 10
var fade_timer = 0
@onready var lowpass: AudioEffectFilter = AudioServer.get_bus_effect(Singleton.WATER_LPF_BUS, 0)
@onready var reverb: AudioEffectReverb = AudioServer.get_bus_effect(Singleton.WATER_VRB_BUS, 0)
func manage_water_audio(delta):
	if swimming:
		# Fade in water fx
		fade_timer = min(fade_timer + delta * 60, FADE_TIME)
	else:
		# Fade out water fx
		fade_timer = max(fade_timer - delta * 60, 0)
	
	# Apply fade to fx
	reverb.wet = 0.25 * fade_timer / FADE_TIME
	lowpass.cutoff_hz = int((2000 - 20500) * fade_timer / FADE_TIME + 20500)
	
	# Disable fx if left water and fade is finished
	AudioServer.set_bus_effect_enabled(Singleton.WATER_LPF_BUS, 0, fade_timer != 0)
	AudioServer.set_bus_effect_enabled(Singleton.WATER_VRB_BUS, 0, fade_timer != 0)


const ROLLOUT_TIME: int = 18
const DIVE_RESET_TIME: int = 8
var rollout_frames: int = 0
var dive_reset_frames: int = 0
func manage_dive_recover():
	if state == S.ROLLOUT:
		rollout_frames += 1
		body_rotation = rollout_frames * TAU / ROLLOUT_TIME * facing_direction
		if rollout_frames >= ROLLOUT_TIME or grounded:
			switch_state(S.NEUTRAL)
			body_rotation = 0
			rollout_frames = 0
	elif dive_resetting:
		dive_reset_frames += 1
		body_rotation = (-dive_reset_frames * PI / 2.0 / DIVE_RESET_TIME) * facing_direction
		# Offset when the sprite becomes upright
		if dive_reset_frames >= DIVE_RESET_TIME / 2.0:
			body_rotation += PI / 2.0 * facing_direction
		
		if dive_reset_frames >= DIVE_RESET_TIME:
			dive_resetting = false
			switch_state(S.NEUTRAL)
			body_rotation = 0


const CROUCH_RESET_TIME: int = 8
var crouch_reset_frames: int = 0
func manage_crouch_reset() -> void:
	if !crouch_resetting:
		return
	if Input.is_action_pressed("dive"):
		crouch_resetting = false
		return
	crouch_reset_frames += 1
	if crouch_reset_frames >= CROUCH_RESET_TIME:
		crouch_resetting = false
		switch_state(S.NEUTRAL)


func switch_fludd():
	var last_nozzle = current_nozzle
	# Switch to next nozzle, bypassing nozzles not currently held.
	current_nozzle += 1
	while (
		(
			current_nozzle < 4
			and !collected_nozzles[(current_nozzle - 1) % 3]
		)
		or current_nozzle == 0
	):
		current_nozzle += 1
	# If reached the end, revert to no nozzle.
	if current_nozzle == 4:
		current_nozzle = 0
	# If nozzle actually changed, set it up and play effects.
	if current_nozzle != last_nozzle:
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
		position = collect_pos_init + sin(min(collect_frames / 230.0, 1) * PI / 2) * (collect_pos_final - collect_pos_init)
		collect_frames += 1
		if collect_frames >= 230:
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
const STAND_BOX_SIZE = Vector2(12, 29)
const DIVE_BOX_POS = Vector2(0, 10)
const DIVE_BOX_SIZE = Vector2(12, 12)
func switch_state(new_state):
	# Always pause AND stop spin SFX
	spin_sfx.stop()
	spin_sfx.stream_paused = true
	# If spin just ended, adjust SFX accordingly.
	if state == S.SPIN:
		if swimming:
			play_sfx("spin_end", "water")
	
	# Update to new state.
	state = new_state
	body_rotation = 0
	match state:
		S.DIVE, S.CROUCH:
			hitbox.position = DIVE_BOX_POS
			hitbox.shape.size = DIVE_BOX_SIZE
		S.POUND:
			hitbox.position = STAND_BOX_POS
			hitbox.shape.size = STAND_BOX_SIZE
			camera.position_smoothing_speed = 10
		_:
			hitbox.position = STAND_BOX_POS
			hitbox.shape.size = STAND_BOX_SIZE
			camera.position_smoothing_speed = 5
			clear_rotation_origin()
	
	# On any state change, reset the following things:
	pound_state = Pound.NONE
	clear_rotation_origin()


func take_damage(amount):
	if invuln_frames <= 0 and !locked:
		hp = clamp(hp - amount, 0, 8) # TODO - multi HP
		invuln_frames = 180


func take_damage_shove(amount, direction):
	if invuln_frames <= 0 and !locked:
		take_damage(amount)
		switch_state(S.HURT)
		hurt_timer = 30
		clear_rotation_origin()
		camera.offset = Vector2.ZERO
		vel = Vector2(4 * direction, -3)
		facing_direction = -direction
		off_ground()


func off_ground():
	coyote_frames = 0
	grounded = false
	cancel_ground = true


func receive_health(amount):
	hp = clamp(hp + amount, 0, 8) # TODO - multi HP


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
		"spin", "spin_end":
			spin_sfx.stream = sound
			spin_sfx.play(0)
			spin_sfx.stream_paused = false


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
		0b00000100:
			return "sand"
		0b00000010:
			return "wood"
		_:
			return "generic"


func step_sound():
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


func set_rotation_origin(facing_dir: int, origin: Vector2):
	# Flip origin, if appropriate.
	origin.x *= facing_dir
	
	sprite.offset = origin
	sprite.position = -origin


func clear_rotation_origin():
	set_rotation_origin(1, Vector2.ZERO)


# Called when interacting with signs and toads
func start_interaction():
	# Ends spinning if active
	if state == S.SPIN:
		end_spin()
	
	end_fludd()
