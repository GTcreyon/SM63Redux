class_name Coin
extends KinematicBody2D

const PARTICLE_SCENE = preload("res://classes/pickup/coin/coin_particles.tscn")

export var disabled = false setget set_disabled

onready var sprite = $AnimatedSprite
onready var pickup_area = $PickupArea
var dropped = false
var indexed = true
var vel : Vector2 = Vector2.INF
var picked = false
var active_timer = 30
var yellow = 0
var red = 0
var water_bodies = 0
var collect_id
var particle_texture: StreamTexture


func _ready():
	if !dropped:
		var room = get_tree().get_current_scene().get_filename()
		collect_id = Singleton.get_collect_id()
		if Singleton.collected_dict[room][collect_id]:
			queue_free()
		else:
			Singleton.collected_dict[room].append(false)
	if vel == Vector2.INF:
		vel.x = (Singleton.rng.randf() * 4 - 2) * 0.53
		vel.y = -7 * 0.53
	sprite.playing = !disabled


func _physics_process(_delta):
	if !disabled:
		physics_step()


func _on_WaterCheck_area_entered(_body):
	water_bodies += 1


func _on_WaterCheck_area_exited(_body):
	water_bodies -= 1


func _on_PickupArea_body_entered(_body):
	Singleton.coin_total += yellow
	if Singleton.hp < 8:
		Singleton.internal_coin_counter += yellow
	Singleton.red_coin_total += red
	if !dropped:
		Singleton.collected_dict[get_tree().get_current_scene().get_filename()][collect_id] = true
	Singleton.collect_count += 1
	picked = true
	Singleton.get_node("SFX/Coin").play()
	pickup_area.queue_free() #clears up the acting segments of the coin so only the SFX is left
	var inst = PARTICLE_SCENE.instance()
	inst.texture = particle_texture
	inst.position = position
	get_parent().add_child(inst)
	queue_free()


func physics_step():
	if !picked:
		if dropped:
			active_timer = max(active_timer - 1, 0)
			
	if dropped:
		vel.y += 0.2
		if vel.y > 0:
			if water_bodies > 0:
				vel.y *= 0.88
			else:
				vel.y *= 0.98
		if is_on_floor():
			vel.y = -vel.y / 2
			if round(vel.y) == 0:
				vel.y = 0
		
		if is_on_wall():
			vel.x *= -0.5
		if is_on_floor():
			vel.x *= 0.75
		# warning-ignore:RETURN_VALUE_DISCARDED
		move_and_slide(vel * 60, Vector2.UP)


func set_disabled(value):
	disabled = value
	if sprite == null:
		sprite = $AnimatedSprite
	if pickup_area == null:
		pickup_area = $PickupArea
	$AnimatedSprite.playing = !value
	$PickupArea.monitoring = !value
