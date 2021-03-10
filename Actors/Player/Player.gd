extends KinematicBody2D;

const fpsMod = 32.0 / 60.0; #Multiplier to account for 60fps
const grav = fpsMod;

const setJumpTP = 3;
const setDJumpTP = setJumpTP * 1.25;
const setTJumpTP = setJumpTP * 1.5;
const setAirSpeedCap = 20.0*fpsMod;
const setWalkAccel = 1.2 * fpsMod;
const setAirAccel = 5.0 * fpsMod; #Functions differently to WalkAccel
const setWalkDecel = setWalkAccel * 1.1; #Suggested by Maker - decel is faster than accel in casual mode
const setAirDecel = setAirAccel * 1.1;
const setJumpVel = 10 * fpsMod;
const setDJumpVel = setJumpVel + 2.5 * fpsMod;
const setTJumpVel = setJumpVel + 5.0 * fpsMod;
var setWallBounce;
const setJumpModFrames = 13;
const setDoubleJumpFrames = 17;
const setTJumpDeadzone = 3.0 * fpsMod;
const setDiveSpeed = 35.0 * fpsMod;
const setDiveCorrect = 7;

onready var voice = $Voice;
onready var tween = $Tween;
onready var sprite = $AnimatedSprite;
onready var camera = $Camera2D;

const voiceBank = {
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
};

var jumpFrames = -1;
var vel = Vector2();
var doubleJumpState = 0;
var doubleJumpFrames = 0;
var spinTimer = 0;
var flipL;

enum s {
	Walk,
	Frontflip,
	Backflip,
	Spin,
	Dive,
	Diveflip,
	Pound,
	Door,
}

var state = s.Walk;
var classic;

func screen_handling():
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen;
	if Input.is_action_just_pressed("screen+"):
		OS.window_size = OS.window_size * 2;
	if Input.is_action_just_pressed("screen-"):
		OS.window_size = OS.window_size / 2;
	var zoomFactor = 448/OS.window_size.x;
	camera.zoom = Vector2(zoomFactor, zoomFactor);

func play_voice(groupName):
	var group = voiceBank[groupName];
	var sound = group[randi() % group.size()];
	voice.stream = sound;
	voice.play(0);

func update_classic():
	classic = $"/root/Main".classic;
	if classic:
		setWallBounce = 0.5;
	else:
		setWallBounce = 0.19;
		
func switch_state(newState):
	state = newState;
	sprite.rotation_degrees = 0;
	match state:
		s.Dive:
			$StandHitbox.disabled = true;
			$DiveHitbox.disabled = false;
		_:
			$StandHitbox.disabled = false;
			$DiveHitbox.disabled = true;

func _ready():
	update_classic();

func ground_friction(val, sub, div): #Ripped from source
	val = val/fpsMod;
	var velSign = sign(val);
	val = abs(val);
	val -= sub;
	val = max(0, val);
	val /= div;
	val *= velSign;
	return val*fpsMod;

var debugMaxYVel = 0;
func _physics_process(_delta):
	var iLeft = Input.is_action_pressed("left");
	var iRight = Input.is_action_pressed("right");
	var iDown = Input.is_action_pressed("down");
	var iJump = Input.is_action_just_pressed("jump");
	var iJumpH = Input.is_action_pressed("jump");
	var iDive = Input.is_action_just_pressed("dive");
	var iDiveH = Input.is_action_pressed("dive");
	var iSpin = Input.is_action_just_pressed("spin");
	var iSpinH = Input.is_action_pressed("spin");
	if (Input.is_action_just_pressed("debug")):
		if iJumpH:
			#get_tree().change_scene("res://level_designer.tscn");
			get_tree().change_scene("res://scenes/castle/lobby/castle_lobby.tscn");
		else:
			$"/root/Main".classic = !classic;
			update_classic();
	var ground = is_on_floor();
	var wall = is_on_wall();
	var ceiling = is_on_ceiling();
	
	var fallAdjust = vel.y; #Used to adjust downward acceleration to account for framerate differenc
	if state == s.Diveflip:
		if flipL:
			sprite.rotation_degrees -= 20;
		else:
			sprite.rotation_degrees += 20;
		if abs(sprite.rotation_degrees) > 360-20 || ground:
			switch_state(s.Walk);
			sprite.rotation_degrees = 0;
