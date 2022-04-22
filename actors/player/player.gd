extends KinematicBody2D

const FPS_MOD = 32.0 / 60.0 #Multiplier to account for 60fps

const SFX_BANK = { #bank of sfx to be played with play_sfx()
	"step": {
		"grass": [
			preload("res://audio/sfx/step/grass/step_grass_0.wav"),
			preload("res://audio/sfx/step/grass/step_grass_1.wav"),
			preload("res://audio/sfx/step/grass/step_grass_2.wav"),
			preload("res://audio/sfx/step/grass/step_grass_3.wav"),
		],
		"generic": [
			preload("res://audio/sfx/step/generic/step_generic_0.wav"),
			preload("res://audio/sfx/step/generic/step_generic_1.wav"),
			preload("res://audio/sfx/step/generic/step_generic_2.wav"),
			preload("res://audio/sfx/step/generic/step_generic_3.wav"),
			preload("res://audio/sfx/step/generic/step_generic_4.wav"),
			preload("res://audio/sfx/step/generic/step_generic_5.wav"),
			preload("res://audio/sfx/step/generic/step_generic_6.wav"),
			preload("res://audio/sfx/step/generic/step_generic_7.wav"),
			preload("res://audio/sfx/step/generic/step_generic_8.wav"),
			preload("res://audio/sfx/step/generic/step_generic_9.wav"),
			preload("res://audio/sfx/step/generic/step_generic_10.wav"),
			preload("res://audio/sfx/step/generic/step_generic_11.wav"),
			preload("res://audio/sfx/step/generic/step_generic_12.wav"),
			preload("res://audio/sfx/step/generic/step_generic_13.wav"),
		],
		"metal": [
			preload("res://audio/sfx/step/metal/step_metal_0.wav"),
			preload("res://audio/sfx/step/metal/step_metal_1.wav"),
			preload("res://audio/sfx/step/metal/step_metal_2.wav"),
			preload("res://audio/sfx/step/metal/step_metal_3.wav"),
			preload("res://audio/sfx/step/metal/step_metal_4.wav"),
			preload("res://audio/sfx/step/metal/step_metal_5.wav"),
			preload("res://audio/sfx/step/metal/step_metal_6.wav"),
			preload("res://audio/sfx/step/metal/step_metal_7.wav"),
			preload("res://audio/sfx/step/metal/step_metal_8.wav"),
			preload("res://audio/sfx/step/metal/step_metal_9.wav"),
		],
		"snow": [
			preload("res://audio/sfx/step/snow/step_snow_0.wav"),
			preload("res://audio/sfx/step/snow/step_snow_1.wav"),
			preload("res://audio/sfx/step/snow/step_snow_2.wav"),
			preload("res://audio/sfx/step/snow/step_snow_3.wav"),
			preload("res://audio/sfx/step/snow/step_snow_4.wav"),
		],
		"cloud": [
			preload("res://audio/sfx/step/cloud/step_cloud_0.wav"),
			preload("res://audio/sfx/step/cloud/step_cloud_1.wav"),
		],
		"ice": [
			preload("res://audio/sfx/step/ice/step_ice_0.wav"),
			preload("res://audio/sfx/step/ice/step_ice_1.wav"),
		],
	},
	"voice": {
		"jump1": [
			preload("res://audio/sfx/mario/jump_single/jump_single_0.wav"),
			preload("res://audio/sfx/mario/jump_single/jump_single_1.wav"),
		],
		"jump2": [
			preload("res://audio/sfx/mario/jump_double/jump_double_0.wav"),
			preload("res://audio/sfx/mario/jump_double/jump_double_1.wav"),
			preload("res://audio/sfx/mario/jump_double/jump_double_2.wav"),
		],
		"jump3": [
			preload("res://audio/sfx/mario/jump_triple/jump_triple_0.wav"),
			preload("res://audio/sfx/mario/jump_triple/jump_triple_1.wav"),
			preload("res://audio/sfx/mario/jump_triple/jump_triple_2.wav"),
			preload("res://audio/sfx/mario/jump_triple/jump_triple_3.wav"),
			preload("res://audio/sfx/mario/jump_triple/jump_triple_4.wav"),
			preload("res://audio/sfx/mario/jump_triple/jump_triple_5.wav"),
			preload("res://audio/sfx/mario/jump_triple/jump_triple_6.wav"),
			preload("res://audio/sfx/mario/jump_triple/jump_triple_7.wav"),
		],
		"dive": [
			preload("res://audio/sfx/mario/dive/dive_0.wav"),
			preload("res://audio/sfx/mario/dive/dive_1.wav"),
			preload("res://audio/sfx/mario/dive/dive_2.wav"),
			preload("res://audio/sfx/mario/dive/dive_3.wav"),
		],
	}
}

