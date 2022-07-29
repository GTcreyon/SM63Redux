extends StaticBody2D

const coin = preload("res://classes/pickup/coin/yellow/coin_yellow.tscn")
const particle = preload("./box_particle.tscn")
const residual = preload("res://classes/misc/residual_sfx/residual_sfx.tscn")
const boom0 = preload("./boom.wav")
const boom1 = preload("./box_break.wav")

onready var pound_area = $PoundArea
onready var spin_area = $SpinArea

var rng = RandomNumberGenerator.new()
var collect_id

export var coin_count = 5

func _ready():
	collect_id = Singleton.get_collect_id()
	rng.seed = hash(position.x + position.y * PI)
	$Sprite.frame = randi() % 3


func _process(_delta):
	for body in pound_area.get_overlapping_bodies():
		if body.state == body.S.POUND && body.pound_state != body.Pound.SPIN:
			destroy()
	for body in spin_area.get_overlapping_bodies():
		if body.is_spinning(): 
			destroy()


func _on_PoundArea_body_entered(body):
	if body.state == body.S.POUND && body.pound_state != body.Pound.SPIN:
		destroy()


func _on_SpinArea_body_entered(body):
	if body.is_spinning():
		destroy()


func destroy():
	for _i in range(5):
		var inst = particle.instance()
		inst.position = position + Vector2((rng.randf() - 0.5) * 27, (rng.randf() - 0.5) * 27)
		inst.vel = Vector2((rng.randf() - 0.5) * 5, rng.randf() * -2.5)
		inst.get_node("AnimatedSprite").frame = rng.randi() % 7
		get_parent().call_deferred("add_child", inst)
	if Singleton.request_coin(collect_id):
		for _i in range(coin_count):
			var inst = coin.instance()
			inst.position = position# + Vector2((rng.randf() - 0.5) * 27, (rng.randf() - 0.5) * 27)
			inst.vel = Vector2((rng.randf() - 0.5) * 5.0, rng.randf() * -2.5)
			inst.dropped = true
			get_parent().call_deferred("add_child", inst)
	var inst = residual.instance()
	if rng.randi() % 2 < 1:
		inst.sound = boom0
	else:
		inst.sound = boom1
	get_parent().call_deferred("add_child", inst)
	queue_free()
