extends Sprite2D

const WATER_FILL_HEIGHT = 79
const POWER_GAUGE_HEIGHT = 83
## The total height of the FLUDD icon's bobbing animation.
const Y_BOB_SCALE = 2

var power_prev = 100
var water_prev = 100
var icon_bob = 0


@onready var bottom: Sprite2D = $Bottom
@onready var filler: Sprite2D = $Filler
@onready var surface: Sprite2D = $Surface
@onready var bubble_mask: NinePatchRect = $BubbleMask
@onready var bubbles_big: GPUParticles2D = $BubbleMask/BubblesBig
@onready var bubbles_medium: GPUParticles2D = $BubbleMask/BubblesMedium
@onready var bubbles_small: GPUParticles2D = $BubbleMask/BubblesSmall
@onready var label: Label = $WaterMeterLabel
@onready var max_sprite: Sprite2D = $Max
@onready var power_filler: Sprite2D = $PowerFiller
@onready var power_filler_cover: Sprite2D = $PowerFiller/Cover
@onready var power_mask: Light2D = $PowerMask
@onready var cover: Sprite2D = $Cover
@onready var icon: AnimatedSprite2D = $Icon

@onready var player: PlayerCharacter = $"/root/Main/Player"
@onready var hud_root: Control = $"/root/Main/Player/Camera/HUD/HUDControl"


func _ready():
	refresh()


func _process(delta):
	var dmod = 60 * delta
	refresh()
	
	# Update icon's bob-up-down animation.
	if player.fludd_strain:
		# FLUDD is spraying. Bob fast.
		icon_bob = fmod(icon_bob + 0.5 * dmod, 120)
	else:
		# Bob slowly. 
		icon_bob = fmod(icon_bob + 0.1 * dmod, 120)
	icon.offset.y = sin(icon_bob) * Y_BOB_SCALE
	
	# Update water fill height.
	if player.water == INF:
		# Infinite water should look like full tank, not infinite height.
		filler.scale.y = WATER_FILL_HEIGHT
	else:
		# Fill tank to match player's currently held water.
		filler.scale.y = player.water * WATER_FILL_HEIGHT / 100
	# Mask bubbles to only show in the water fill.
	bubble_mask.offset_top = WATER_FILL_HEIGHT - filler.scale.y
	
	# Update visibility and placement of the other water elements.
	if player.water > 0:
		# Some water is in the tank. Show all the parts of that.
		surface.visible = true
		bottom.visible = true
		bubbles_big.visible = true
		bubbles_medium.visible = true
		bubbles_small.visible = true
		# Place water surface at the top of the water fill.
		if player.water == INF:
			surface.position.y = 0
		else:
			surface.position.y = (100 - player.water) * WATER_FILL_HEIGHT / 100
		
		# Size bubbles to match the canvas (as GPU particles, scale doesn't
		# seem to affect them).
		# Begin by fetching the particle process material. All the systems
		# share this, so (for now) we only need to get this once.
		var ptcl_mat = bubbles_big.process_material as ParticleProcessMaterial
		if ptcl_mat != null:
			# The HUD root control scales all children. Get that scale factor.
			var bubble_scale = hud_root.scale.x # Scale X and Y should always be equal.
			# Apply it to the particles.
			ptcl_mat.scale_min = bubble_scale
			ptcl_mat.scale_max = bubble_scale
	else:
		# Tank is empty. Show nothing.
		surface.visible = false
		bottom.visible = false
		bubbles_big.visible = false
		bubbles_medium.visible = false
		bubbles_small.visible = false
	
	# Fill power gauge to match player's remaining spray power.
	power_filler.scale.y = player.fludd_power * POWER_GAUGE_HEIGHT / 100
	# Scroll the power mask.
	power_mask.offset.y -= 1 * dmod
	# Wrap it around if it gets too low.
	if power_mask.offset.y < -POWER_GAUGE_HEIGHT:
		power_mask.offset.y += POWER_GAUGE_HEIGHT
	# Show the mask more brightly if FLUDD is in use.
	power_mask.energy = 1.4 if player.fludd_strain else 1.0
	
	# Flash the gauge white when power refills to full.
	if player.fludd_power == 100 and power_prev != 100:
		power_filler_cover.modulate.a = 1
	# If said flash is on, fade it out naturally.
	elif power_filler_cover.modulate.a > 0:
		power_filler_cover.modulate.a -= 0.1 * dmod
	# Same deal when water refills by any amount.
	if player.water > water_prev:
		cover.modulate.a = 1
	elif cover.modulate.a > 0:
		cover.modulate.a -= 0.1 * dmod
	# Save current values for next frame's checks.
	power_prev = player.fludd_power
	water_prev = player.water


func refresh():
	visible = true
	
	match player.current_nozzle:
		Singleton.Nozzles.HOVER:
			icon.animation = "hover"
		Singleton.Nozzles.ROCKET:
			icon.animation = "rocket"
		Singleton.Nozzles.TURBO:
			icon.animation = "turbo"
		_:
			visible = false
	
	if player.water == 100:
		# Water is at max. Show "MAX" text instead of number 100.
		max_sprite.visible = true
		label.visible = false
	else:
		# Show the player's current water amount.
		max_sprite.visible = false
		label.visible = true
		if player.water == INF:
			label.text = "INF"
		else:
			# keeps the display in range 1-99
			label.text = str(floor((player.water + 1) / 100 * 99))