onready var base_modifier: BaseModifier = Singleton.base_modifier
onready var voice = $Voice
onready var step = $Step
onready var tween = $Tween
onready var sprite = $Character
onready var fludd_sprite = $Character/Fludd
onready var camera = $"/root/Main/Player/Camera2D"
onready var step_check = $StepCheck
onready var angle_cast = $DiveAngling
onready var hitbox =  $Hitbox
onready var water_check = $WaterCheck
onready var bubbles_medium: Particles2D = $"BubbleViewport/BubblesMedium"
onready var bubbles_small: Particles2D = $"BubbleViewport/BubblesSmall"
onready var bubbles_viewport = $BubbleViewport
onready var switch_sfx = $SwitchSFX
onready var hover_sfx = $HoverSFX
onready var hover_loop_sfx = $HoverLoopSFX
onready var dust = $Dust

#vars to lock mechanics
var invuln_frames: int = 0
var locked: bool = false

#visual vars
var last_step = 0
var invuln_flash: int = 0

func _ready():
	var warp = $"/root/Singleton/Warp"
	switch_state(S.NEUTRAL) # reset state to avoid short mario glitch
	if Singleton.set_location != null:
		position = Singleton.set_location
		warp.set_location = null
		sprite.flip_h = warp.flip


func _physics_process(_delta):
	if locked:
		locked_behaviour()
	else:
		player_physics()
	fixed_visuals()


func _on_Tween_tween_completed(_object, _key):
	if state == S.POUND:
		pound_state = Pound.FALL
		vel.y = 8
	else:
		switch_state(S.NEUTRAL)


func _on_BackupAngle_body_entered(_body):
	solid_floors += 1


func _on_BackupAngle_body_exited(_body):
	solid_floors -= 1


func _on_WaterCheck_area_entered(_area):
	swimming = true
	Singleton.water = max(Singleton.water, 100)


func _on_WaterCheck_area_exited(_area):
	if water_check.get_overlapping_bodies().size() == 0:
		swimming = false
		if vel.y < 0 && !fludd_strain && !is_spinning():
			vel.y -= 3

# player physics constants
const GP_DIVE_TIME = 6
const GROUND_OVERRIDE_THRESHOLD: int = 10

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
var dive_resetting: bool = false
var frontflip_dir_left: bool = false
var double_anim_cancel: bool = false
var double_jump_state: int = 0
var double_jump_frames: int = 0
var pound_land_frames: int = 0
var pound_state: int = Pound.SPIN
var solid_floors: int = 0
func player_physics():
	check_ground_state()
	
	manage_invuln()
	manage_buffers()
	manage_dive_recover()
	manage_water_audio()
	
	if Input.is_action_just_pressed("switch_fludd"):
		switch_fludd()
	
	if swimming:
		Singleton.water = max(Singleton.water, 100)
		Singleton.power = 100

	
	if coyote_frames > 0:
		coyote_behaviour()
	else:
		airborne_anim()
		if Input.is_action_pressed("left") == Input.is_action_pressed("right"):
			vel.x = resist(vel.x, 0, 1.001) # Air decel
	
	player_fall()
	if Input.is_action_pressed("jump"):
		if coyote_frames > 0:
			player_jump()
		elif jump_vary_frames > 0 && state == S.NEUTRAL:
			vel.y -= GRAV * pow(FPS_MOD, 3) #Variable jump height
	
	player_control_x()
	fludd_control()
	
	action_dive()
	action_spin()
	action_pound()
	
	wall_stop()
	
	player_move()
	
	if state == S.POUND && is_on_floor():
		vel.x = 0 # stop sliding down into holes


