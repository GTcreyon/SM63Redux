extends Control

@onready var selector_story = $SelectorStory
@onready var selector_settings = $SelectorSettings
@onready var selector_extra = $SelectorExtras
@onready var selector_ld = $SelectorLevelDesigner

@onready var story = $Story
@onready var settings = $Settings
@onready var extra = $Extras
@onready var ld = $LevelDesigner

@onready var icon = $Icon
@onready var border = $Border
@onready var description_box = $Border/DescriptionBox

@onready var options_control = $OptionsControl
@onready var options_menu = $OptionsControl/OptionsMenu
@onready var back_button = $OptionsControl/BackButton

@onready var preview_orb = $PreviewOrb

# Only based on window size.
var visible_positions: Array#[Vector2]
var center_pos_idx: int

# Changes when the menu scrolls.
var cycle_progress: float = 0  # Between 0 and 1
var cycle_direction: int = 0  # 0 when not scrolling, 1 or -1 when scrolling.
var cycle_step: int = 0  # Current menu position, increases when scrolling left, updated at scroll *end*.
var num_items: int  # Modulo for cycle_step.

var show_options = false


func _cycle_increment(increment_direction: int) -> void:
	cycle_step += increment_direction
	cycle_step = posmod(cycle_step, num_items)


func _item_position(idx_frac: float, offset: Vector2) -> Vector2:
	idx_frac = clamp(idx_frac, 0, visible_positions.size() - 1)
	
	var idx = int(idx_frac)
	if idx + 1 >= visible_positions.size():
		return visible_positions[-1]
	
	var a = visible_positions[idx]
	var b = visible_positions[idx + 1]
	var interp = lerp(a, b, idx_frac - idx)
	interp = interp.round()
	
	assert(offset.round() == offset)
	
	interp += offset
	assert(interp.round() == interp)
	return interp


func _process(delta: float) -> void:
	var dmod = 60 * delta
	var scale = Singleton.get_screen_scale()
	_manage_sizes(scale)
	if visible:
		options_control.visible = show_options
		options_menu.visible = show_options
		if show_options:
			for node in get_tree().get_nodes_in_group("menu_hide"):
				node.modulate.a = max(node.modulate.a - 0.125 * dmod, 0)
			options_menu.modulate.a = min(options_menu.modulate.a + 0.125 * dmod, 1)
			if Input.is_action_just_pressed("ui_cancel"):
				show_options = false
				Singleton.get_node("SFX/Back").play()
		else:
			for node in get_tree().get_nodes_in_group("menu_hide"):
				node.modulate.a = min(node.modulate.a + 0.125 * dmod, 1)
			options_menu.modulate.a = max(options_menu.modulate.a - 0.125 * dmod, 0)
			
			
			visible_positions = [
				Vector2(-0.5 * get_window().size.x, get_window().size.y),
				Vector2(4 * scale, (188.0 / Singleton.DEFAULT_SIZE.y) * get_window().size.y),
				Vector2(0.5 * get_window().size.x, (124.0 / Singleton.DEFAULT_SIZE.y) * get_window().size.y),
				Vector2(get_window().size.x - 4 * scale, (188.0 / Singleton.DEFAULT_SIZE.y) * get_window().size.y),
				Vector2(1.5 * get_window().size.x, get_window().size.y),
				]
			center_pos_idx = 2
			
			var items = [[story, selector_story], [settings, selector_settings], [extra, selector_extra], [ld, selector_ld]]
			# Be sure to initialize num_items before _cycle_through() -> _clamp_cycle_step() reads it.
			num_items = items.size()
			
			if Input.is_action_just_pressed("left"):
				_cycle_through(-1)
			
			if Input.is_action_just_pressed("right"):
				_cycle_through(1)
			
			var item_progress = sin(cycle_progress * PI/2)
			
			# Items move ahead of arrows.
			var item_scroll: float = center_pos_idx + cycle_step + (cycle_direction * item_progress)
			
			# Arrows move linearly.
			var arrow_scroll: float = center_pos_idx + cycle_step + (cycle_direction * cycle_progress)
			
			# Has integer coordinates because scale is an integer.
			# Don't need to round before passing into _item_position.
			var arrow_offset = Vector2.DOWN * 45 * scale
			
			for idx in num_items:
				var item_arrow = items[idx]
				var item = item_arrow[0]
				var arrow = item_arrow[1]
				
				item.position = _item_position(fposmod(item_scroll + idx, num_items), Vector2.ZERO) / scale
				arrow.position = _item_position(fposmod(arrow_scroll + idx, num_items), arrow_offset) / scale
			
			if cycle_direction != 0:
				cycle_progress += 1 / 12.0 * dmod
				if abs(cycle_progress) >= 1:
					_cycle_increment(cycle_direction)
					cycle_progress = 0
					cycle_direction = 0
			
			var arr = [story, ld, extra, settings]
			for node in arr:
				node.get_node("Frame/CrystalL").frame = 0
				node.get_node("Frame/CrystalR").frame = 0
			arr[cycle_step % 4].get_node("Frame/CrystalL").frame = 1
			arr[cycle_step % 4].get_node("Frame/CrystalR").frame = 1
			
			var i = 0
			for desc in description_box.get_children():
				desc.visible = i == posmod(cycle_step + cycle_direction, 4)
				i += 1
			
			if (
				(
					Input.is_action_just_pressed("ui_accept")
					or Input.is_action_just_pressed("interact")
				)
				and modulate.a > 0
			):
				_press_button(get_selected())
			
			if Input.is_action_just_pressed("ui_cancel"):
				visible = false
				Singleton.get_node("SFX/Back").play()
			
			modulate.a = min(modulate.a + 0.125 * dmod, 1)
	else:
		modulate.a = 0