#	elif state == s.Frontflip:
#		if flipL:
#			sprite.rotation_degrees -= 14;
#		else:
#			sprite.rotation_degrees += 14;
#		if abs(sprite.rotation_degrees) > 720-14:
#			state = s.Walk;
#			sprite.rotation_degrees = 0;
		
	if ground:
		fallAdjust = 0;
		if state == s.Dive:
			vel.x = ground_friction(vel.x, 0.2, 1.05); #Floor friction
		else:
			vel.x = ground_friction(vel.x, 0.3, 1.15); #Floor friction
		
		if state == s.Frontflip || state == s.Backflip: #Reset state when landing
			switch_state(s.Walk);
			sprite.rotation_degrees = 0;
			tween.stop_all();
		
		if state == s.Dive && abs(vel.x) == 0 && !iDiveH:
			move_and_slide(Vector2(0, -setDiveCorrect)*60, Vector2(0, -1));
			switch_state(s.Walk);
		if state == s.Walk:
			sprite.animation = "walk";
			
		doubleJumpFrames = max(doubleJumpFrames - 1, 0);
		if doubleJumpFrames <= 0:
			doubleJumpState = 0;
	else:
		if state == s.Frontflip:
			sprite.animation = "flip";
		elif state == s.Walk:
			if vel.y > 0:
				sprite.animation = "fall";
			else:
				sprite.animation = "jump";
				
		if iLeft == iRight:
			vel.x = ground_friction(vel.x, 0, 1.001); #Air decel

	fallAdjust += grav;
	
	if !ground:
		if fallAdjust > 0:
			fallAdjust = ground_friction(fallAdjust, ((grav/fpsMod)/5), 1.05);
		fallAdjust = ground_friction(fallAdjust, 0, 1.001);
		if state == s.Spin && !iDown:
			#fallAdjust = ground_friction(fallAdjust, 0.3, 1.05); #fastspin
			fallAdjust = ground_friction(fallAdjust, 0.1, 1.03);
		vel.x = ground_friction(vel.x, 0, 1.001); #Air friction
		
		jumpFrames = max(jumpFrames - 1, -1);
		
	vel.y += (fallAdjust - vel.y) * fpsMod; #Adjust the Y velocity according to the framerate
	
	if iJumpH:
		if ground:
			if state == s.Dive:
				move_and_slide(Vector2(0, -setDiveCorrect)*60, Vector2(0, -1)); #Correct for hitbox positioning
				if ((int(iRight) - int(iLeft) != -1) && !sprite.flip_h) || ((int(iRight) - int(iLeft) != 1) && sprite.flip_h):
					switch_state(s.Diveflip);
					vel.y = min(-setJumpVel/1.5, vel.y);
				else:
					switch_state(s.Backflip);
					vel.y = min(-setJumpVel - 2.0 * fpsMod, vel.y);
					if sprite.flip_h:
						vel.x += (30.0 - abs(vel.x)) / (5 / fpsMod);
					else:
						vel.x -= (30.0 - abs(vel.x)) / (5 / fpsMod);
					if sprite.flip_h:
						tween.interpolate_property(sprite, "rotation_degrees", 0, 360, 0.6, 1, Tween.EASE_OUT, 0);
					else:
						tween.interpolate_property(sprite, "rotation_degrees", 0, -360, 0.6, 1, Tween.EASE_OUT, 0);
					tween.start();
				sprite.animation = "jump";
				flipL = sprite.flip_h;
				
			elif iJump:
				jumpFrames = setJumpModFrames;
				doubleJumpFrames = setDoubleJumpFrames;
				
				match doubleJumpState:
					0: #Single
						switch_state(s.Walk);
						play_voice("jump1");
						vel.y = -setJumpVel;
						doubleJumpState+=1;
					1: #Double
						switch_state(s.Walk);
						play_voice("jump2");
						vel.y = -setDJumpVel;
						doubleJumpState+=1;
					2: #Triple
						if abs(vel.x) > setTJumpDeadzone:
							vel.y = -setTJumpVel;
							vel.x += (vel.x + 15*fpsMod*sign(vel.x))/5*fpsMod;
							doubleJumpState = 0;
							switch_state(s.Frontflip);
							play_voice("jump3");
							if sprite.flip_h:
								tween.interpolate_property(sprite, "rotation_degrees", 0, -720, 1, 1, Tween.EASE_OUT, 0);
							else:
								tween.interpolate_property(sprite, "rotation_degrees", 0, 720, 1, 1, Tween.EASE_OUT, 0);
							tween.start();
							flipL = sprite.flip_h;
						else:
							vel.y = -setDJumpVel; #Not moving left/right fast enough
							play_voice("jump2");
				
				if !classic:
					move_and_collide(Vector2(0, -setJumpTP)); #Suggested by Maker - slight upwards teleport
		elif jumpFrames > 0 && state == s.Walk:
			vel.y -= grav * pow(fpsMod, 3); #Variable jump height
	
	debugMaxYVel = max(debugMaxYVel, vel.y);
	
	if iLeft && !iRight:
		if state != s.Dive && (state != s.Diveflip || !classic) && (state != s.Frontflip || !classic) && state != s.Backflip:
			sprite.flip_h = true;
		if ground:
			if state != s.Dive:
				vel.x -= setWalkAccel;
		else:
			if state == s.Frontflip || state == s.Spin:
				vel.x -= max((setAirAccel+vel.x)/(setAirSpeedCap/(3*fpsMod)), 0) / (1.5 / fpsMod);
			elif state == s.Dive || state == s.Diveflip:
				vel.x -= max((setAirAccel+vel.x)/(setAirSpeedCap/(3*fpsMod)), 0) / (8 / fpsMod);
			else:
				vel.x -= max((setAirAccel+vel.x)/(setAirSpeedCap/(3*fpsMod)), 0);
			
	if iRight && !iLeft:
		if state != s.Dive && (state != s.Diveflip || !classic) && (state != s.Frontflip || !classic) && state != s.Backflip:
			sprite.flip_h = false;
		if ground:
			if state != s.Dive:
				vel.x += setWalkAccel;
		else:
			if state == s.Frontflip || state == s.Spin:
				vel.x += max((setAirAccel-vel.x)/(setAirSpeedCap/(3*fpsMod)), 0) / (1.5 / fpsMod);
			elif state == s.Dive || state == s.Diveflip:
				vel.x += max((setAirAccel-vel.x)/(setAirSpeedCap/(3*fpsMod)), 0) / (8 / fpsMod);
			else:
				vel.x += max((setAirAccel-vel.x)/(setAirSpeedCap/(3*fpsMod)), 0);
	
	if iDiveH && state != s.Dive && (state != s.Diveflip || (!classic && iDive && sprite.flip_h != flipL)) && state != s.Pound  && (state != s.Spin || (!classic && iDive)): #Dive
		if ground && iJumpH:
			move_and_slide(Vector2(0, -setDiveCorrect)*60, Vector2(0, -1));
			switch_state(s.Diveflip);
			sprite.animation = "jump";
			flipL = sprite.flip_h;
			vel.y = min(-setJumpVel/1.5, vel.y);
			doubleJumpState = 0;
		elif state != s.Backflip || abs(sprite.rotation_degrees) > 270:
			switch_state(s.Dive);
			rotation_degrees = 0;
			tween.stop_all();
			sprite.animation = "dive";
			doubleJumpState = 0;
			if ground:
				move_and_slide(Vector2(0, setDiveCorrect)*60, Vector2(0, -1));
			else:
				play_voice("dive");
				if sprite.flip_h:
					vel.x -= (setDiveSpeed - abs(vel.x)) / (5 / fpsMod) / fpsMod;
				else:
					vel.x += (setDiveSpeed - abs(vel.x)) / (5 / fpsMod) / fpsMod;
				vel.y += 3.0 * fpsMod;
	
	if state == s.Spin:
		if spinTimer > 0:
			spinTimer -= 1;
		elif !iSpinH:
			switch_state(s.Walk);
	
	if (iSpinH
	&& state != s.Spin
	&& state != s.Frontflip
	&& state != s.Pound
	&& state != s.Dive
	&& (state != s.Diveflip || (!classic && iSpin))
	&& (vel.y > -3.3 * fpsMod || (!classic && state == s.Diveflip))):
		switch_state(s.Spin);
		sprite.animation = "spin";
		vel.y = min(-3.3 * fpsMod, vel.y - 3.3 * fpsMod);
		spinTimer = 30;
	
	if wall:
		if int(iRight) - int(iLeft) != sign(int(vel.x)) && int(vel.x) != 0:
			vel.x = -vel.x*setWallBounce; #Bounce off a wall when not intentionally pushing into it
		else:
			vel.x = 0; #Cancel X velocity when intentionally pushing into a wall
			
	if ceiling:
		vel.y = max(vel.y, 0.1);
	
	var snap;
	if !ground || iJump || state == s.Diveflip:
		snap = Vector2.ZERO;
		
	else:
		snap = Vector2(0, 4);
		
	var savePos = position;
	move_and_slide_with_snap(vel*60, snap, Vector2(0, -1), true);
	var slideVec = position-savePos;
	position = savePos;
	if slideVec.length() > 0.5:
		move_and_slide_with_snap(vel*60 * (vel.length()/slideVec.length()), snap, Vector2(0, -1), true);
	
	$Label.text = String(vel.x);

	screen_handling();

func _on_Tween_tween_completed(object, key):
	switch_state(s.Walk);