var hover_sound_position = 0
func fixed_visuals() -> void:
	if state == S.DIVE || swimming:
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
			if !Input.is_action_pressed("fludd") || Singleton.power > 0:
				hover_sfx.stop()
	
	bubbles_medium.emitting = fludd_strain
	bubbles_small.emitting = fludd_strain

	var center = position
	if state == S.DIVE:
		bubbles_medium.position.y = -9
		bubbles_small.position.y = -9
		if sprite.flip_h:
			bubbles_medium.position.x = -1
			bubbles_small.position.x = -1

		else:
			bubbles_medium.position.x = 1
			bubbles_small.position.x = 1
	else:
		bubbles_medium.position.y = -2
		bubbles_small.position.y = -2
		if sprite.flip_h:
			bubbles_medium.position.x = 10
			bubbles_small.position.x = 10
		else:
			bubbles_medium.position.x = -10
			bubbles_small.position.x = -10
	#offset bubbles to mario's center
	bubbles_medium.position += center
	bubbles_small.position += center
	
	#give it shader data
	bubbles_small.process_material.direction = Vector3(cos(sprite.rotation + PI / 2), sin(sprite.rotation + PI / 2), 0)
	bubbles_medium.process_material.direction = Vector3(cos(sprite.rotation + PI / 2), sin(sprite.rotation + PI / 2), 0)
	
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
#			0:
#				fludd_sprite.flip_h = sprite.flip_h
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


func action_pound() -> void:
	if Input.is_action_pressed("pound"):
		if state == S.DIVE && gp_dive_timer > 0:
			var mag = vel.length()
			var ang
			if vel.x > 0:
				ang = PI / 5
			else:
				ang = PI - PI / 5
			vel = Vector2(cos(ang) * mag, sin(ang) * mag)
		else:
			if (
				!grounded
				&& (
					state & (
						S.NEUTRAL
						| S.TRIPLE_JUMP
						| S.SPIN
						| S.BACKFLIP
						| S.ROLLOUT
					)
					||
					(
						state == S.DIVE
						&& Input.is_action_just_pressed("pound")
					)
				)
			):
				switch_state(S.POUND)
				pound_state = Pound.SPIN
				switch_anim("flip")
				sprite.rotation_degrees = 0
				tween.remove_all()
				tween.interpolate_property(sprite, "rotation_degrees", 0, -360 if sprite.flip_h else 360, 0.25)
				tween.start()


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
		&& (
			state == S.NEUTRAL
			|| (state == S.ROLLOUT || Input.is_action_just_pressed("spin"))
		)
		&& (vel.y > -3.3 * FPS_MOD || state == S.ROLLOUT)
	):
		switch_state(S.SPIN)
		switch_anim("spin")
		if !grounded:
			vel.y = min(-3.5 * FPS_MOD * 1.3, vel.y - 3.5 * FPS_MOD)
		spin_frames = SPIN_TIME


