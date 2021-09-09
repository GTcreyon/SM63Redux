extends KinematicBody2D

const fps_mod = 32.0 / 60.0 #Multiplier to account for 60fps
const grav = fps_mod

const set_jump_1_tp = 3
const set_jump_2_tp = set_jump_1_tp * 1.25
const set_jump_3_tp = set_jump_1_tp * 1.5
const set_air_speed_cap = 20.0*fps_mod
const set_walk_accel = 1.1 * fps_mod
const set_air_accel = 5.0 * fps_mod #Functions differently to walkAccel
const set_walk_decel = set_walk_accel * 1.1 #Suggested by Maker - decel is faster than accel in casual mode
const set_air_decel = set_air_accel * 1.1
const set_jump_1_vel = 10 * fps_mod
const set_jump_2_vel = set_jump_1_vel + 2.5 * fps_mod
const set_jump_3_vel = set_jump_1_vel + 5.0 * fps_mod
var set_wall_bounce
const set_jump_mod_frames = 13
const set_double_jump_frames = 17
const set_triple_jump_deadzone = 2.0 * fps_mod
const set_dive_speed = 35.0 * fps_mod
const set_dive_correct = 7
const set_hover_speed = 9.2

onready var singleton = $"/root/Singleton"
onready var voice = $Voice
onready var tween = $Tween
onready var sprite = $AnimatedSprite
onready var camera = $Camera2D
onready var angle_cast = $DiveAngling
onready var stand_box =  $StandHitbox
onready var dive_box = $DiveHitbox
onready var hitbox = stand_box
onready var bubbles_medium = $"BubbleViewport/BubblesMedium"
onready var bubbles_small = $"BubbleViewport/BubblesSmall"
onready var bubbles_viewport = $BubbleViewport
onready var timer = get_node("Timer")

#mario's gameplay parameters
var life_meter_counter = 8
var fludd_strain = false
var static_v = false #for pipe, may be used for other things.
var invincible = false #needed for making him invincible
var internal_coin_counter = 0 #if it hits 5, gets reset
var if_died = false #for death transition
#####################

const voice_bank = {
	"jump1": [
		preload("res://audio/sfx/mario/jump1/ya1.wav"),
		preload("res://audio/sfx/mario/jump1/ya2.wav"),
		preload("res://audio/sfx/mario/jump1/ya3.wav"),
	],
	"jump2": [
		preload("res://audio/sfx/mario/jump2/ma1.wav"),
		preload("res://audio/sfx/mario/jump2/ma2.wav"),
		preload("res://audio/sfx/mario/jump2/ma3.wav"),
	],
	"jump3": [
		preload("res://audio/sfx/mario/jump3/wahoo1.wav"),
		preload("res://audio/sfx/mario/jump3/wahoo2.wav"),
		preload("res://audio/sfx/mario/jump3/wahoo3.wav"),
		preload("res://audio/sfx/mario/jump3/wahoo4.wav"),
		preload("res://audio/sfx/mario/jump3/wahoo5.wav"),
	],
	"dive": [
		preload("res://audio/sfx/mario/dive/wa1.wav"),
		preload("res://audio/sfx/mario/dive/wa2.wav"),
		preload("res://audio/sfx/mario/dive/wa3.wav"),
	],
}

var jump_frames = -1
var vel = Vector2()
var double_jump_state = 0
var double_jump_frames = 0
var spin_timer = 0
var flip_l
var dive_return = false
var dive_frames = 0
var pound_frames = 0
var rocket_charge = 0
var jump_cancel = false
var sign_cooldown = 0
var jump_buffer = 0
var coyote_time = 0
var sign_x = null
var solid_floors = 0
var swim_delay = false

enum s { #state enum
	walk,
	frontflip, #triple jump
	backflip,
	spin,
	dive,
	diveflip,
	pound_spin,
	pound_fall,
	pound_land,
	door,
	ejump, #bouncing off a goomba
	swim,
}

