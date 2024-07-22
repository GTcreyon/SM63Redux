extends HitHandler

@export var motion: Motion

var bouncing: bool = false


func set_vel(value):
	motion.set_vel(value)


func get_vel() -> Vector2:
	return motion.get_vel()


func stomp_bounce():
	bouncing = true