var rocket_charge: int = 0
func fludd_control():
	if grounded:
		Singleton.power = 100 # TODO: multi fludd
	elif !Input.is_action_pressed("fludd") && Singleton.nozzle != Singleton.n.hover:
		Singleton.power = min(Singleton.power + FPS_MOD, 100)
	if (
		Input.is_action_pressed("fludd")
		&& Singleton.power > 0
		&& Singleton.water > 0
		&& state & (
				S.NEUTRAL
				| S.BACKFLIP
				| S.TRIPLE_JUMP
				| S.DIVE
			)
	):
		match Singleton.nozzle:
			Singleton.n.hover:
				fludd_strain = true
				double_anim_cancel = true
				if state != S.TRIPLE_JUMP || (abs(sprite.rotation_degrees) < 90 || abs(sprite.rotation_degrees) > 270):
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
						if Singleton.power == 100:
							vel.y -= 2
						
						if Input.is_action_pressed("jump"):
							vel.y *= 1 - (0.13 * FPS_MOD)
						else:
							vel.y *= 1 - (0.2 * FPS_MOD)
						#vel.y -= (((9.2 * fps_mod)-vel.y * fps_mod)/(10 / fps_mod))*((Singleton.power/(175 / fps_mod))+(0.75 * fps_mod))
						#vel.y -= (((9.2 * fps_mod)-vel.y * fps_mod)/10)*((Singleton.power/(175))+(0.75 * fps_mod))
						vel.y -= (((-4*Singleton.power*vel.y * FPS_MOD * FPS_MOD) + (-525*vel.y * FPS_MOD) + (368*Singleton.power * FPS_MOD * FPS_MOD) + (48300)) / 7000) * pow(FPS_MOD, 5)
						vel.x = resist(vel.x, 0.05, 1.03)
					Singleton.water = max(0, Singleton.water - 0.07 * FPS_MOD)
					Singleton.power -= 1.5 * FPS_MOD
			Singleton.n.rocket:
				if Singleton.power == 100:
					fludd_strain = true
					rocket_charge += 1
				else:
					fludd_strain = false
				if rocket_charge >= 14 / FPS_MOD && (state != S.TRIPLE_JUMP || ((abs(sprite.rotation_degrees) < 20 || abs(sprite.rotation_degrees) > 340))):
					if state == S.DIVE:
						#set sign of velocity (could use ternary but they're icky)
						var multiplier = 1
						if sprite.flip_h:
							multiplier = -1
						if grounded:
							multiplier *= 2 #double power when grounded to counteract friction
						vel += Vector2(cos(sprite.rotation)*25*FPS_MOD * FPS_MOD * multiplier, -sin(sprite.rotation - PI / 2) * 25 * FPS_MOD * FPS_MOD)
	#					elif state == s.frontflip:
	#						vel -= Vector2(-cos(sprite.rotation - PI / 2)*25*fps_mod, sin(sprite.rotation + PI / 2)*25*fps_mod)
					else:
						vel.y = min(max((vel.y/3),0) - 15.3, vel.y)
						vel.y -= 0.5 * FPS_MOD
					
					Singleton.water = max(Singleton.water - 5, 0)
					rocket_charge = 0
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
		if state != S.POUND || pound_state != Pound.SPIN:
			if (
				state & (
					S.NEUTRAL
					| S.SPIN
					| S.TRIPLE_JUMP
					| S.ROLLOUT
				)
			):
				sprite.flip_h = dir == -1 # flip sprite according to direction
			if grounded:
				if state == S.POUND:
					vel.x = 0
				elif state != S.DIVE:
					vel.x += dir * WALK_ACCEL
			else:
				var core_vel = dir * max((AIR_ACCEL - dir * vel.x) / (AIR_SPEED_CAP / (3 * FPS_MOD)), 0)
				if state & (S.TRIPLE_JUMP | S.SPIN | S.BACKFLIP):
					vel.x += core_vel / (1.5 / FPS_MOD)
				elif state & (S.DIVE | S.ROLLOUT):
					vel.x += core_vel / (8 / FPS_MOD)
				elif state == S.POUND:
					vel.x += core_vel / (2 / FPS_MOD)
				else:
					vel.x += core_vel


