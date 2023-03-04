class_name Pickup
extends Area2D

# If true, free the parent node as well when collected.
# Useful for pickup children of physics objects.
export var parent_is_root: bool = false

# Enables pickup ID behavior, so pickups can only be collected once per level.
export var persistent_collect = true
export var disabled: bool = false setget set_disabled
export var _sprite_path: NodePath = "Sprite"
export var _sfx_path: NodePath = "GrabSFX"

var _pickup_id: int = -1

onready var sprite = get_node_or_null(_sprite_path)
onready var sfx = get_node_or_null(_sfx_path)


func _ready():
	_ready_override()


func _ready_override() -> void:
	if sprite != null and sprite.get("playing") != null:
		sprite.playing = !disabled
	if persistent_collect && _pickup_id == -1:
		_pickup_id_setup()
	_connect_signals()


# Allow a pickup ID to be manually assigned.
# Usually inherited from a spawner.
func assign_pickup_id(id) -> void:
	persistent_collect = true
	_pickup_id = id


func pickup(body) -> void:
	_award_pickup(body)
	_pickup_sound()
	_pickup_effect()
	_kill_pickup()
	if persistent_collect:
		FlagServer.set_flag_state(_pickup_id, true)


func _connect_signals() -> void:
	# warning-ignore:return_value_discarded
	connect("body_entered", self, "pickup")


func set_disabled(val):
	disabled = val
	monitoring = !val
	sprite = get_node_or_null(_sprite_path)
	if sprite != null:
		sprite.playing = !val


func _pickup_id_setup() -> void:
	_pickup_id = FlagServer.claim_flag_id()
	if FlagServer.get_flag_state(_pickup_id):
		FlagServer.set_flag_state(_pickup_id, true)
		if parent_is_root:
			get_parent().queue_free()
		else:
			queue_free()


func _pickup_sound():
	if sfx != null:
		# Find an object we know will survive this object's destruction.
		var safe_sfx_root = get_parent()
		if parent_is_root:
			safe_sfx_root = safe_sfx_root.get_parent()
		# Anchor the sound source to that, then play it.
		ResidualSFX.new_from_existing(sfx, safe_sfx_root)


func _kill_pickup() -> void:
	if parent_is_root:
		get_parent().queue_free()
	else:
		queue_free()


func _pickup_effect() -> void:
	pass


func _award_pickup(_body) -> void:
	pass
