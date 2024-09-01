extends AnimatedSprite2D

const HIT_SPEED: int = 5

@onready var hitbox = $Hitbox
@onready var hurtbox_stomp = $HurtboxStomp
@onready var hurtbox_other = $HurtboxOther

@export var koopa_scene: PackedScene
@export var shell_scene: PackedScene
@export var disabled = false
@export var mirror = false
@export var color := Koopa.ShellColor.GREEN


func set_color(new_color):
	for i in range(3):
		material.set_shader_parameter("color" + str(i), Koopa.COLOR_PRESETS[new_color][i])


func _ready():
	set_disabled(disabled)
	# Ensure that the material is unique so we can set its parameters.
	# "Local to scene" causes issues with source control, because UIDs are refreshed on loading the scene.
	# This method refreshes them at runtime instead of in the editor.
	material = material.duplicate()

	set_color(color)

	flip_h = mirror
	frame = hash(position.x + position.y * PI) % 6
	if not disabled:
		play()


func take_hit(hit: Hit) -> bool:
	var type = hit.type
	var handler = hit.source
	if disabled:
		return false

	match type:
		Hit.Type.STOMP:
			var koopa = koopa_scene.instantiate()
			get_parent().add_child.call_deferred(koopa)
			#koopa.position = Vector2(position.x, body.position.y + 33)
			koopa.color = color
			koopa.position = position
			koopa.hit_cooldown()
			koopa.mirror = flip_h
			handler.set_vel_component(Vector2.UP, 5)
			defeat()
			return true
		Hit.Type.STRIKE:
			spawn_shell(handler)
			return true
		Hit.Type.POUND:
			var shell = spawn_shell(handler)
			shell.destroy(handler)
			return true
		_:
			return false


func spawn_shell(handler: HitHandler) -> Node2D:
	hitbox.stop_hit()
	defeat()
	var shell = shell_scene.instantiate()
	get_parent().call_deferred("add_child", shell)
	shell.position = position + Vector2(0, 7.5)
	shell.color = color
	if handler.get_pos().x < position.x:
		shell.vel.x = HIT_SPEED
	else:
		shell.vel.x = -HIT_SPEED
	return shell


# Called when the parakoopa loses its wings
func defeat():
	ResidualSFX.new_from_existing($Kick, get_parent())
	queue_free()


func set_disabled(val):
	disabled = val
	hurtbox_stomp.monitorable = !val
	hurtbox_other.monitorable = !val
	if disabled:
		stop()
	else:
		play()
