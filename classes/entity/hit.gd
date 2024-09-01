class_name Hit
extends RefCounted
## A data structure that stores a hit type and a source handler.

enum Type {
	## Fallback type for damage of non-specific origin, e.g. /dmg.
	GENERIC = 0b1,
	## Stomp / light crush, e.g. jumping on a Goomba.
	STOMP = 0b10,
	## Pound / heavy crush, e.g. ground-pounding a Goomba or being crushed by a Thwomp.
	POUND = 0b100,
	## Impact, e.g. spin attack or Bullet Bill.
	STRIKE = 0b1000,
	## Heat damage, e.g. fire or lava.
	BURN = 0b10000,
	## Explosive damage, e.g. Bob-omb.
	EXPLOSION = 0b100000,
	## Passive contact damage, e.g. walking into a shell.
	NUDGE = 0b1000000,
}

var type: Type
var handler: HitHandler
