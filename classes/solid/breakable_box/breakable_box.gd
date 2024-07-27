extends StaticBody2D

const COIN_PREFAB = preload("res://classes/pickup/coin/yellow/coin_yellow.tscn")
const PARTICLE_PREFAB = preload("./box_particle.tscn")
const BOOM_A = preload("./boom.wav")
const BOOM_B = preload("./box_break.wav")

var rng = RandomNumberGenerator.new()
var _pickup_ids = []

@export var coin_count = 5


func _ready():
	_pickup_ids = FlagServer.claim_flag_id_array(coin_count)
	rng.seed = hash(position.x + position.y * PI)
	$Sprite.frame = randi() % 3


func take_hit(type: Hitbox.Type, _handler) -> void:
	destroy()


func destroy():
	for _i in range(5):
		var inst = PARTICLE_PREFAB.instantiate()
		inst.position = position + Vector2((rng.randf() - 0.5) * 27, (rng.randf() - 0.5) * 27)
		inst.vel = Vector2((rng.randf() - 0.5) * 5, rng.randf() * -2.5)
		inst.get_node("AnimatedSprite2D").frame = rng.randi() % 7
		get_parent().call_deferred("add_child", inst)
	for _i in range(coin_count):
		var id = _pickup_ids[_i]
		if !FlagServer.get_flag_state(id):
			var inst = COIN_PREFAB.instantiate()
			inst.position = position# + Vector2((rng.randf() - 0.5) * 27, (rng.randf() - 0.5) * 27)
			inst.vel = Vector2((rng.randf() - 0.5) * 5.0, rng.randf() * -2.5)
			inst.dropped = true
			inst.get_pickup_node().assign_pickup_id(id)
			get_parent().call_deferred("add_child", inst)
	
	var sound
	if rng.randi() % 2 < 1:
		sound = BOOM_A
	else:
		sound = BOOM_B
	get_parent().add_child(ResidualSFX.new(sound, position))
	queue_free()
