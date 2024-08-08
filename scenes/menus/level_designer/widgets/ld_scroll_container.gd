@tool
class_name ScrollContainerDecorated
extends Container
## Scroll container which uses decorated scrollbars.
# Ported from Godot source code 8/7/2024.

signal scroll_started
signal scroll_ended

@export var follow_focus := false
@export_enum("Disabled", "Auto", "Always Show", "Never Show") var horizontal_scroll_mode: int = ScrollContainer.SCROLL_MODE_AUTO: set = set_horizontal_scroll_mode
@export_enum("Disabled", "Auto", "Always Show", "Never Show") var vertical_scroll_mode: int = ScrollContainer.SCROLL_MODE_AUTO: set = set_vertical_scroll_mode
@export var deadzone := 0

@export_group("Scroll", "scroll_")
@export_range(0, 0, 1, "hide_slider", "or_greater", "suffix:px") var scroll_horizontal = 0: set = set_h_scroll, get = get_h_scroll
@export_range(0, 0, 1, "hide_slider", "or_greater", "suffix:px") var scroll_vertical = 0: set = set_v_scroll, get = get_v_scroll
@export_range(-1, 4096, 0.005, "suffix:px") var scroll_horizontal_custom_step = -1: set = set_horizontal_custom_step, get = get_horizontal_custom_step
@export_range(-1, 4096, 0.005, "suffix:px") var scroll_vertical_custom_step = -1: set = set_vertical_custom_step, get = get_vertical_custom_step

var _h_scroll: HScrollBar#Decorated
var _v_scroll: VScrollBarDecorated

var _largest_child_min_size: Vector2 # The largest one among the min sizes of all available child controls.

var drag_speed: Vector2
var drag_accum: Vector2
var drag_from: Vector2
var last_drag_accum: Vector2
var time_since_motion := 0.0
var drag_touching := false
var drag_touching_deaccel := false
var beyond_deadzone := false

var _panel_style: StyleBox

# Normally an internal part of Node; duplicated here because logic relies on it.
# Seems to become true when _ready() is called, but the inner workings of Godot
# are an eldritch enigma whose workings elude the grasp of mere mortals (and
# also poorly commented), so this is a best guess at best.
var _is_ready := false

# Protected
var _updating_scrollbars := false

#include "core/config/project_settings.h"
#include "scene/main/window.h"
#include "scene/theme/theme_db.h"


func _init():
	_is_ready = false
	
	_panel_style = get_theme_stylebox(&"panel", &"ScrollContainer")
	
	_h_scroll = HScrollBar.new()
	_h_scroll.name = "_h_scroll"
	add_child(_h_scroll, false, INTERNAL_MODE_BACK)
	_h_scroll.value_changed.connect(Callable(self, &"_scroll_moved"))

	_v_scroll = VScrollBarDecorated.new()
	_v_scroll.set_name("_v_scroll")
	add_child(_v_scroll, false, INTERNAL_MODE_BACK)
	_v_scroll.value_changed.connect(Callable(self, &"_scroll_moved"))

	deadzone = ProjectSettings.get_setting_with_override("gui/common/default_scroll_deadzone")

	set_clip_contents(true)


func _ready():
	_is_ready = true
	
	var viewport := get_viewport()
	assert(viewport != null)
	viewport.connect("gui_focus_changed", Callable(self, &"_gui_focus_changed"))
	_reposition_children()


func _draw():
	draw_style_box(_panel_style, Rect2(Vector2(), get_size()))


