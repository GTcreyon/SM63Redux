extends KinematicBody2D

onready var singleton = $"/root/Singleton"
onready var player = $"/root/Main/Player"
onready var sprite = $AnimatedSprite
var dropped = false
var vel : Vector2 = Vector2.INF
var picked = false
var active_timer = 30
var yellow = 0
var red = 0
var water_bodies = 0
var collect_id

func _process(_delta):
	if !picked:
		if dropped:
			active_timer = max(active_timer - 1, 0)
			if active_timer == 0:
				$PickupArea.monitoring = true
		else:
			$PickupArea.monitoring = true


func _ready():
	var room = get_tree().get_current_scene().get_filename()
	collect_id = singleton.get_collect_id()
	if singleton.collected_dict[room].size() > collect_id && singleton.collected_dict[room][collect_id]:
		queue_free()
	else:
		singleton.collected_dict[room].append(false)
		if vel == Vector2.INF:
			vel.x = (singleton.rng.randf() * 4 - 2) * 0.53
			vel.y = -7 * 0.53
		sprite.playing = true


func _physics_process(_delta):
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


func _on_WaterCheck_area_entered(_body):
	water_bodies += 1


func _on_WaterCheck_area_exited(_body):
	water_bodies -= 1


func _on_PickupArea_body_entered(_body):
	singleton.coin_total += yellow
	if singleton.hp < 8:
		player.internal_coin_counter += yellow
	singleton.red_coin_total += red
	singleton.collected_dict[get_tree().get_current_scene().get_filename()][collect_id] = true
	singleton.collect_count += 1
	picked = true
	singleton.get_node("CoinSFX").play()
	$PickupArea.queue_free() #clears up the acting segments of the coin so only the SFX is left
	sprite.queue_free()


func _on_SFX_finished():
	queue_free()
