extends KinematicBody2D;

const fpsMod = 32.0/60.0; #Multiplier to account for 60fps
const grav = fpsMod;
const setRolloutVel = 6.5*fpsMod;

const setSpinTime = 40;
const setLandTimer = 10;
const setTermYVel = 12*fpsMod;
const setSpinTermYVel = setTermYVel/1.5;
const setSpinGravMod = 1.5;
const setSpinBob = 4.0*fpsMod;
const setJumpTP = 3;
const setDJumpTP = 3;
const setTJumpTP = 3;
const setJumpMod = 1.2;
const setWalkSpeedCap = 6.7*fpsMod;
const setDiveSpeedCap = 10;
const setAirSpeedCap = 20.0*fpsMod;
const setWalkAccel = 1.2*fpsMod;
const setAirAccel = 5.0*fpsMod; #Functions differently to WalkAccel
const setDiveAccel = setAirAccel;
const setTJumpAccel = setAirAccel;
const setGPAccel = setAirAccel*0.25;
const setWalkDeceleration = setWalkAccel;
const setAirDeceleration = setAirAccel;
const setJumpVel = 10*fpsMod;
const setDJumpVel = 11.5*fpsMod;
const setTJumpYVel = 12.0*fpsMod;
const setTJumpXVel = setWalkSpeedCap*1.5;
const setBackflipYVel = setJumpVel+2.0*fpsMod;
const setBackflipXVel = 6;
const setGPYVel = 9.5;
const setGPXvelCap = 1.5;
const setDiveSpeed = 35.0*fpsMod;
const setBackflipSpeed = 30.0*fpsMod;
const setBackflipTorque = 11.25;
const setRolloutTorque = 18;
const setWallBounce = 0.35*fpsMod;

const setJumpModFrames = 3;

var jumpFrames = -1;
var vel = Vector2();

enum s {
	Walk,
	Triple,
	Spin,
	Dive,
	Pound,
	Door,
}

var state = s.Walk;

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
	var iDive = Input.is_action_just_pressed("dive");
	var ground = is_on_floor();
	var wall = is_on_wall();
	var ceiling = is_on_ceiling();
	
	if ground:
		vel.x = ground_friction(vel.x, 0.3, 1.15);
		$AnimatedSprite.animation = "walk";
	else:
		if vel.y > 0:
			$AnimatedSprite.animation = "fall";
		else:
			$AnimatedSprite.animation = "jump";
				
		if iLeft == iRight:
			vel.x = ground_friction(vel.x, 0, 1.001); #Floor friction
		
	var fallAdjust = vel.y; #Used to adjust downward acceleration to account for framerate difference
	
	if ground:
		fallAdjust = 0;
	if (state == s.Spin && vel.y > 0):
		fallAdjust = min(vel.y + grav/setSpinGravMod, setSpinTermYVel);
	elif (state == s.Pound):
		fallAdjust = min(vel.y + grav, setGPYVel);
	else:
		fallAdjust += grav;
	
	if !ground:
		
		if fallAdjust > 0:
			fallAdjust = ground_friction(fallAdjust, ((grav/fpsMod)/5), 1.05);
		fallAdjust = ground_friction(fallAdjust, 0, 1.001);
		vel.x = ground_friction(vel.x, 0, 1.001);
		
		jumpFrames = max(jumpFrames - 1, -1);
		
	vel.y += (fallAdjust - vel.y) * fpsMod; #Adjust the Y velocity according to the framerate
	
	debugMaxYVel = max(debugMaxYVel, vel.y);
	
	if iLeft:
		$AnimatedSprite.flip_h = true;
		if ground:
			vel.x -= setWalkAccel;
		else:
			vel.x -= max((vel.x+setAirAccel)/(setAirSpeedCap/(3*fpsMod)), 0); #Ripped from source
	if iRight:
		$AnimatedSprite.flip_h = false;
		if ground:
			vel.x += setWalkAccel;
		else:
			vel.x -= min((vel.x-setAirAccel)/(setAirSpeedCap/(3*fpsMod)), 0); #Ripped from source
	if iJump && ground:
		jumpFrames = setJumpModFrames;
		vel.y = -setJumpVel;
		move_and_collide(Vector2(0, -setJumpTP)); #Suggested by Maker
	elif iJumpH && !ground && jumpFrames > 0:
		vel.y = -setJumpVel;
		
	if iDive && state != s.Dive:
		state = s.Dive;
	
	if wall:
		if int(iRight) - int(iLeft) != sign(int(vel.x)):
			vel.x = -vel.x*setWallBounce;
		else:
			vel.x = 0;
			
	if ceiling:
		vel.y = 0.1;
	
	move_and_slide(vel*60, Vector2(0, -1));
	
	$RichTextLabel.text = String(vel.y);