func _notification(p_what: int):
	match p_what:
		NOTIFICATION_ENTER_TREE, NOTIFICATION_THEME_CHANGED, \
		NOTIFICATION_LAYOUT_DIRECTION_CHANGED, \
		NOTIFICATION_TRANSLATION_CHANGED:
			_updating_scrollbars = true
			# Update children only if _ready() has finished;
			# otherwise just update the scrollbars.
			call_deferred(&"_reposition_children" if _is_ready else &"_update_scrollbar_position")
		NOTIFICATION_SORT_CHILDREN:
			_reposition_children()
		NOTIFICATION_INTERNAL_PHYSICS_PROCESS:
			if drag_touching:
				if drag_touching_deaccel:
					var pos := Vector2(_h_scroll.get_value(), _v_scroll.get_value())
					pos += drag_speed * get_physics_process_delta_time()

					var turnoff_h := false
					var turnoff_v := false

					if pos.x < 0:
						pos.x = 0
						turnoff_h = true
					if pos.x > (_h_scroll.get_max() - _h_scroll.get_page()):
						pos.x = _h_scroll.get_max() - _h_scroll.get_page()
						turnoff_h = true

					if pos.y < 0:
						pos.y = 0
						turnoff_v = true
					if pos.y > (_v_scroll.get_max() - _v_scroll.get_page()):
						pos.y = _v_scroll.get_max() - _v_scroll.get_page()
						turnoff_v = true

					if horizontal_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED:
						_h_scroll.scroll_to(pos.x)
					
					if vertical_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED:
						_v_scroll.scroll_to(pos.y)

					var sgn_x := -1 if drag_speed.x < 0 else 1
					var val_x: float = abs(drag_speed.x)
					val_x -= 1000 * get_physics_process_delta_time()

					if val_x < 0:
						turnoff_h = true

					var sgn_y := -1 if drag_speed.y < 0 else 1
					var val_y: float = abs(drag_speed.y)
					val_y -= 1000 * get_physics_process_delta_time()

					if val_y < 0:
						turnoff_v = true

					drag_speed = Vector2(sgn_x * val_x, sgn_y * val_y)

					if turnoff_h and turnoff_v:
						_cancel_drag()
				else:
					if time_since_motion == 0 or time_since_motion > 0.1:
						var diff := drag_accum - last_drag_accum
						last_drag_accum = drag_accum
						drag_speed = diff / get_physics_process_delta_time()
					
					time_since_motion += get_physics_process_delta_time()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	# Check how many Control children this node has, besides the scrollbars.
	var found := 0
	for i in get_child_count():
		var c = _as_sortable_control(get_child(i))
		# Skip children which are not controls.
		if !c:
			continue
		# Skip the scrollbars.
		if c == _h_scroll or c == _v_scroll:
			continue
		found += 1
	# There should be exactly one. Emit a warning if not.
	if found != 1:
		warnings.push_back(tr("ScrollContainer is intended to work with a single child control.\nUse a container as child (VBox, HBox, etc.), or a Control and set the custom minimum size manually."))

	return warnings


func get_h_scroll_bar() -> HScrollBar:#Decorated:
	return _h_scroll


func get_v_scroll_bar() -> VScrollBarDecorated:
	return _v_scroll


func _as_sortable_control(node: Node, sort_visible = false) -> Control:
	var c = node as Control
	if !c or c.top_level:
		return null
	if sort_visible and !c.visible:
		return null
	if !sort_visible and !c.is_visible_in_tree():
		return null
	
	return c


func _get_minimum_size():
	var min_size: Vector2

	# Find min size of largest child, not counting the scrollbars.
	# Calculated in this function, as it needs to traverse all child controls once to calculate
	# and needs to be calculated before being used by update_scrollbars().
	_largest_child_min_size = Vector2()
	for i in get_child_count():
		var c = _as_sortable_control(get_child(i))
		# Skip children which are not controls.
		if !c:
			continue
		# Skip invisible children.
		if !c.visible:
			continue
		# Skip the scrollbars.
		if c == _h_scroll or c == _v_scroll:
			continue

		var child_min_size: Vector2 = c.get_combined_minimum_size()

		_largest_child_min_size = Vector2(
			max(_largest_child_min_size.x, child_min_size.x),
			max(_largest_child_min_size.y, child_min_size.y)
		)
	
	# If scrollbars on one axis are disabled, size up to fit the largest child
	# (in case the largest child control is bigger).
	if horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED:
		min_size.x = max(min_size.x, _largest_child_min_size.x)
	if vertical_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED:
		min_size.y = max(min_size.y, _largest_child_min_size.y)
	
	# Show enabled scrollbars if one of the following is true:
	# - the scrollbar is set to always show
	# - the largest child outsizes the container itself.
	var h_scroll_show := horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_SHOW_ALWAYS or (
		horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO and 
		_largest_child_min_size.x > min_size.x)
	var v_scroll_show := vertical_scroll_mode == ScrollContainer.SCROLL_MODE_SHOW_ALWAYS or (
		vertical_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO and 
		_largest_child_min_size.y > min_size.y)

	# Size this control up to fit the scrollbars.
	# TODO: Undesired for SM63R-styled scroll container!
	if h_scroll_show and _h_scroll.get_parent() == self:
		min_size.y += _h_scroll.get_minimum_size().y
	if v_scroll_show and _v_scroll.get_parent() == self:
		min_size.x += _v_scroll.get_minimum_size().x
	
	# Account for padding given by the panel style.
	min_size += _panel_style.get_minimum_size()
	return min_size


