class_name Bobomb
extends EntityEnemyWalk
# Bobombs wander until a player enters their alert area.
# This will begin their fuse, and they will pursue the player at a higher speed.
# They will explode, dropping a coin once their fuse runs out.
# When their fuse is lit, they do not lose focus on the player.
# They can be struck to send them flying a short distance before exploding.

const EXPLOSION = preload("res://classes/entity/enemy/bobomb/explosion.tscn")

var fuse_time = 240

onready var base = $Sprites/Base
onready var fuse = $Sprites/Fuse
onready var key = $Sprites/Key
onready var sfx_fuse = $SFXFuse


func _ready_override():
	._ready_override()
	fuse = _preempt_node_ready(fuse, "Sprites/Fuse")
	key = _preempt_node_ready(key, "Sprites/Key")
	fuse.playing = !disabled
	key.playing = !disabled


func _physics_step() -> void:
	if !struck:
		_update_sprites()
	
	if fuse.animation == "lit":
		fuse_time -= 1
		
	if fuse_time <= 0:
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


func _target_alert(body) -> void:
	fuse.animation = "lit"


func set_disabled(val) -> void:
	.set_disabled(val)
	fuse.playing = !disabled
	key.playing = !disabled


func _hurt_struck(body) -> void:
	._hurt_struck(body)
	base.animation = "struck"
	fuse.visible = false
	key.visible = false


func _struck_land():
	explode()


func explode():
	var spawn = EXPLOSION.instance()
	spawn.position = position
	get_parent().add_child(spawn)
	enemy_die()
