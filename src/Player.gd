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

onready var voice = $Voice;

const voiceBank = {
	"jump1": [
		preload("res://Audio/SFX/Mario/Ma1.ogg"),
		preload("res://Audio/SFX/Mario/Ma2.ogg"),
		preload("res://Audio/SFX/Mario/Ma3.ogg"),
		#preload("res://Audio/SFX/Mario/Ha4.ogg"),
	],
	"jump2": [
		preload("res://Audio/SFX/Mario/Ya1.ogg"),
		preload("res://Audio/SFX/Mario/Ya2.ogg"),
		#preload("res://Audio/SFX/Mario/Ya3.ogg"),
		preload("res://Audio/SFX/Mario/Ya4.ogg"),
	],
	"jump3": [
		preload("res://Audio/SFX/Mario/Wahoo1.ogg"),
		preload("res://Audio/SFX/Mario/Wahoo2.ogg"),
	],
	"dive": [
		preload("res://Audio/SFX/Mario/Ha1.ogg"),
		preload("res://Audio/SFX/Mario/Ha2.ogg"),
		preload("res://Audio/SFX/Mario/Ha3.ogg"),
		#preload("res://Audio/SFX/Mario/Ha4.ogg"),
#		preload("res://Audio/SFX/Mario/Ya1.ogg"),
#		preload("res://Audio/SFX/Mario/Ya2.ogg"),
#		#preload("res://Audio/SFX/Mario/Ya3.ogg"),
#		preload("res://Audio/SFX/Mario/Ya4.ogg"),
	],
};

var jumpFrames = -1;
var vel = Vector2();
var doubleJumpState = 0;
var doubleJumpFrames = 0;
var spinTimer = 0;
var diveFlipL;

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
	$AnimatedSprite.rotation_degrees = 0;
	match state:
		s.Dive:
			$StandHitbox.disabled = true;
			$DiveHitbox.disabled = false;
		_:
			$StandHitbox.disabled = false;
			$DiveHitbox.disabled = true;

func _ready():
	update_classic();

func ground_friction(vel, sub, div): #Ripped from source
	vel = vel/fpsMod;
	var velSign = sign(vel);
	vel = abs(vel);
	vel -= sub;
	vel = max(0, vel);
	vel /= div;
	vel *= velSign;
	return vel*fpsMod;

var debugMaxYVel = 0;
func _physics_process(delta):
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
			get_tree().change_scene("res://LevelDesigner.tscn");
		else:
			$"/root/Main".classic = !classic;
			update_classic();
	var ground = is_on_floor();
	var wall = is_on_wall();
	var ceiling = is_on_ceiling();
	
	var fallAdjust = vel.y; #Used to adjust downward acceleration to account for framerate differenc
	if state == s.Diveflip:
		if diveFlipL:
			$AnimatedSprite.rotation_degrees -= 20;
		else:
			$AnimatedSprite.rotation_degrees += 20;
		if abs($AnimatedSprite.rotation_degrees) > 360-20:
			state = s.Walk;
			$AnimatedSprite.rotation_degrees = 0;
		
	if ground:
		fallAdjust = 0;
		if state == s.Dive:
			vel.x = ground_friction(vel.x, 0.2, 1.05); #Floor friction
		else:
			vel.x = ground_friction(vel.x, 0.3, 1.15); #Floor friction
		
		if state == s.Frontflip || state == s.Backflip: #Reset state when landing
			switch_state(s.Walk);
			
		if state == s.Walk:
			$AnimatedSprite.animation = "walk";
			
		doubleJumpFrames = max(doubleJumpFrames - 1, 0);
		if doubleJumpFrames <= 0:
			doubleJumpState = 0;
	else:
		if state == s.Frontflip:
			$AnimatedSprite.animation = "flip";
		elif state == s.Walk:
			if vel.y > 0:
				$AnimatedSprite.animation = "fall";
			else:
				$AnimatedSprite.animation = "jump";
				
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
				move_and_slide(Vector2(0, -4.5)*60, Vector2(0, -1));
				switch_state(s.Diveflip);
				$AnimatedSprite.animation = "jump";
				diveFlipL = $AnimatedSprite.flip_h;
				vel.y = min(-setJumpVel/1.5, vel.y);
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
						else:
							vel.y = -setDJumpVel; #Not moving left/right fast enough
							play_voice("jump2");
				
				if !classic:
					move_and_collide(Vector2(0, -setJumpTP)); #Suggested by Maker - slight upwards teleport
		elif jumpFrames > 0 && state == s.Walk:
			vel.y -= grav * pow(fpsMod, 3); #Variable jump height
	
	debugMaxYVel = max(debugMaxYVel, vel.y);
	
	if iLeft && !iRight:
		if state != s.Dive && (state != s.Diveflip || !classic):
			$AnimatedSprite.flip_h = true;
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
		if state != s.Dive && (state != s.Diveflip || !classic):
			$AnimatedSprite.flip_h = false;
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
	
	if iDiveH && state != s.Dive && (state != s.Diveflip || (!classic && iDive && $AnimatedSprite.flip_h != diveFlipL)) && state != s.Pound  && (state != s.Spin || (!classic && iDive)): #Dive
		if ground && iJumpH:
			move_and_slide(Vector2(0, -4.5)*60, Vector2(0, -1));
			switch_state(s.Diveflip);
			$AnimatedSprite.animation = "jump";
			diveFlipL = $AnimatedSprite.flip_h;
			vel.y = min(-setJumpVel/1.5, vel.y);
		else:
			switch_state(s.Dive);
			$AnimatedSprite.animation = "dive";
			doubleJumpState = 0;
			if ground:
				move_and_slide(Vector2(0, 4.5)*60, Vector2(0, -1));
			else:
				play_voice("dive");
				if $AnimatedSprite.flip_h:
					vel.x -= (setDiveSpeed - abs(vel.x)) / (5 / fpsMod) / fpsMod;
				else:
					vel.x += (setDiveSpeed - abs(vel.x)) / (5 / fpsMod) / fpsMod;
				vel.y += 3.0 * fpsMod;
	
	if state == s.Spin:
		if spinTimer > 0:
			spinTimer -= 1;
		elif !iSpinH:
			state = s.Walk;
	
	if iSpinH && state != s.Spin && state != s.Frontflip && state != s.Pound && state != s.Dive && (state != s.Diveflip || (!classic && iSpin)) && vel.y > -3.3 * fpsMod:
		switch_state(s.Spin);
		$AnimatedSprite.animation = "spin";
		vel.y = min(-3.3 * fpsMod, vel.y - 3.3 * fpsMod);
		spinTimer = 30;
	
	if wall:
		if int(iRight) - int(iLeft) != sign(int(vel.x)) && int(vel.x) != 0:
			vel.x = -vel.x*setWallBounce; #Bounce off a wall when not intentionally pushing into it
		else:
			vel.x = 0; #Cancel X velocity when intentionally pushing into a wall
			
	if ceiling:
		vel.y = 0.1;
	
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