func player_jump() -> void:
	if state == S.DIVE:
		if (
			(
				(
					int(Input.is_action_pressed("right"))
					- int(Input.is_action_pressed("left")) != -1
				)
				&&
				!sprite.flip_h
			)
			||
			(
				(
					int(Input.is_action_pressed("right"))
					- int(Input.is_action_pressed("left")) != 1
				)
				&&
				sprite.flip_h
			)
		):
			if !dive_resetting && abs(vel.x) >= 1 && !is_on_wall(): #prevents static dive recover
				action_rollout()
		else:
			action_backflip()
	elif (jump_buffer_frames > 0
		&&
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
	coyote_frames = 0
	match double_jump_state:
		0: # Single
			switch_state(S.NEUTRAL)
			play_sfx("voice", "jump1")
			if ground_override >= GROUND_OVERRIDE_THRESHOLD:
				vel.y = -JUMP_VEL_1 * 2
			else:
				vel.y = -JUMP_VEL_1
			double_jump_state += 1
		1: # Double
			switch_state(S.NEUTRAL)
			jump_2()
			double_jump_state += 1
		2: #Triple
			if abs(vel.x) > TRIPLE_JUMP_DEADZONE:
				if ground_override >= GROUND_OVERRIDE_THRESHOLD:
					vel.y = -JUMP_VEL_3 * 2
				else:
					vel.y = -JUMP_VEL_3
				vel.x += (vel.x + 15 * FPS_MOD * sign(vel.x)) / 5 * FPS_MOD
				double_jump_state = 0
				switch_state(S.TRIPLE_JUMP)
				play_sfx("voice", "jump3")
				tween.remove_all() # TODO: remove tween, bad
				if Singleton.nozzle == Singleton.n.none:
					tween.interpolate_property(sprite, "rotation_degrees", 0, -720 if sprite.flip_h else 720, 0.9, Tween.TRANS_QUART, Tween.EASE_OUT)
				else:
					tween.interpolate_property(sprite, "rotation_degrees", 0, -360 if sprite.flip_h else 360, 0.9, Tween.TRANS_QUART, Tween.EASE_OUT)
				tween.start()
				frontflip_dir_left = sprite.flip_h
			else:
				jump_2()
	
	#warning-ignore:return_value_discarded
	move_and_collide(Vector2(0, -3)) # helps jumps feel more responsive


func jump_2() -> void:
	if ground_override >= GROUND_OVERRIDE_THRESHOLD:
		vel.y = -JUMP_VEL_2 * 2
	else:
		vel.y = -JUMP_VEL_2
	play_sfx("voice", "jump2")


func action_backflip() -> void:
	if !dive_resetting:
		dive_correct(-1)
	coyote_frames = 0
	switch_state(S.BACKFLIP)
	vel.y = min(-JUMP_VEL_1 - 2.5 * FPS_MOD, vel.y)
	if sprite.flip_h:
		vel.x += (30.0 - abs(vel.x)) / (5 / FPS_MOD)
	else:
		vel.x -= (30.0 - abs(vel.x)) / (5 / FPS_MOD)
	dive_resetting = false
	tween.remove_all()
	if sprite.flip_h:
		tween.interpolate_property(sprite, "rotation_degrees", 0, 360, 0.6, 1, Tween.EASE_OUT, 0)
	else:
		tween.interpolate_property(sprite, "rotation_degrees", 0, -360, 0.6, 1, Tween.EASE_OUT, 0)
	tween.start()
	switch_anim("jump")
	frontflip_dir_left = sprite.flip_h


func action_rollout() -> void:
	coyote_frames = 0
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
		ground_friction()
	
		if state & (S.TRIPLE_JUMP | S.BACKFLIP): # Reset state when landing
			switch_state(S.NEUTRAL)
			tween.remove_all()
			sprite.rotation = 0
		
		if state == S.DIVE && abs(vel.x) < 1 && !Input.is_action_pressed("dive") && !dive_resetting:
			reset_dive()


func check_ground_state() -> void:
	# failsafe to prevent getting stuck between slopes
	grounded = is_on_floor() || ground_override >= GROUND_OVERRIDE_THRESHOLD
	if (
		vel.y < 0
		|| is_on_floor()
		|| Input.is_action_pressed("fludd")
		|| state == S.POUND
		|| swimming
		|| bouncing
	):
		ground_override = 0


func player_fall() -> void:
	var fall_adjust = vel.y # used to adjust downward acceleration to account for framerate difference
	if state == S.POUND && pound_state == Pound.SPIN:
		vel = Vector2.ZERO
	else:
		if state == S.POUND && pound_state == Pound.FALL:
			fall_adjust += 0.814
		else:
			fall_adjust += GRAV
		
		if !grounded:
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


func air_resistance(fall_adjust) -> float:
	if state == S.POUND && pound_state == Pound.FALL:
		pound_land_frames = 15
	if fall_adjust > 0:
		fall_adjust = resist(fall_adjust, ((GRAV/FPS_MOD)/5), 1.05)
	fall_adjust = resist(fall_adjust, 0, 1.001)
	if state == S.SPIN:
		fall_adjust = resist(fall_adjust, 0.1, 1.03)
	vel.x = resist(vel.x, 0, 1.001) #Air friction
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
			if double_jump_state == 2 && !double_anim_cancel:
				switch_anim("jump_double")
			else:
				switch_anim("jump")
	elif state == S.POUND && pound_state == Pound.FALL:
		switch_anim("pound_fall")
	elif state == S.DIVE:
		if sprite.flip_h:
			sprite.rotation = lerp_angle(sprite.rotation, -atan2(vel.y, -vel.x) - PI / 2, 0.5)
		else:
			sprite.rotation = lerp_angle(sprite.rotation, atan2(vel.y, vel.x) + PI / 2, 0.5)


func manage_pound_recover() -> void:
	if state == S.POUND:
		if pound_land_frames == 12:
			pound_state = Pound.LAND
			switch_anim("flip")
		elif pound_land_frames <= 0:
			switch_state(S.NEUTRAL)
		# warning-ignore:narrowing_conversion
		pound_land_frames = max(0, pound_land_frames - 1)


func player_move() -> void:
	var snap = get_snap()
	
	# store the current position in advance
	var save_pos = position
	#warning-ignore:return_value_discarded
	move_and_slide_with_snap(vel * 60.0, snap, Vector2(0, -1), true)
	
	# check how far that moved the player
	var slide_vec = position-save_pos
	# if the player isn't grounded despite being stopped moving downwards, increment the failsafe
	if abs(slide_vec.y) < 0.5 && vel.y > 0 && !is_on_floor():
		# warning-ignore:narrowing_conversion
		ground_override = min(ground_override + 1, GROUND_OVERRIDE_THRESHOLD)
	
	# ensure the player moves the intended horizontal distance
	if (
		slide_vec.x >= 0.5
		&& is_on_floor()
	):
		position = save_pos
		#warning-ignore:return_value_discarded
		move_and_slide_with_snap(Vector2(vel.x * 60.0 * (vel.x / slide_vec.x), vel.y * 60.0), snap, Vector2(0, -1), true, 4, deg2rad(47))


func get_snap() -> Vector2:
	if (
		!grounded
		|| Input.is_action_just_pressed("jump")
		|| jump_buffer_frames > 0
		|| state == S.ROLLOUT
		||
		(
			Input.is_action_just_pressed("fludd")
			&& Singleton.nozzle == Singleton.n.hover
		) 
		||
		(
			swimming
			&& Input.is_action_pressed("semi")
		)
	):
		return Vector2.ZERO
	else:
		return Vector2(0, 4)


const DIVE_VEL = 35.0 * FPS_MOD
func action_dive():
	if (
		Input.is_action_pressed("dive")
		&&
		(
			state & (
				S.TRIPLE_JUMP
				| S.NEUTRAL
				| S.BACKFLIP
			)
			||
			(
				Input.is_action_just_pressed("dive")
				&&
				(
					(
						state == S.ROLLOUT # allows for tighter dive turns
						&& sprite.flip_h != frontflip_dir_left
					)
					||
					state == S.SPIN
				)
			)
		)
		&&
		(
			!swimming
			||
			grounded
		)
	):
		if !swimming && coyote_frames > 0 && Input.is_action_pressed("jump") && abs(vel.x) > 1: # auto rollout
			coyote_frames = 0
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
			||
			(
				state == S.BACKFLIP
				&& abs(sprite.rotation) > PI / 2 * 3
			)
		):
			if !grounded:
				gp_dive_timer = 6
				coyote_frames = 0
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
			if (!grounded || vel.y >= 0) && (!swimming || grounded):
				switch_state(S.DIVE)
				if sprite.flip_h:
					sprite.rotation = -PI / 2
				else:
					sprite.rotation = PI / 2
				tween.remove_all()
				switch_anim("dive")
				double_jump_state = 0
				dive_correct(1)


