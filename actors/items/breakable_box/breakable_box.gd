extends StaticBody2D

const coin = preload("res://actors/items/coin/coin_yellow.tscn")
const particle = preload("res://actors/items/breakable_box/box_particle.tscn")

onready var main = $"/root/Main"
onready var player = $"/root/Main/Player"
onready var pound_area = $PoundArea
onready var spin_area = $SpinArea

var rng = RandomNumberGenerator.new()

func _ready():
	rng.seed = hash(position.x + position.y * PI)
	$Sprite.frame = randi() % 3


func _process(_delta):
	if pound_area.overlaps_body(player):
		if player.state == player.s.pound_fall:
			queue_free()
	if spin_area.overlaps_body(player):
		if player.is_spinning(): 
			queue_free()


func _on_PoundArea_body_entered(body):
	if player.state == player.s.pound_fall:
		destroy()


func _on_SpinArea_body_entered(body):
	if player.is_spinning():
		destroy()


func destroy():
	for _i in range(5):
		var inst = particle.instance()
		inst.position = position + Vector2((rng.randf() - 0.5) * 27, (rng.randf() - 0.5) * 27)
		inst.vel = Vector2((rng.randf() - 0.5) * 5, rng.randf() * -2.5)
		inst.get_node("AnimatedSprite").frame = rng.randi() % 7
		main.call_deferred("add_child", inst)
	for _i in range(5):
		var inst = coin.instance()
		inst.position = position# + Vector2((rng.randf() - 0.5) * 27, (rng.randf() - 0.5) * 27)
		inst.vel = Vector2((rng.randf() - 0.5) * 5.0, rng.randf() * -2.5)
		inst.dropped = true
		main.call_deferred("add_child", inst)
	queue_free()
