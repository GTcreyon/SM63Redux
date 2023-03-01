class_name Bobomb
extends EntityEnemyWalk
# Bobombs wander until a player enters their alert area.
# This will begin their fuse, and they will pursue the player at a higher speed.
# They will explode, dropping a coin once their fuse runs out.
# When their fuse is lit, they do not lose focus on the player.
# They can be struck to send them flying a short distance before exploding.

# When two bombs play the buildup sound at once, the sound gets confusing.
# Would be nice to have it choose from two or three different pitches so
# the player can differentiate which sound belongs to which bomb, but
# picking at random is likely to give two bombs the same pitch more often than
# not, and making a global "in-use bomb sound" pool would require modifying
# the singleton--which sounds like a pretty far-reaching change for a little
# problem like this!
# So for now, multiple buildup sounds is off the table.
#const BUILDUP_SOUNDS = [
#	preload("res://classes/entity/enemy/bobomb/explosion_buildup_1.wav"),
#	preload("res://classes/entity/enemy/bobomb/explosion_buildup_2.wav"),
#]
const EXPLOSION: PackedScene = preload("res://classes/entity/enemy/bobomb/explosion.tscn")
const FUSE_DURATION: int = 240
const BUILDUP_SOUND_START: int = 198
const EASE_FACTOR: float = 1.5
const FLASH_COUNT: int = 18

var _is_lit: bool = false
var _fuse_time: int = FUSE_DURATION

onready var base = $Sprites/Base
onready var fuse = $Sprites/Fuse
onready var key = $Sprites/Key
onready var sfx_fuse = $SFXFuse
onready var sfx_build = $SFXBuildup
onready var sfx_knock = $SFXKnock

func _ready_override():
	._ready_override()
	fuse = _preempt_node_ready(fuse, "Sprites/Fuse")
	key = _preempt_node_ready(key, "Sprites/Key")
	fuse.playing = !disabled
	key.playing = !disabled


func _physics_step() -> void:
	if !struck:
		_update_sprites()
	
	if _is_lit:
		fuse.animation = "lit"
		var fuse_frame: float = max(0, BUILDUP_SOUND_START - _fuse_time)
		var fuse_progress: float = fuse_frame / BUILDUP_SOUND_START
		var ease_position: float = pow(fuse_progress, EASE_FACTOR)
		var red_amount = (1 - cos(ease_position * 2 * PI * FLASH_COUNT)) / 2.0
		base.modulate.g = 1 - red_amount * fuse_progress
		base.modulate.b = 1 - red_amount * fuse_progress
		_fuse_time -= 1
	
	if _fuse_time == BUILDUP_SOUND_START:
		sfx_build.play()
	
	if _fuse_time <= 0:
		explode()
	
	._physics_step()


func _update_sprites() -> void:
	if [1, 2, 5, 6].find(base.frame) == -1: # Offset the fuse and key when the bobomb steps
		fuse.offset.y = 0
		key.offset.y = 0
	else:
		fuse.offset.y = 1
		key.offset.y = 1
	
	if mirror:
		base.flip_h = true
		fuse.flip_h = true
		fuse.offset.x = 4
		key.flip_h = true
		key.offset.x = 22
	else:
		base.flip_h = false
		fuse.flip_h = false
		key.flip_h = false
		key.offset.x = 0
		if target != null:
			fuse.offset.x = 3
		else:
			fuse.offset.x = 0


func _target_alert(_body) -> void:
	_is_lit = true
	sfx_fuse.play()


func set_disabled(val) -> void:
	.set_disabled(val)
	fuse.playing = !disabled
	key.playing = !disabled


func _hurt_struck(body) -> void:
	._hurt_struck(body)
	base.animation = "struck"
	fuse.visible = false
	key.visible = false
	sfx_knock.play()
	# Once the bomb's been hit away, the fuse should get much quieter, as the
	# danger has been deflected.
	# But players can still run into the explosion, so we can't just drop the
	# fuse volume--it still marks danger!
	# Instead, let's switch to a lower max difference and a sharper attenuation
	# curve. The fuse will fade to quiet very quickly as the bob-omb falls
	# away, but stays loud if the player is going to walk into it.
	# If the player hits the bob-omb from a standstill, then starts walking,
	# they won't hit the danger zone, so in this case the fuse should stay
	# quiet.
	# It took a lot of finetuning to get all three of these effects at once!
	sfx_fuse.max_distance = 100
	sfx_fuse.attenuation = 0.75


func _struck_land():
	explode()


func explode():
	var spawn = EXPLOSION.instance()
	spawn.position = position
	get_parent().add_child(spawn)
	enemy_die()