func _cancel_drag():
	set_physics_process_internal(false)
	drag_touching_deaccel = false
	drag_touching = false
	drag_speed = Vector2()
	drag_accum = Vector2()
	last_drag_accum = Vector2()
	drag_from = Vector2()

	if beyond_deadzone:
		scroll_ended.emit()
		propagate_notification(NOTIFICATION_SCROLL_END)
		beyond_deadzone = false
	


func gui_input(p_gui_input: InputEvent):
	assert(!p_gui_input.is_null())

	var prev_v_scroll = _v_scroll.get_value()
	var prev_h_scroll = _h_scroll.get_value()
	var h_scroll_enabled = horizontal_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED
	var v_scroll_enabled = vertical_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED

	var mb := p_gui_input as InputEventMouseButton

	if mb and mb.is_pressed():
		var scroll_value_modified = false

		var v_scroll_hidden := !_v_scroll.is_visible() and vertical_scroll_mode != ScrollContainer.SCROLL_MODE_SHOW_NEVER
		if mb.get_button_index() == MOUSE_BUTTON_WHEEL_UP:
			# By default, the vertical orientation takes precedence. This is an exception.
			if (h_scroll_enabled and mb.is_shift_pressed()) or v_scroll_hidden:
				_h_scroll.scroll(-_h_scroll.get_page() / 8 * mb.get_factor())
				scroll_value_modified = true
			elif v_scroll_enabled:
				_v_scroll.scroll(-_v_scroll.get_page() / 8 * mb.get_factor())
				scroll_value_modified = true
		
		if mb.get_button_index() == MOUSE_BUTTON_WHEEL_DOWN:
			if (h_scroll_enabled and mb.is_shift_pressed()) or v_scroll_hidden:
				_h_scroll.scroll(_h_scroll.get_page() / 8 * mb.get_factor())
				scroll_value_modified = true
			elif v_scroll_enabled:
				_v_scroll.scroll(_v_scroll.get_page() / 8 * mb.get_factor())
				scroll_value_modified = true
		
		var h_scroll_hidden := !_h_scroll.is_visible() and horizontal_scroll_mode != ScrollContainer.SCROLL_MODE_SHOW_NEVER
		if mb.get_button_index() == MOUSE_BUTTON_WHEEL_LEFT:
			# By default, the horizontal orientation takes precedence. This is an exception.
			if (v_scroll_enabled and mb.is_shift_pressed()) or h_scroll_hidden:
				_v_scroll.scroll(-_v_scroll.get_page() / 8 * mb.get_factor())
				scroll_value_modified = true
			elif h_scroll_enabled:
				_h_scroll.scroll(-_h_scroll.get_page() / 8 * mb.get_factor())
				scroll_value_modified = true
		
		if mb.get_button_index() == MOUSE_BUTTON_WHEEL_RIGHT:
			if (v_scroll_enabled and mb.is_shift_pressed()) or h_scroll_hidden:
				_v_scroll.scroll(_v_scroll.get_page() / 8 * mb.get_factor())
				scroll_value_modified = true
			elif h_scroll_enabled:
				_h_scroll.scroll(_h_scroll.get_page() / 8 * mb.get_factor())
				scroll_value_modified = true
		
		if scroll_value_modified and (_v_scroll.get_value() != prev_v_scroll or _h_scroll.get_value() != prev_h_scroll):
			accept_event() # Accept event if scroll changed.
			return

	if not DisplayServer.is_touchscreen_available():
		return

	if mb.get_button_index() != MOUSE_BUTTON_LEFT:
		return

	if mb.is_pressed():
		if drag_touching:
			_cancel_drag()
		drag_speed = Vector2()
		drag_accum = Vector2()
		last_drag_accum = Vector2()
		drag_from = Vector2(prev_h_scroll, prev_v_scroll)
		drag_touching = true
		drag_touching_deaccel = false
		beyond_deadzone = false
		time_since_motion = 0
		set_physics_process_internal(true)
		time_since_motion = 0
	else:
		if drag_touching:
			if drag_speed == Vector2():
				_cancel_drag()
			else:
				drag_touching_deaccel = true
	return

	var mm = p_gui_input as InputEventMouseMotion

	if mm:
		if drag_touching and !drag_touching_deaccel:
			var motion := mm.get_relative()
			drag_accum -= motion

			if beyond_deadzone or (h_scroll_enabled and abs(drag_accum.x) > deadzone) or (v_scroll_enabled and abs(drag_accum.y) > deadzone):
				if !beyond_deadzone:
					propagate_notification(NOTIFICATION_SCROLL_BEGIN)
					scroll_started.emit()

					beyond_deadzone = true
					# Resetting drag_accum here ensures smooth scrolling after reaching deadzone.
					drag_accum = -motion
				
				var diff := drag_from + drag_accum
				if h_scroll_enabled:
					_h_scroll.scroll_to(diff.x)
				else:
					drag_accum.x = 0
				
				if v_scroll_enabled:
					_v_scroll.scroll_to(diff.y)
				else:
					drag_accum.y = 0
				
				time_since_motion = 0

		if _v_scroll.get_value() != prev_v_scroll or _h_scroll.get_value() != prev_h_scroll:
			accept_event() # Accept event if scroll changed.
		return

	var pan_gesture = p_gui_input as InputEventPanGesture
	if pan_gesture:
		if h_scroll_enabled:
			_h_scroll.scroll(_h_scroll.get_page() * pan_gesture.get_delta().x / 8)
		if v_scroll_enabled:
			_v_scroll.scroll(_v_scroll.get_page() * pan_gesture.get_delta().y / 8)
		
		if _v_scroll.get_value() != prev_v_scroll or _h_scroll.get_value() != prev_h_scroll:
			accept_event() # Accept event if scroll changed.
		return


