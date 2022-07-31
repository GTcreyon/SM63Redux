extends StaticBody2D
tool

onready var detect_area = $DetectionBox
onready var detect_shape = $DetectionBox/CollisionShape2D
onready var ouchies_area = $Hurtbox
onready var peek_zone = $PeekZone
onready var peek_shape = $PeekZone/CollisionShape2D
onready var sprite = $Sprite
onready var sfx = $SFXUmph
onready var dustleft = $DustLeft
onready var dustright = $DustRight

onready var raycasters = $Raycasters.get_children()

enum MODE {
	AWAIT_PLAYER = 0,
	AWAIT_INPUT = 1,
	ALWAYS_ATTACK = 2,
}

export(int, "Wait for Player", "Wait for Input", "Always Attack") var attack_mode = MODE.AWAIT_PLAYER

# times are measured in secs
# speeds in pixels/sec
export var attack_delay = 0.2 # delay before attacking
export var ground_wait = 0.5 # after landing, delay before rising
export var always_attack_initial_delay = 0.0 # additional delay prior to first attack, 'always attack' mode only

export var falling_speed = 300.0
export var falling_accel = 1200.0

export var rising_speed = 100.0
export var rising_accel = 100.0

export var detection_range = Vector2(16, 200) setget set_detection_range

enum S { # state enum
	WAITING,
	ALERTED, # detected player, now delay a moment
	FALLING,
	GROUNDED,
	RISING,
}

enum F {
	IDLE = 0
	BLINK = 1
	ANGRY = 2
	LOOKLEFT = 3
	LOOKRIGHT = 4
}

onready var _original_pos = position
onready var _groundref = raycasters[0].cast_to.y #distance from center to bottom

var _state = S.WAITING
var _velocity = 0.0 # float because no horizontal motion, only vertical !!
var _timer = 0.0
var _blinktimer = rand_range(3.0, 5.0)
var _first_attack = true

func set_detection_range(val: Vector2):
	detection_range = val
	
	# without this it sometimes errors upon project start idk why
	if detect_shape == null: return
	
	detect_shape.shape.extents = val
	detect_shape.position.y = val.y
	peek_shape.shape.extents = val + Vector2(32, 0)
	peek_shape.position.y = val.y


func _ready():
	for raycast in raycasters:
		raycast.add_exception(self)


func _on_body_enter(body):
	body.take_damage_shove(2, 1 if body.position.x > position.x else -1)


func _switch_state(s):
	_state = s
	_timer = 0.0
	_velocity = 0.0

# convenience function for remotely attacking
func attack():
	if _state==S.WAITING: _switch_state(S.ALERTED)


func _physics_process(delta):
	if Engine.is_editor_hint(): return
	
	_timer += delta
	
	match _state:
		S.WAITING:
			if peek_zone.get_overlapping_bodies().size() == 0:
				_blinktimer-=delta
				sprite.frame = F.IDLE if _blinktimer > 0.15 else F.BLINK
				
				if _blinktimer < 0: _blinktimer = rand_range(3.0, 5.0)
			else:
				if peek_zone.get_overlapping_bodies()[0].global_position.x < global_position.x:
					sprite.frame = F.LOOKLEFT
				else:
					sprite.frame = F.LOOKRIGHT
				
			if (attack_mode == MODE.AWAIT_PLAYER and detect_area.get_overlapping_bodies().size()
			or attack_mode == MODE.ALWAYS_ATTACK and (!_first_attack or _timer > always_attack_initial_delay) ):
				_first_attack = false
				_switch_state(S.ALERTED)
		# need this state because otherwise player could walk out of the zone before the thwomp attacks
		S.ALERTED:
			sprite.frame = F.IDLE
			if _timer > attack_delay:
				sprite.frame = F.ANGRY
				_switch_state(S.FALLING)
		
		S.FALLING:
			_velocity = min(_velocity+falling_accel*delta, falling_speed)
			
			# position is written to directly to prevent any and all blockages
			position += Vector2.DOWN*_velocity*delta
			
			for raycast in raycasters:
				raycast.force_raycast_update() # removes need for them to be Enabled
			
			var landed = false
			var pushup = 0
			
			for raycast in raycasters:
				if raycast.is_colliding():
					landed = true
					
					if pushup < raycast.get_collision_point().y:
						pushup = raycast.get_collision_point().y
			
			if landed:
				global_position.y = pushup-_groundref
				sprite.frame = F.BLINK
				sfx.play()
				dustleft.emitting = true
				dustright.emitting = true
				_switch_state(S.GROUNDED)
		
		S.GROUNDED:
			if _timer > ground_wait:
				_switch_state(S.RISING)
		
		S.RISING:
			var speedlimit = lerp(4.0, rising_speed, min(1.0, (position.y-_original_pos.y) / 24 ) )
			
			_velocity = min(_velocity+rising_accel*delta, speedlimit)
			
			position += Vector2.UP*_velocity*delta
			if position.y <= _original_pos.y:
				position.y = _original_pos.y
				_switch_state(S.WAITING)
