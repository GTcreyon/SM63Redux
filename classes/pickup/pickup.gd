class_name Pickup
extends Area2D

## If true, free the parent node as well when collected.
## Useful for pickup children of physics objects.
@export var parent_is_root: bool = false

## Enables pickup ID behavior, so pickups can only be collected once per level.
@export var persistent_collect = true
## When collected, the pickup will respawn in this many seconds. 0 to disable.
@export_range(0, 30, 1.0, "suffix:seconds") var respawn_seconds: float = 0.0
@export var disabled: bool = false: set = set_disabled
@export_node_path("Sprite2D", "AnimatedSprite2D") var _sprite_path: NodePath = "Sprite2D"
@export_node_path("AudioStreamPlayer", "AudioStreamPlayer2D") var _sfx_path: NodePath = "SFXCollect"
## The pickup will emit this effect when collected.
@export var death_fx: PackedScene

var _pickup_id: int = -1
var _respawn_timer: float = -1

@onready var sprite = get_node_or_null(_sprite_path)
@onready var sfx = get_node_or_null(_sfx_path)


func _ready():
	_ready_override()


func _ready_override() -> void:
	if sprite != null:
		if not disabled and sprite.has_method("play"):
			sprite.play()
		elif sprite.has_method("stop"):
			sprite.stop()
	if persistent_collect && _pickup_id == -1:
		_pickup_id_setup()
	_connect_signals()


func _physics_process(_delta):
	if respawns() and _respawn_timer != -1:
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


## Allow a pickup ID to be manually assigned.
## Usually inherited from a spawner.
func assign_pickup_id(id) -> void:
	persistent_collect = true
	_pickup_id = id


func pickup(body) -> void:
	_award_pickup(body)
	_pickup_sound()
	var effect = _pickup_effect()
	if effect:
		# Find an object we know will survive this object's destruction.
		var safe_root = $"/root/Main"
		
		# Anchor child effects (if they exist) to that, so they can play past
		# the death of this object.
		safe_root.add_child(effect)
		effect.global_position = self.global_position
	_kill_pickup()
	if persistent_collect:
		FlagServer.set_flag_state(_pickup_id, true)


## Returns whether this pickup respawns after [param respawn_seconds] seconds.[br]
## True if and only if [code]respawn_seconds != 0.0[/code].
func respawns() -> bool:
	return respawn_seconds > 0.0


func _connect_signals() -> void:
	# warning-ignore:return_value_discarded
	connect("body_entered", Callable(self, "pickup"))


func set_disabled(val):
	disabled = val
	monitoring = !val
	sprite = get_node_or_null(_sprite_path)
	if sprite != null:
		if not disabled and sprite.has_method("play"):
			sprite.play()
		elif sprite.has_method("stop"):
			sprite.stop()


func _pickup_id_setup() -> void:
	_pickup_id = FlagServer.claim_flag_id()
	if FlagServer.get_flag_state(_pickup_id):
		FlagServer.set_flag_state(_pickup_id, true)
		if parent_is_root:
			get_parent().queue_free()
		else:
			queue_free()


func _pickup_sound():
	# Check whether the object is killable.
	if !respawns():
		# Object is permanently killable.
		
		if sfx:
			# Find an object we know will survive this object's destruction.
			var safe_root = $"/root/Main"
			# Anchor SFX (if they exist) to that, so they can play past
			# the death of this object.
			ResidualSFX.new_from_existing(sfx, safe_root)
	else:
		# Object respawns after a set time. Child effects guaranteed to survive
		# when the object is collected; use them in-place.
		if sfx:
			sfx.play()


func _pickup_effect() -> Node2D:
	return death_fx.instantiate() if death_fx else null


func _kill_pickup() -> void:
	if !respawns():
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


func _award_pickup(_body) -> void:
	pass
