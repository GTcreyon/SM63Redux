extends Area2D

const coin = preload("res://actors/items/coin/coin_yellow.tscn")
onready var main = $"/root/Main"
onready var player = $"/root/Main/Player"
onready var sprite = $"../Sprite"
onready var lm_counter = player.life_meter_counter
onready var lm_gui = $"/root/Main/Player/Camera2D/GUI/LifeMeterCounter"
onready var enemy_layer = $"/root/Main/Enemies"

var full_jump = false
var dead = false
var id = null

#kind of screwed setup, but basically body's global position
#is compared to object's global position so the collision
#will be triggered if body's is less or greater
#depending on coordinates


func _on_Area2D_body_entered_hurt(body):
	if body == player:
		if sprite.animation != "squish":
			if body.hitbox.global_position.y + body.hitbox.shape.extents.y - body.vel.y < global_position.y && body.vel.y > 0:# && (body.global_position.x < global_position.x || body.global_position.x > global_position.x):
				sprite.animation = "squish"
				get_parent().velocity.y = 0
				sprite.frame = 0
				sprite.playing = true
				player.state = player.s.ejump
			elif body.global_position.x < global_position.x:# && body.global_position.y > global_position.y:
				lm_counter -= 1
				lm_gui.text = str(lm_counter)
				
				player.vel.x += -4
				player.vel.y += -8
			elif body.global_position.x > global_position.x:# && body.global_position.y > global_position.y:
				lm_counter -= 1
				lm_gui.text = str(lm_counter)
				
				player.vel.x += 4
				player.vel.y += -8


func _physics_process(_delta):
	if sprite.animation == "squish":
		if dead:
			var spawn = coin.instance()
			spawn.position = get_parent().position
			spawn.dropped = true
			main.add_child(spawn)
			get_parent().queue_free()
		else:
			if player.position.y + 16 > global_position.y - 10:
				player.vel.y = 0
				player.position.y += 0.5
			if Input.is_action_just_pressed("jump"):
				full_jump = true
			
		if sprite.frame == 3:
			if Input.is_action_pressed("jump"):
				if full_jump:
					player.vel.y = -6.5
				else:
					player.vel.y = -6
			else:
				player.vel.y = -5
			#player.position.y -= 4
			player.state = player.s.walk
			dead = true #apparently queue_free() doesn't cancel the current cycle
			
	#code to push enemies apart - maybe come back to later?
#	for area in get_overlapping_areas():
#		if area != player:
#			if global_position.x > area.global_position.x || (global_position.x == area.global_position.x && id > area.id):
#				get_parent().velocity.x += 7.5
#			else:
#				get_parent().velocity.x -= 7.5
