class_name Pickup
extends Area2D

# If true, free the parent node as well when collected.
# Useful for pickup children of physics objects.
@export var parent_is_root: bool = false

# Enables pickup ID behavior, so pickups can only be collected once per level.
@export var persistent_collect = true
@export var respawn_seconds = 0.0 # (float, 0.0, 30.0, 1.0)
@export var disabled: bool = false: set = set_disabled
@export var _sprite_path: NodePath = "Sprite2D"
@export var _sfx_path: NodePath = "SFXCollect"

var _pickup_id: int = -1
var _respawn_timer: float = -1

@onready var sprite = get_node_or_null(_sprite_path)
@onready var sfx = get_node_or_null(_sfx_path)


func _ready():
	_ready_override()


func _ready_override() -> void:
	if sprite != null and sprite.get("playing") != null:
		sprite.playing = !disabled
	if persistent_collect && _pickup_id == -1:
		_pickup_id_setup()
	_connect_signals()


func _physics_process(_delta):
	if respawn_seconds > 0 and _respawn_timer != -1:
		if _respawn_timer > respawn_seconds:
			# Show and re-enable the object.
			set_disabled(false)
			if sprite != null:
				sprite.visible = true
			# Unset the timer.
			_respawn_timer = -1
		else:
			# Tick the respawn timer.
			_respawn_timer += 1.0 / 60


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
	connect("body_entered", Callable(self, "pickup"))


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
	# Check to make sure the object is killable.
	if respawn_seconds == 0.0:
		# Check to see if sfx should exist, and does exist.
		# sfx will exist if it should, but the second condition is a failsafe in case it doesn't.
		if sfx != null and has_node(_sfx_path):
			# Find an object we know will survive this object's destruction.
			var safe_sfx_root = $"/root/Main"
			# Anchor the sound source to that, then play it.
			ResidualSFX.new_from_existing(sfx, safe_sfx_root)
		# Check to see if object should have an sfx, and if it does have an sfx.
		elif sfx != null and !has_node(_sfx_path):
			printerr("This pickup should have SFXCollect, but it wasn't found. :(")
	else:
		sfx.play()


func _kill_pickup() -> void:
	if respawn_seconds == 0.0:
		# No respawn. Destroy object permanently.
		if parent_is_root:
			get_parent().queue_free()
		else:
			queue_free()
	else:
		# Will respawn soon. Hide and disable in the meantime.
		set_disabled(true)
		if sprite != null:
			sprite.visible = false
		# Start the respawn timer.
		_respawn_timer = 0.0


func _pickup_effect() -> void:
	pass


func _award_pickup(_body) -> void:
	pass
