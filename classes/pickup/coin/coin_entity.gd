class_name CoinEntity
extends Entity

var dropped = false
var active_timer = 30

func _physics_step():
	if dropped:
		active_timer = max(active_timer - 1, 0)
	
	if dropped:
		vel.y += 0.2
		if vel.y > 0:
			if _water_bodies > 0:
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


# Add some velocity to make spawned coins jump in different directions.
func pop_velocity():
	vel.x = (Singleton.rng.randf() * 4 - 2) * 0.53
	vel.y = -7 * 0.53