func get_selected() -> int:
	return posmod(cycle_step + cycle_direction, 4)


func _press_button(button: int) -> void:
	if !get_parent().dampen:
		match button:
			0:
				_menu_to_scene("res://scenes/levels/tutorial_1/tutorial_1_1.tscn")
#			1:
#				_menu_to_scene("res://scenes/menus/level_designer/level_designer.tscn")
			3:
				Singleton.get_node("SFX/Confirm").play()
				show_options = true


func _menu_to_scene(scene: String) -> void:
	get_parent().dampen = true
	Singleton.get_node("WindowWarp").warp(Vector2(110, 153), scene)
	Singleton.get_node("SFX/Start").play()


func _cycle_through(direction: int) -> void:
	Singleton.get_node("SFX/Next").play()
	
	# Pressing the left arrow key (direction = -1) scrolls the menu rightward
	# (cycle_direction = 1) and queues an increase to cycle_step modulo num_items.
	#
	# Scrolling right (increasing cycle_step) centers an item previously on the left.
	#
	# In the list of *drawn* menu items (_process#items), later indexes are drawn to the right,
	# so scrolling right (centering a leftwards item) centers a lower-numbered item
	# modulo num_items.
	#
	# In the list of *selectable* menu items (_process#arr), later indexes are drawn to the left,
	# so scrolling right (centering a leftwards item) marks a higher-numbered item as selected by Z.
	# The code uses (cycle_step + cycle_direction) directly as an index.
	#
	# touch_cycle() compares (cycle_step) to larger indexes for leftwards buttons,
	# matching _process#arr.
	
	direction = -direction
	
	# If currently scrolling through menu, finish previous scroll operation.
	if cycle_direction == direction:
		cycle_progress = 0
	elif cycle_direction == -direction:
		cycle_progress = 2 * asin(1 - sin(cycle_progress*(PI/2)))/PI
	
	_cycle_increment(cycle_direction)
	cycle_direction = direction
	preview_orb.transition(get_selected())


func _manage_sizes(scale) -> void:
	scale = Vector2.ONE * scale
	size = get_window().size / scale


func _touch_cycle(step) -> void:
	if !show_options:
		if step == posmod(cycle_step, 4):
			_press_button(step)
		else:
			if posmod(cycle_step + 1, 4) == step:
				_cycle_through(-1)
			else:
				_cycle_through(1)


func _on_LDButton_pressed() -> void:
	_touch_cycle(1)


func _on_ExtrasButton_pressed() -> void:
	_touch_cycle(2)


func _on_SettingsButton_pressed() -> void:
	_touch_cycle(3)


func _on_StoryButton_pressed() -> void:
	_touch_cycle(0)


func _on_BackButton_pressed() -> void:
	Singleton.get_node("SFX/Back").play()
	Singleton.save_input_map_current()
	show_options = false