func manage_water_audio():
	AudioServer.set_bus_effect_enabled(0, 0, swimming) # muffle audio underwater
	AudioServer.set_bus_effect_enabled(0, 1, swimming) # TODO: fade the muffle effect


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
		if rollout_frames >= 18 || grounded:
			switch_state(S.NEUTRAL)
			sprite.rotation = 0
			rollout_frames = 0
	elif dive_resetting:
		dive_reset_frames += 1
		# warning-ignore:integer_division
		if dive_reset_frames >= DIVE_RESET_TIME / 2:
			if sprite.animation != "jump":
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
			&& !Singleton.collected_nozzles[(Singleton.nozzle - 1) % 3]
		)
		|| Singleton.nozzle == 0
	):
		Singleton.nozzle += 1
	if Singleton.nozzle == 4:
		Singleton.nozzle = 0
	if Singleton.nozzle != save_nozzle:
		# lazy way to refresh fludd anim
		var anim = (sprite.animation.replace("hover_", "").replace("rocket_", "").replace("turbo_", ""))
		switch_anim(anim)
		fludd_strain = false
		switch_sfx.play()


const COYOTE_TIME: int = 5
const JUMP_VARY_TIME: int = 13
var sign_frames: int = 0
var ground_override: int = 0
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


func locked_behaviour():
#	if sign_x != null:
#		position.x = sign_x + (position.x - sign_x) * 0.75
#	if collect_pos_final != Vector2():
#		sprite.animation = "spin"
#		position = collect_pos_init + sin(min(collect_time, 1) * PI / 2) * (collect_pos_final - collect_pos_init)
#		if collect_time < 1:
#			collect_time += 1.0/(60.0 * 3.835)
#		else:
#			collect_time += 1.0
#			sprite.animation = "shine"
#			if collect_time >= 80:
#				$"/root/Singleton/WindowWarp".warp(Vector2(), "res://scenes/title/title.tscn", 40)
	var _a = 0 # TODO


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
func switch_state(new_state): # TODO - bad state
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
	if invuln_frames <= 0 && !locked: # TODO - invuln frames, static
		Singleton.hp = clamp(Singleton.hp - amount, 0, 8) #TODO - multi HP
		invuln_frames = 180