func _update_scrollbar_position():
	if not _updating_scrollbars:
		return

	var hmin := _h_scroll.get_combined_minimum_size() if _h_scroll.is_visible() else Vector2()
	var vmin := _v_scroll.get_combined_minimum_size() if _v_scroll.is_visible() else Vector2()

	var lmar = _panel_style.get_margin(SIDE_RIGHT) if is_layout_rtl() else _panel_style.get_margin(SIDE_LEFT)
	var rmar = _panel_style.get_margin(SIDE_LEFT) if is_layout_rtl() else _panel_style.get_margin(SIDE_RIGHT)

	_h_scroll.set_anchor_and_offset(SIDE_LEFT, ANCHOR_BEGIN, lmar)
	_h_scroll.set_anchor_and_offset(SIDE_RIGHT, ANCHOR_END, -rmar - vmin.x)
	_h_scroll.set_anchor_and_offset(SIDE_TOP, ANCHOR_END, -hmin.y - _panel_style.get_margin(SIDE_BOTTOM))
	_h_scroll.set_anchor_and_offset(SIDE_BOTTOM, ANCHOR_END, -_panel_style.get_margin(SIDE_BOTTOM))

	_v_scroll.set_anchor_and_offset(SIDE_LEFT, ANCHOR_END, -vmin.x - rmar)
	_v_scroll.set_anchor_and_offset(SIDE_RIGHT, ANCHOR_END, -rmar)
	_v_scroll.set_anchor_and_offset(SIDE_TOP, ANCHOR_BEGIN, _panel_style.get_margin(SIDE_TOP))
	_v_scroll.set_anchor_and_offset(SIDE_BOTTOM, ANCHOR_END, -hmin.y - _panel_style.get_margin(SIDE_BOTTOM))

	_updating_scrollbars = false


func _gui_focus_changed(p_control: Control):
	if follow_focus and is_ancestor_of(p_control):
		ensure_control_visible(p_control)


func ensure_control_visible(p_control: Control):
	assert(is_ancestor_of(p_control), "Must be an ancestor of the control.")

	var global_rect := get_global_rect()
	var other_rect := p_control.get_global_rect()
	var side_margin := _v_scroll.get_size().x if _v_scroll.is_visible() else 0.0
	var bottom_margin := _h_scroll.get_size().y if _h_scroll.is_visible() else 0.0

	var diff := Vector2(
		max(
			min(other_rect.position.x - (side_margin if is_layout_rtl() else 0.0), global_rect.position.x),
			other_rect.position.x + other_rect.size.x - global_rect.size.x + (side_margin if !is_layout_rtl() else 0.0)
		),
		max(
			min(other_rect.position.y, global_rect.position.y),
			other_rect.position.y + other_rect.size.y - global_rect.size.y + bottom_margin
		)
	)

	set_h_scroll(get_h_scroll() + (diff.x - global_rect.position.x))
	set_v_scroll(get_v_scroll() + (diff.y - global_rect.position.y))


