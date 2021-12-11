extends StaticBody2D

const coin = preload("res://actors/items/coin/coin_yellow.tscn")
const particle = preload("res://actors/items/breakable_box/box_particle.tscn")
const residual = preload("res://actors/residual_sfx.tscn")
const boom = preload("res://actors/items/breakable_box/boom.wav")

onready var main = $"/root/Main"
onready var player = $"/root/Main/Player"
onready var pound_area = $PoundArea
onready var spin_area = $SpinArea

var rng = RandomNumberGenerator.new()
var collect_id

func _ready():
	collect_id = Singleton.get_collect_id()
	rng.seed = hash(position.x + position.y * PI)
	$Sprite.frame = randi() % 3


func _process(_delta):
	if pound_area.overlaps_body(player):
		if player.state == player.s.pound_fall || player.state == player.s.pound_land:
			destroy()
	if spin_area.overlaps_body(player):
		if player.is_spinning(): 
			destroy()


func _on_PoundArea_body_entered(_body):
	if player.state == player.s.pound_fall || player.state == player.s.pound_land:
		destroy()


func _on_SpinArea_body_entered(_body):
	if player.is_spinning():
		destroy()


func destroy():
	var room = get_tree().get_current_scene().get_filename()
	for _i in range(5):
		var inst = particle.instance()
		inst.position = position + Vector2((rng.randf() - 0.5) * 27, (rng.randf() - 0.5) * 27)
		inst.vel = Vector2((rng.randf() - 0.5) * 5, rng.randf() * -2.5)
		inst.get_node("AnimatedSprite").frame = rng.randi() % 7
		main.call_deferred("add_child", inst)
	if !Singleton.collected_dict[room][collect_id]:
		Singleton.collected_dict[room][collect_id] = true
		for _i in range(5):
			var inst = coin.instance()
			inst.position = position# + Vector2((rng.randf() - 0.5) * 27, (rng.randf() - 0.5) * 27)
			inst.vel = Vector2((rng.randf() - 0.5) * 5.0, rng.randf() * -2.5)
			inst.dropped = true
			main.call_deferred("add_child", inst)
	var inst = residual.instance()
	inst.sound = boom
	main.call_deferred("add_child", inst)
	queue_free()
