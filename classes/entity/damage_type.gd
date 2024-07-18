class_name Damage

## Types of damage that can be inflicted.
enum Type {
	ANY, # Universal type.
	GENERIC, # Fallback type for damage of non-specific origin, e.g. /dmg
	CRUSH, # Light crush, e.g. jumping on a Goomba
	CRUSH_HEAVY, # Heavy crush, e.g. ground-pounding a Goomba or being crushed by a Thwomp
	STRIKE, # Impact, e.g. spin attack or Bullet Bill
	BURN, # Heat damage, e.g. fire or lava
	EXPLOSION, # Explosive damage, e.g. Bob-omb
}
