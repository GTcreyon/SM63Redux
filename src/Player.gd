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

var jumpFrames = -1;
var vel = Vector2();
var doubleJumpState = 0;
var doubleJumpFrames = 0;

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

func update_classic():
	classic = $"/root/Main".classic;
	if classic:
		setWallBounce = 0.5;
	else:
		setWallBounce = 0.19;
		
func switch_state(newState):
	state = newState;
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
	var iJump = Input.is_action_just_pressed("jump");
	var iJumpH = Input.is_action_pressed("jump");
	var iDive = Input.is_action_pressed("dive");
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
		if $AnimatedSprite.flip_h:
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
		vel.x = ground_friction(vel.x, 0, 1.001); #Air friction
		
		jumpFrames = max(jumpFrames - 1, -1);
		
	vel.y += (fallAdjust - vel.y) * fpsMod; #Adjust the Y velocity according to the framerate
	
	if iJumpH:
		if ground:
			if state == s.Dive:
				switch_state(s.Diveflip);
				$AnimatedSprite.animation = "jump";
				vel.y = min(-setJumpVel/1.5, vel.y);
			elif iJump:
				jumpFrames = setJumpModFrames;
				doubleJumpFrames = setDoubleJumpFrames;
				
				match doubleJumpState:
					0: #Single
						vel.y = -setJumpVel;
						doubleJumpState+=1;
					1: #Double
						vel.y = -setDJumpVel;
						doubleJumpState+=1;
					2: #Triple
						if abs(vel.x) > setTJumpDeadzone:
							vel.y = -setTJumpVel;
							vel.x += (vel.x + 15*fpsMod*sign(vel.x))/5*fpsMod;
							doubleJumpState = 0;
							switch_state(s.Frontflip);
						else:
							vel.y = -setDJumpVel; #Not moving left/right fast enough
				
				if !classic:
					move_and_collide(Vector2(0, -setJumpTP)); #Suggested by Maker - slight upwards teleport
		elif jumpFrames > 0 && state == s.Walk:
			vel.y -= grav * pow(fpsMod, 3); #Variable jump height
	
	debugMaxYVel = max(debugMaxYVel, vel.y);
	
	if iLeft && state != s.Diveflip:
		if state != s.Dive:
			$AnimatedSprite.flip_h = true;
		if ground:
			if state != s.Dive:
				vel.x -= setWalkAccel;
		else:
			if state == s.Frontflip:
				vel.x -= max((vel.x+setAirAccel)/(setAirSpeedCap/(3*fpsMod)), 0) / (1.5 / fpsMod);
			elif state == s.Dive:
				vel.x -= max((vel.x+setAirAccel)/(setAirSpeedCap/(3*fpsMod)), 0) / (8 / fpsMod);
			else:
				vel.x -= max((vel.x+setAirAccel)/(setAirSpeedCap/(3*fpsMod)), 0);
			
	if iRight:
		if state != s.Dive && state != s.Diveflip:
			$AnimatedSprite.flip_h = false;
		if ground:
			if state != s.Dive:
				vel.x += setWalkAccel;
		else:
			if state == s.Frontflip:
				vel.x -= min((vel.x-setAirAccel)/(setAirSpeedCap/(3*fpsMod)), 0) / (1.5 / fpsMod);
			elif state == s.Dive || state == s.Diveflip:
				vel.x -= min((vel.x-setAirAccel)/(setAirSpeedCap/(3*fpsMod)), 0) / (8 / fpsMod);
			else:
				vel.x -= min((vel.x-setAirAccel)/(setAirSpeedCap/(3*fpsMod)), 0);
		
	if iDive && state != s.Dive && state != s.Diveflip: #Dive
		if ground && iJumpH:
			switch_state(s.Diveflip);
			$AnimatedSprite.animation = "jump";
			vel.y = min(-setJumpVel/1.5, vel.y);
		else:
			switch_state(s.Dive);
			$AnimatedSprite.animation = "dive";
			doubleJumpState = 0;
			move_and_collide(Vector2(0, 6));
			if !ground:
				if $AnimatedSprite.flip_h:
					vel.x += (vel.x - setDiveSpeed) / (5 / fpsMod) / fpsMod;
				else:
					vel.x += (vel.x + setDiveSpeed) / (5 / fpsMod) / fpsMod;
				vel.y += 3.0 * fpsMod;
			
	
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