func take_damage_shove(amount, direction):
	if invuln_frames <= 0 && !locked: # TODO - invuln frames, static
		take_damage(amount)
		vel = Vector2(4 * direction, -3)


func recieve_health(amount):
	Singleton.hp = clamp(Singleton.hp + amount, 0, 8) # TODO - multi HP
	
const DIVE_CORRECTION = 7
func dive_correct(factor): # Correct the player's origin position when diving
	#warning-ignore:return_value_discarded
	move_and_slide(Vector2(0, DIVE_CORRECTION * factor * 60), Vector2(0, -1))
	if factor == -1:
		dust.position.y = 11.5
	else:
		dust.position.y = 11.5 - DIVE_CORRECTION
	base_modifier.add_modifier(
		camera,
		"position",
		"dive_correction",
		Vector2(
			0,
			min(0, -DIVE_CORRECTION * factor)
		)
	)
	#camera.position.y = min(0, -set_dive_correct * factor)


func play_sfx(type, group):
	var sound_set = SFX_BANK[type][group]
	var sound = sound_set[randi() % sound_set.size()]
	voice.stream = sound
	voice.play(0)


const STEP_MASK = 0b111111110000000000000000
func step_sound():
	if sprite.frame == 0 && last_step == 1:
		var collider: CollisionObject2D = step_check.get_collider()
		if collider != null:
			var layer = collider.collision_layer & STEP_MASK >> 16
			match layer:
				0b10000000:
					play_sfx("step", "grass")
				0b01000000:
					play_sfx("step", "metal")
				0b00100000:
					play_sfx("step", "snow")
				0b00010000:
					play_sfx("step", "soft")
				0b00001000:
					play_sfx("step", "ice")
				_:
					play_sfx("step", "generic")


func invincibility_on_effect():
	invincible = true


func is_spinning():
	return state == S.SPIN && spin_frames > 0


func is_diving(allow_rollout):
	return (state == S.DIVE || (state == S.ROLLOUT && allow_rollout))


func resist(val, sub, div): # ripped from source
	val = val / FPS_MOD
	var vel_sign = sign(val)
	val = abs(val)
	val -= sub
	val = max(0, val)
	val /= div
	val *= vel_sign
	return val * FPS_MOD