enum n { #fludd enum
	none,
	hover,
	rocket,
	turbo,
}

var state = s.walk
var classic

func take_damage(amount):
	life_meter_counter = clamp(life_meter_counter - amount, 0, 8)
	invincibility_on_effect()

func take_damage_shove(amount, direction):
	take_damage_impact(amount, Vector2(4 * direction, -8))

func take_damage_impact(amount, impact_vel):
	take_damage(amount)
	vel = impact_vel

func recieve_health(amount):
	life_meter_counter = clamp(life_meter_counter + amount, 0, 8)

func dive_correct(factor): #Correct the player's origin position when diving
	#warning-ignore:return_value_discarded
	move_and_slide(Vector2(0, set_dive_correct * factor * 60), Vector2(0, -1))
	camera.position.y = min(0, -set_dive_correct * factor)

func play_voice(group_name):
	var group = voice_bank[group_name]
	var sound = group[randi() % group.size()]
	voice.stream = sound
	voice.play(0)

func update_classic():
	classic = $"/root/Singleton".classic #this isn't a filename don't change Main to lowercase lol
	if classic:
		set_wall_bounce = 0.5
	else:
		set_wall_bounce = 0.19

func switch_anim(new_anim):
	var fludd_anim
	match singleton.nozzle:
		n.hover:
			fludd_anim = "hover_" + new_anim
			if sprite.frames.has_animation(fludd_anim):
				sprite.animation = fludd_anim
			else:
				sprite.animation = new_anim
		n.rocket:
			fludd_anim = "rocket_" + new_anim
			if sprite.frames.has_animation(fludd_anim):
				sprite.animation = fludd_anim
			else:
				sprite.animation = new_anim
		n.turbo:
			fludd_anim = "turbo_" + new_anim
			if sprite.frames.has_animation(fludd_anim):
				sprite.animation = fludd_anim
			else:
				sprite.animation = new_anim
		_:
			sprite.animation = new_anim

func switch_state(new_state):
	state = new_state
	sprite.rotation_degrees = 0
	match state:
		s.dive:
			stand_box.disabled = true
			dive_box.disabled = false
		s.pound_fall:
			stand_box.disabled = false
			dive_box.disabled = true
			camera.smoothing_speed = 10
		_:
			stand_box.disabled = false
			dive_box.disabled = true
			camera.smoothing_speed = 5


func _ready():
	update_classic()
	timer.set_wait_time(1)
	if(singleton.dead):
		$Camera2D/GUI/Deathcontrol/deathanim.play("DeathOut")


func ground_friction(val, sub, div): #Ripped from source
	val = val/fps_mod
	var vel_sign = sign(val)
	val = abs(val)
	val -= sub
	val = max(0, val)
	val /= div
	val *= vel_sign
	return val*fps_mod


func _physics_process(_delta):
	
	if internal_coin_counter >= 5 && life_meter_counter < 8:
		life_meter_counter += 1
		internal_coin_counter = 0
	
	update_classic()
	if static_v:
		if sign_x != null:
			position.x = sign_x + (position.x - sign_x) * 0.75
	else:
		var i_left = Input.is_action_pressed("left")
		var i_right = Input.is_action_pressed("right")
		var i_down = Input.is_action_pressed("down")
		var i_jump = Input.is_action_just_pressed("jump")
		var i_jump_h = Input.is_action_pressed("jump")
		var i_semi = Input.is_action_pressed("semi")
		var i_dive = Input.is_action_just_pressed("dive")
		var i_dive_h = Input.is_action_pressed("dive")
		var i_spin = Input.is_action_just_pressed("spin")
		var i_spin_h = Input.is_action_pressed("spin")
		var i_pound_h = Input.is_action_pressed("pound")
		var i_fludd = Input.is_action_pressed("fludd")
		var i_switch = Input.is_action_just_pressed("switch_fludd")