func _reposition_children():
	update_scrollbars()
	var size := get_size()
	var ofs: Vector2

	size -= _panel_style.get_minimum_size()
	ofs += _panel_style.get_offset()
	var rtl := is_layout_rtl()

	if _h_scroll.is_visible_in_tree() and _h_scroll.get_parent() == self: #scrolls may have been moved out for reasons
		size.y -= _h_scroll.get_minimum_size().y
	

	if _v_scroll.is_visible_in_tree() and _v_scroll.get_parent() == self: #scrolls may have been moved out for reasons
		size.x -= _v_scroll.get_minimum_size().x
	

	for i in get_child_count():
		var c = _as_sortable_control(get_child(i))
		# Skip children which are not controls.
		if !c:
			continue
		# Skip the scrollbars.
		if c == _h_scroll or c == _v_scroll:
			continue
		
		var minsize := c.get_combined_minimum_size()

		var r := Rect2(-Vector2(get_h_scroll(), get_v_scroll()), minsize)
		if c.get_h_size_flags() & SIZE_EXPAND:
			r.size.x = max(size.x, minsize.x)
		
		if c.get_v_size_flags() & SIZE_EXPAND:
			r.size.y = max(size.y, minsize.y)
		
		r.position += ofs
		if rtl and _v_scroll.is_visible_in_tree() and _v_scroll.get_parent() == self:
			r.position.x += _v_scroll.get_minimum_size().x
		
		r.position = r.position.floor()
		fit_child_in_rect(c, r)
	
	queue_redraw()


func update_scrollbars():
	var size := get_size()
	size -= _panel_style.get_minimum_size()

	var hmin := _h_scroll.get_combined_minimum_size()
	var vmin := _v_scroll.get_combined_minimum_size()

	_h_scroll.set_visible(horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_SHOW_ALWAYS or (horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO and _largest_child_min_size.x > size.x))
	_v_scroll.set_visible(vertical_scroll_mode == ScrollContainer.SCROLL_MODE_SHOW_ALWAYS or (vertical_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO and _largest_child_min_size.y > size.y))

	_h_scroll.set_max(_largest_child_min_size.x)
	_h_scroll.set_page(size.x - vmin.x if (_v_scroll.is_visible() and _v_scroll.get_parent() == self) else size.x)

	_v_scroll.set_max(_largest_child_min_size.y)
	_v_scroll.set_page(size.y - hmin.y if (_h_scroll.is_visible() and _h_scroll.get_parent() == self) else size.y)

	# Afunc scrollbar overlapping.
	_updating_scrollbars = true
	call_deferred(&"_update_scrollbar_position")


func _scroll_moved(_delta: float):
	queue_sort()


func set_h_scroll(p_pos: int):
	_h_scroll.set_value(p_pos)
	_cancel_drag()


func get_h_scroll() -> int:
	return _h_scroll.get_value()


func set_v_scroll(p_pos: int):
	_v_scroll.set_value(p_pos)
	_cancel_drag()


func get_v_scroll() -> int:
	return _v_scroll.get_value()


func set_horizontal_custom_step(p_custom_step: float):
	_h_scroll.set_custom_step(p_custom_step)


func get_horizontal_custom_step() -> float:
	return _h_scroll.get_custom_step()


func set_vertical_custom_step(p_custom_step: float):
	_v_scroll.set_custom_step(p_custom_step)


func get_vertical_custom_step() -> float:
	return _v_scroll.get_custom_step()


func set_horizontal_scroll_mode(p_mode: ScrollContainer.ScrollMode):
	if horizontal_scroll_mode == p_mode:
		return

	horizontal_scroll_mode = p_mode
	update_minimum_size()
	queue_sort()


func set_vertical_scroll_mode(p_mode: ScrollContainer.ScrollMode):
	if vertical_scroll_mode == p_mode:
		return
	

	vertical_scroll_mode = p_mode
	update_minimum_size()
	queue_sort()
