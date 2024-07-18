class_name Hitbox
extends Area2D
## An [Area2D] that inflicts hits onto [Hurtbox]es.

enum Type {
	## Fallback type for damage of non-specific origin, e.g. /dmg.
	GENERIC = 0b1,
	## Light crush, e.g. jumping on a Goomba.
	CRUSH = 0b10,
	## Heavier crush, e.g. ground-pounding a Goomba or being crushed by a Thwomp.
	CRUSH_HEAVY = 0b100,
	## Impact, e.g. spin attack or Bullet Bill.
	STRIKE = 0b1000,
	## Heat damage, e.g. fire or lava.
	BURN = 0b10000,
	## Explosive damage, e.g. Bob-omb.
	EXPLOSION = 0b100000,
	## Passive contact damage, e.g. walking into a shell.
	NUDGE = 0b1000000,
}

## The damage type the hitbox will inflict.
@export var _hit_type: Type

## The [HitHandler] for this hitbox.
@export var _handler: HitHandler = get_node_or_null(^"../HitHandler")

## If [code]true[/code], the attack does not need to be restarted in order to apply a second hit.
@export var _persistent := true

## If [code]true[/code], the attack will be active immediately, rather than having to be started.
@export var _start_active := true

## Array of hurtboxes that have already been hit during this attack.
## Unused if the attack is persistent.
var _already_hit: Array[Hurtbox] = []


func _ready():
	connect("area_entered", _found_hurtbox)
	if _start_active:
		start_hit()
	else:
		stop_hit()


## Begin a hit, enabling [Hurtbox] detection.
func start_hit() -> void:
	monitoring = true


## End a hit, disabling [Hurtbox] detection.
func stop_hit() -> void:
	monitoring = false
	_already_hit.clear()


## Called when a [Hurtbox] is detected.
func _found_hurtbox(area: Area2D) -> void:
	# Only detect hurtboxes
	if not area is Hurtbox:
		return

	if not _persistent:
		if area in _already_hit:
			return
		_already_hit.append(area)

	if _handler == null:
		push_warning("No HitHandler assigned. Using a dummy. This might cause unexpected behavior.")
		_handler = HitHandler.new()
		get_parent().add_child(_handler)

	var target = area.take_hit(_hit_type, _handler)