#		if Input.is_action_just_pressed("debug"):
#			if i_jump_h:
#				$"/root/Main".classic = !classic
#				update_classic()
		var ground = is_on_floor()
		var wall = is_on_wall()
		var ceiling = is_on_ceiling()
		
		if ground:
			coyote_time = 5
		else:
			coyote_time = max(coyote_time - 1, 0)
		
		if i_jump_h:
			jump_buffer = max(jump_buffer - 1, 0)
			if i_jump:
				jump_buffer = 6
		else:
			jump_buffer = 0
		
		sign_cooldown = max(sign_cooldown - 1, 0)
		
		if i_switch:
			singleton.nozzle = (singleton.nozzle + 1) % 2
			var anim = sprite.animation.replace("hover_", "").replace("rocket_", "").replace("turbo_", "") #lazy way to refresh fludd anim
			switch_anim(anim)
			fludd_strain = false
			$switch.play()
		
		var fall_adjust = vel.y #Used to adjust downward acceleration to account for framerate difference
		if state == s.swim: #swimming is basically entirely different so it's wholly seperate
			if ground:
				switch_anim("walk")
			else:
				switch_anim("swim")
				if sprite.frame == 0:
					sprite.speed_scale = 0
			
			fall_adjust += grav / 3.0
			fall_adjust = ground_friction(fall_adjust, 0.05, 1.01);
			fall_adjust = ground_friction(fall_adjust, ((grav/fps_mod)/5), 1.05)
			fall_adjust = ground_friction(fall_adjust, 0, 1.001)
			vel.x = ground_friction(vel.x, 0, 1.001)
			if i_left == i_right:
				vel.x = ground_friction(vel.x, 0, 1.001)
			#fall_adjust = ground_friction(fall_adjust, 0.05, 1.1);
			if i_left && !i_right:
				sprite.flip_h = true
				if state == s.spin || state == s.backflip:
					vel.x -= max((set_air_accel+vel.x)/(set_air_speed_cap/(3*fps_mod)), 0) / (1.5 / fps_mod)
				else:
					vel.x -= max((set_air_accel+vel.x)/(set_air_speed_cap/(3*fps_mod)), 0)
			
			if i_right && !i_left:
				sprite.flip_h = false
				if state == s.spin || state == s.backflip:
					vel.x += max((set_air_accel-vel.x)/(set_air_speed_cap/(3*fps_mod)), 0) / (1.5 / fps_mod)
				else:
					vel.x += max((set_air_accel-vel.x)/(set_air_speed_cap/(3*fps_mod)), 0)
			if i_jump || i_semi:
				switch_anim("swim")
				if swim_delay:
					fall_adjust = min((- set_jump_1_vel) * 1.25, fall_adjust) * fps_mod
				else:
					fall_adjust = min((- set_jump_1_vel) * 1.25, fall_adjust)
				sprite.frame = 1
				sprite.speed_scale = 1
				swim_delay = true
			else:
				swim_delay = false
			if i_down:
				fall_adjust += 0.107
			vel.x = ground_friction(vel.x, 0.05, 1.05)
			vel.y += (fall_adjust - vel.y) * fps_mod #Adjust the Y velocity according to the framerate
		else:
			if state == s.diveflip:
				if flip_l:
					sprite.rotation_degrees -= 20
				else:
					sprite.rotation_degrees += 20
				if abs(sprite.rotation_degrees) > 360-20 || ground:
					switch_state(s.walk)
					sprite.rotation_degrees = 0
			elif dive_return:
				dive_frames -= 1
				if dive_frames == 0:
					switch_anim("jump")
					sprite.rotation_degrees += -90 if sprite.flip_h else 90
					dive_correct(-1)
					stand_box.disabled = false
					dive_box.disabled = true
					
				if sprite.rotation_degrees != 0 || dive_frames > 2:
					sprite.rotation_degrees += 10 if sprite.flip_h else -10
				else:
					dive_return = false
					switch_state(s.walk)
					sprite.rotation_degrees = 0
				
			if coyote_time > 0:
				jump_cancel = false
				if state == s.pound_fall:
					pound_frames = max(0, pound_frames - 1)
					if pound_frames <= 0:
						switch_state(s.walk)
						
				if ground: #specifically apply to when actually on the ground, not coyote time
					fall_adjust = 0 #set adjustable yvel to 0
					if state == s.dive:
						if double_jump_frames >= set_double_jump_frames - 1:
							vel.x = ground_friction(vel.x, 0.2, 1.02) #Double friction on landing
						vel.x = ground_friction(vel.x, 0.2, 1.02) #Floor friction
						if !dive_return:
							if angle_cast.is_colliding():
								#var diff = fmod(angle_cast.get_collision_normal().angle() + PI/2 - sprite.rotation, PI * 2)
								sprite.rotation = lerp_angle(sprite.rotation, angle_cast.get_collision_normal().angle() + PI/2, 0.5)
							elif solid_floors > 0:
								sprite.rotation = 0
					else:
						if double_jump_frames >= set_double_jump_frames - 1:
							vel.x = ground_friction(vel.x, 0.3, 1.15) #Double friction on landing
						vel.x = ground_friction(vel.x, 0.3, 1.15) #Floor friction
				
					if state == s.frontflip || state == s.backflip: #Reset state when landing
						switch_state(s.walk)
						sprite.rotation_degrees = 0
						tween.stop_all()
					
					if state == s.dive && abs(vel.x) == 0 && !i_dive_h && !dive_return:
						dive_return = true
						dive_frames = 4
						sprite.rotation_degrees = 0
				if state == s.walk:
					switch_anim("walk")
				
				double_jump_frames = max(double_jump_frames - 1, 0)
				if double_jump_frames <= 0:
					double_jump_state = 0
			else:
				if state == s.frontflip:
					if singleton.nozzle == n.none:
						if abs(sprite.rotation_degrees) < 700:
							switch_anim("flip")
						else:
							switch_anim("fall")
					else:
						if abs(sprite.rotation_degrees) < 340:
							switch_anim("flip")
						else:
							switch_anim("fall")
				elif state == s.walk:
					if vel.y > 0:
						switch_anim("fall")
					else:
						if double_jump_state == 2 && !jump_cancel:
							switch_anim("jump_double")
						else:
							switch_anim("jump")
				elif state == s.pound_fall:
					switch_anim("pound_fall")
				elif state == s.dive:
					if sprite.flip_h:
						sprite.rotation = lerp_angle(sprite.rotation, -atan2(vel.y, -vel.x), 0.5)
					else:
						sprite.rotation = lerp_angle(sprite.rotation, atan2(vel.y, vel.x), 0.5)
				
				if i_left == i_right:
					vel.x = ground_friction(vel.x, 0, 1.001) #Air decel

			if state == s.pound_spin:
				vel *= 0
			else:
				if state == s.pound_fall:
					fall_adjust += 0.814
				else:
					fall_adjust += grav
				
				if !ground:
					if state == s.pound_fall:
						pound_frames = 15
					if fall_adjust > 0:
						fall_adjust = ground_friction(fall_adjust, ((grav/fps_mod)/5), 1.05)
					fall_adjust = ground_friction(fall_adjust, 0, 1.001)
					if state == s.spin && !i_down:
						#fall_adjust = ground_friction(fall_adjust, 0.3, 1.05) #fastspin
						fall_adjust = ground_friction(fall_adjust, 0.1, 1.03)
					vel.x = ground_friction(vel.x, 0, 1.001) #Air friction
					
					jump_frames = max(jump_frames - 1, -1)
					
				vel.y += (fall_adjust - vel.y) * fps_mod #Adjust the Y velocity according to the framerate
			
			if i_jump_h:
				if coyote_time > 0:
					if state == s.dive:
						if ((int(i_right) - int(i_left) != -1) && !sprite.flip_h) || ((int(i_right) - int(i_left) != 1) && sprite.flip_h):
							if !dive_return && vel.x != 0 && !wall: #prevents static dive recover
								coyote_time = 0
								dive_correct(-1)
								switch_state(s.diveflip)
								vel.y = min(-set_jump_1_vel/1.5, vel.y)
								switch_anim("jump")
								flip_l = sprite.flip_h
						else:
							if !dive_return:
								dive_correct(-1)
							coyote_time = 0
							switch_state(s.backflip)
							vel.y = min(-set_jump_1_vel - 2.5 * fps_mod, vel.y)
							if sprite.flip_h:
								vel.x += (30.0 - abs(vel.x)) / (5 / fps_mod)
							else:
								vel.x -= (30.0 - abs(vel.x)) / (5 / fps_mod)
							dive_return = false
							tween.stop_all()
							if sprite.flip_h:
								tween.interpolate_property(sprite, "rotation_degrees", 0, 360, 0.6, 1, Tween.EASE_OUT, 0)
							else:
								tween.interpolate_property(sprite, "rotation_degrees", 0, -360, 0.6, 1, Tween.EASE_OUT, 0)
							tween.start()
							switch_anim("jump")
							flip_l = sprite.flip_h
						
						
					elif jump_buffer > 0 && state != s.pound_fall:
						jump_buffer = 0
						jump_frames = set_jump_mod_frames
						double_jump_frames = set_double_jump_frames
						coyote_time = 0
						match double_jump_state:
							0: #Single
								switch_state(s.walk)
								play_voice("jump1")
								vel.y = -set_jump_1_vel
								double_jump_state+=1
							1: #Double
								switch_state(s.walk)
								play_voice("jump2")
								vel.y = -set_jump_2_vel
								double_jump_state+=1
							2: #Triple
								if abs(vel.x) > set_triple_jump_deadzone:
									vel.y = -set_jump_3_vel
									vel.x += (vel.x + 15*fps_mod*sign(vel.x))/5*fps_mod
									double_jump_state = 0
									switch_state(s.frontflip)
									play_voice("jump3")
									tween.stop_all()
									if singleton.nozzle == n.none:
										tween.interpolate_property(sprite, "rotation_degrees", 0, -720 if sprite.flip_h else 720, 0.9, Tween.TRANS_QUART, Tween.EASE_OUT)
									else:
										tween.interpolate_property(sprite, "rotation_degrees", 0, -360 if sprite.flip_h else 360, 0.9, Tween.TRANS_QUART, Tween.EASE_OUT)
									tween.start()
									flip_l = sprite.flip_h
								else:
									vel.y = -set_jump_2_vel #Not moving left/right fast enough
									play_voice("jump2")
						
						if !classic:
							#warning-ignore:return_value_discarded
							move_and_collide(Vector2(0, -set_jump_1_tp)) #Suggested by Maker - slight upwards teleport
				elif jump_frames > 0 && state == s.walk:
					vel.y -= grav * pow(fps_mod, 3) #Variable jump height
		
			if i_left && !i_right && state != s.pound_spin:
				if (state != s.dive
				&& (state != s.diveflip || !classic)
				&& (state != s.frontflip || !classic)
				&& state != s.backflip
				&& state != s.pound_fall
				):
					sprite.flip_h = true
				if ground:
					if state != s.dive && state != s.pound_fall:
						vel.x -= set_walk_accel
				else:
					if state == s.pound_fall:
						vel.x *= 0.95
					if state == s.frontflip || state == s.spin || state == s.backflip:
						vel.x -= max((set_air_accel+vel.x)/(set_air_speed_cap/(3*fps_mod)), 0) / (1.5 / fps_mod)
					elif state == s.dive || state == s.diveflip:
						vel.x -= max((set_air_accel+vel.x)/(set_air_speed_cap/(3*fps_mod)), 0) / (8 / fps_mod)
					else:
						vel.x -= max((set_air_accel+vel.x)/(set_air_speed_cap/(3*fps_mod)), 0)
				
			if i_right && !i_left && state != s.pound_spin:
				if (state != s.dive
				&& (state != s.diveflip || !classic)
				&& (state != s.frontflip || !classic)
				&& state != s.backflip
				&& state != s.pound_fall
				):
					sprite.flip_h = false
				if ground:
					if state != s.dive && state != s.pound_fall:
						vel.x += set_walk_accel
				else:
					if state == s.frontflip || state == s.spin || state == s.backflip:
						vel.x += max((set_air_accel-vel.x)/(set_air_speed_cap/(3*fps_mod)), 0) / (1.5 / fps_mod)
					elif state == s.dive || state == s.diveflip:
						vel.x += max((set_air_accel-vel.x)/(set_air_speed_cap/(3*fps_mod)), 0) / (8 / fps_mod)
					else:
						vel.x += max((set_air_accel-vel.x)/(set_air_speed_cap/(3*fps_mod)), 0)
			
			if ground:
				singleton.power = 100
			elif !i_fludd && singleton.nozzle != n.hover:
				singleton.power = min(singleton.power + fps_mod, 100)
			
			if i_fludd && singleton.power > 0 && singleton.water > 0 && state != s.diveflip && (state != s.backflip || !classic) && state != s.spin && state != s.pound_spin && state != s.pound_fall && state != s.pound_land:
				match singleton.nozzle:
					n.hover:
						fludd_strain = true
						jump_cancel = true
						if classic || state != s.frontflip || (abs(sprite.rotation_degrees) < 90 || abs(sprite.rotation_degrees) > 270):
							if state == s.dive || state == s.frontflip:
								vel.y *= 1 - 0.02 * fps_mod
								vel.x *= 1 - 0.03 * fps_mod
								if ground:
									vel.x += cos(sprite.rotation)*pow(fps_mod, 2) * (-1 if sprite.flip_h else 1)
								elif state == s.dive:
									vel.y += sin(sprite.rotation * (-1 if sprite.flip_h else 1))*0.92*pow(fps_mod, 2)
									vel.x += cos(sprite.rotation)/2*pow(fps_mod, 2) * (-1 if sprite.flip_h else 1)
								else:
									if sprite.flip_h:
										vel.y += sin(-sprite.rotation - PI / 2)*0.92*pow(fps_mod, 2)
										vel.x -= cos(-sprite.rotation - PI / 2)*0.92/2*pow(fps_mod, 2)
									else:
										vel.y += sin(sprite.rotation - PI / 2)*0.92*pow(fps_mod, 2)
										vel.x += cos(sprite.rotation - PI / 2)*0.92/2*pow(fps_mod, 2)
							else:
								if singleton.power == 100:
									vel.y -= 2
								
								if i_jump_h:
									vel.y *= 1 - (0.12 * fps_mod)
								else:
									vel.y *= 1 - (0.2 * fps_mod)
								#vel.y -= (((9.2 * fps_mod)-vel.y * fps_mod)/(10 / fps_mod))*((singleton.power/(175 / fps_mod))+(0.75 * fps_mod))
								#vel.y -= (((9.2 * fps_mod)-vel.y * fps_mod)/10)*((singleton.power/(175))+(0.75 * fps_mod))
								vel.y -= (((-4*singleton.power*vel.y * fps_mod * fps_mod) + (-525*vel.y * fps_mod) + (368*singleton.power * fps_mod * fps_mod) + (48300)) / 7000) * pow(fps_mod, 5)
								vel.x = ground_friction(vel.x, 0.05, 1.03)
							singleton.water = max(0, singleton.water - 0.07 * fps_mod)
							singleton.power -= 1.5 * fps_mod
					n.rocket:
						if singleton.power == 100:
							fludd_strain = true
							rocket_charge += 1
						else:
							fludd_strain = false
						if rocket_charge >= 14 / fps_mod && (state != s.frontflip || (round(abs(sprite.rotation_degrees)) < 2 || round(abs(sprite.rotation_degrees)) > 358) || (!classic && (abs(sprite.rotation_degrees) < 20 || abs(sprite.rotation_degrees) > 340))):
							if state == s.dive:
								#set sign of velocity (could use ternary but they're icky)
								var multiplier = 1
								if sprite.flip_h:
									multiplier = -1
								if ground:
									multiplier *= 2 #double power when grounded to counteract friction
								vel += Vector2(cos(sprite.rotation)*25*fps_mod * fps_mod * multiplier, -sin(sprite.rotation - PI / 2)*25*fps_mod * fps_mod)
		#					elif state == s.frontflip:
		#						vel -= Vector2(-cos(sprite.rotation - PI / 2)*25*fps_mod, sin(sprite.rotation + PI / 2)*25*fps_mod)
							else:
								vel.y = min(max((vel.y/3),0) - 15.3, vel.y)
								vel.y -= 0.5 * fps_mod
							
							singleton.water = max(singleton.water - 5, 0)
							rocket_charge = 0
							singleton.power = 0
			else:
				fludd_strain = false
				rocket_charge = 0
			
			if i_dive_h && state != s.dive && (state != s.diveflip || (!classic && i_dive && sprite.flip_h != flip_l)) && state != s.pound_spin && (state != s.spin || (!classic && i_dive)): #dive
				if coyote_time > 0 && i_jump_h && abs(vel.x) > 1:
					coyote_time = 0
					dive_correct(-1)
					switch_state(s.diveflip)
					switch_anim("jump")
					flip_l = sprite.flip_h
					vel.y = min(-set_jump_1_vel/1.5, vel.y)
					double_jump_state = 0
				elif ((state != s.backflip || abs(sprite.rotation_degrees) > 270)
					&& state != s.pound_fall
					&& state != s.pound_spin):
					if !ground:
						coyote_time = 0
						if state != s.frontflip:
							play_voice("dive")
						var multiplier = 1
						if state == s.backflip:
							multiplier = 2
						if sprite.flip_h:
							vel.x -= (set_dive_speed - abs(vel.x / fps_mod)) / (5 / fps_mod) / fps_mod * multiplier
						else:
							vel.x += (set_dive_speed - abs(vel.x / fps_mod)) / (5 / fps_mod) / fps_mod * multiplier
						if state == s.walk:
							vel.y = max(-3, vel.y + 3.0 * fps_mod)
						else:
							vel.y += 3.0 * fps_mod
					switch_state(s.dive)
					rotation_degrees = 0
					tween.stop_all()
					switch_anim("dive")
					double_jump_state = 0
					dive_correct(1)
					
			
			if state == s.spin:
				if spin_timer > 0:
					spin_timer -= 1
				elif !i_spin_h:
					switch_state(s.walk)

			if (i_spin_h
			&& state != s.spin
			&& state != s.frontflip
			&& state != s.dive
			&& state != s.backflip
			&& (state != s.diveflip || (!classic && i_spin))
			&& (vel.y > -3.3 * fps_mod || (!classic && state == s.diveflip))
			&& state != s.pound_fall
			&& state != s.pound_spin):
				switch_state(s.spin)
				switch_anim("spin")
				vel.y = min(-3.5 * fps_mod, vel.y - 3.5 * fps_mod)
				spin_timer = 30
			
			if i_pound_h && !ground && state != s.pound_spin && state != s.pound_fall && (state != s.dive || !classic) && (state != s.diveflip || !classic) && (state != s.spin || !classic):
				switch_state(s.pound_spin)
				tween.stop_all()
				tween.interpolate_property(sprite, "rotation_degrees", 0, -360 if sprite.flip_h else 360, 0.25)
				tween.start()
		
		if wall:
			if int(i_right) - int(i_left) != sign(int(vel.x)) && int(vel.x) != 0:
				vel.x = -vel.x*set_wall_bounce #Bounce off a wall when not intentionally pushing into it
			else:
				vel.x = 0 #Cancel X velocity when intentionally pushing into a wall
				
		if ceiling:
			vel.y = max(vel.y, 0.1)
		
		var snap
		if (!ground && !i_jump_h) || jump_buffer > 0 || state == s.diveflip || (i_fludd && singleton.nozzle == n.hover) || (state == s.swim && i_semi):
			snap = Vector2.ZERO
		else:
			snap = Vector2(0, 4)
			
		var save_pos = position
		#warning-ignore:return_value_discarded
		move_and_slide_with_snap(vel*60.0, snap, Vector2(0, -1), true)
		var slide_vec = position-save_pos
		position = save_pos
		if slide_vec.length() > 0.5 || state == s.swim:
			#warning-ignore:return_value_discarded
			move_and_slide_with_snap(vel*60.0 * (vel.length()/slide_vec.length()), snap, Vector2(0, -1), true, 4, deg2rad(47))
	bubbles_medium.emitting = fludd_strain
	bubbles_small.emitting = fludd_strain
	var rot_offset = PI/2
	var center = position#get_global_transform_with_canvas().origin
	if state == s.dive:
		bubbles_medium.position.y = -9
		bubbles_small.position.y = -9
		if sprite.flip_h:
			rot_offset = 0
			bubbles_medium.position.x = -1
			bubbles_small.position.x = -1

		else:
			rot_offset = PI
			bubbles_medium.position.x = 1
			bubbles_small.position.x = 1
	else:
		bubbles_medium.position.y = -3
		bubbles_small.position.y = -3
		if sprite.flip_h:
			bubbles_medium.position.x = 11
			bubbles_small.position.x = 11
		else:
			bubbles_medium.position.x = -11
			bubbles_small.position.x = -11
	#offset bubbles to mario's center
	bubbles_medium.position += center
	bubbles_small.position += center
	#give it shader data
	bubbles_medium.process_material.set_shader_param("direction", Vector3(cos(sprite.rotation + rot_offset), sin(sprite.rotation + rot_offset), 0))
	bubbles_small.process_material.set_shader_param("direction", Vector3(cos(sprite.rotation + rot_offset), sin(sprite.rotation + rot_offset), 0))
	
	if sprite.animation.ends_with("walk"):
		if round(vel.x) == 0:
			sprite.frame = 0
			sprite.speed_scale = 0
		else:
			if sprite.speed_scale == 0:
				sprite.frame = 1
			sprite.speed_scale = min(abs(vel.x / 3.43), 2)
	elif !sprite.animation.ends_with("swim"):
		sprite.speed_scale = 1
	$Label.text = str(vel.x)
	if life_meter_counter == 1:
		timer.start()
	if life_meter_counter <= 0:
		singleton.dead = true
		$Camera2D/GUI/Deathcontrol/deathanim.play("DeathIn")



func _on_Tween_tween_completed(_object, _key):
	if state == s.pound_spin:
		switch_state(s.pound_fall)
		vel.y = 8
	else:
		switch_state(s.walk)


func _on_BackupAngle_body_entered(_body):
	solid_floors += 1


func _on_BackupAngle_body_exited(_body):
	solid_floors -= 1
	
func mario():
	get_tree().reload_current_scene()

func invincibility_on_effect():
	invincible = true
	print("placeholder effect for flashing sprite")

func after_transition():
	$Camera2D/GUI/Deathcontrol/deathanim.stop()
	singleton.dead = false
