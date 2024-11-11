class_name Hitbox
extends Area2D
## An [Area2D] that inflicts hits onto [Hurtbox]es.

## The damage type the hitbox will inflict.
@export var _hit_type: Hit.Type

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

	var target = area.take_hit(Hit.new(_hit_type, _handler))
