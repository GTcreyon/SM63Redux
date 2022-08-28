extends Control

const LIST_ITEM = preload("./ldui/list_item.tscn")

onready var level_editor := $"/root/Main"
onready var ld_camera := $"/root/Main/Camera"
onready var background := $"/root/Main/BGT1/BGGrid"
onready var hover_ui := get_parent().get_node("HoverUI")
#onready var selection_ui := hover_ui.get_node("SelectionControl")
onready var editable_rect := hover_ui.get_node("Dragger")
onready var rect_controls := hover_ui.get_node("Dragger").get_node("SelectionControl")
onready var item_grid = $ItemPane/ItemBlock/ItemDisplay/Back/Base/ItemGrid

var is_creating_polygon = false
var editable_poly = null
var selected_polys = []

# A bad, slow, O(n^2), but easy to implement algorithm
# I should look into better algorithms
# Here: web.archive.org/web/20141211224415/http://www.lems.brown.edu/~wq/projects/cs252.html
# That is O(n)
# But eh, I'll come back to it
# Sometime TM
func polygon_self_intersecting(polygon):
	var p_size = polygon.size()
	var start = polygon[0]
	var end = polygon[p_size - 1]
	for ind in range(p_size):
		var a = polygon[ind]
		var b = polygon[(ind + 1) % p_size]
		
		var result = Geometry.segment_intersects_segment_2d(
			start, end,
			a, b
		)
		
		if result and result != start and result != end:
			draw_circle(result, 5, Color(1, 0, 0))
			return false
	return true


func fake_polygon_create():
	is_creating_polygon = true
	editable_poly = PolygonContainer.new()
	editable_poly.head_color = Color(0, 1, 0)
	editable_poly.foot_color = Color(1, 0, 0)
	editable_poly.reset()
	editable_poly.append(Vector2(0, 0))
	hover_ui.add_child(editable_poly)


func finish_creating_polygon():
	#make sure the polygon is correctly rotated, which is counter-clockwise
	var make_polygon = Array(editable_poly.polygon)
	if Geometry.is_polygon_clockwise(make_polygon):
		make_polygon.invert()

	if make_polygon.back() != make_polygon.front():
		make_polygon.append(
			make_polygon.back()
		)

	#set the terrain polygon to the actual polygon
	level_editor.place_terrain(
		make_polygon,
		0,
		0
	)
	
	#reset the modifier state
	is_creating_polygon = false
	hover_ui.remove_child(editable_poly)
	set_editable_rect(false)


func get_polygon_rect(polygon):
	# Get the extends
	var vec_min = Vector2.INF
	var vec_max = -Vector2.INF
	for vert in polygon:
		vec_min.x = min(vec_min.x, vert.x)
		vec_min.y = min(vec_min.y, vert.y)
		vec_max.x = max(vec_max.x, vert.x)
		vec_max.y = max(vec_max.y, vert.y)
	return Rect2(vec_min, vec_max - vec_min)


func set_editable_rect(enabled, rect = Rect2(), menu_visible = true):
	rect_controls.visible = menu_visible
	if not enabled:
		editable_rect.visible = false
		return
	if not editable_rect.visible:
		editable_rect.visible = true
	if editable_rect.rect_size != rect.size:
		editable_rect.set_size(rect.size)
	if editable_rect.rect_position != rect.position:
		editable_rect.set_position(rect.position)


func _process(_dt):
	background.material.set_shader_param("camera_position", ld_camera.global_position)
	
	hover_ui.set_position(-ld_camera.global_position)
	if editable_rect.visible and not is_creating_polygon:
		set_editable_rect(true, level_editor.selection_rect)
	
	# Poly edit
	if is_creating_polygon and editable_poly.polygon.size() >= 1:
		var real_position = level_editor.snap_vector(level_editor.last_local_mouse_position + ld_camera.global_position)
		editable_poly.set_vert(editable_poly.polygon.size() - 1, real_position)
		set_editable_rect(true, get_polygon_rect(editable_poly.polygon), false)


func _input(event):
	if is_creating_polygon:
		# On click, insert a new vert in the polygon
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == 1:
				var real_position = level_editor.snap_vector(event.position + ld_camera.global_position)
				var p_size = editable_poly.polygon.size()
				# If we have 2 vertices, cancel the placement, more than 3, we place it down
				if p_size >= 2 and real_position == editable_poly.polygon[0]:
					if p_size >= 3:
						finish_creating_polygon()
				else:
					editable_poly.append(real_position)
			elif event.button_index == 2:
				finish_creating_polygon()


func _on_terrain_control_place_pressed():
	fake_polygon_create()


func _selection_changed(selection):
	for poly in selected_polys:
		hover_ui.remove_child(poly)
	selected_polys = []
	
	for item in selection.active:
		if item.get_parent().name == "Terrain":
			var editable_poly = PolygonContainer.new()
			for vec in item.polygon:
				editable_poly.append(vec)
			hover_ui.add_child(editable_poly)
			selected_polys.append(editable_poly)


func _selection_size_changed(rect):
	if rect.size.length() > 8:
		set_editable_rect(true, rect)
	else:
		set_editable_rect(false)


func fill_grid():
	for item_id in range(level_editor.item_textures.size()):
		if level_editor.item_textures[item_id] != null:
			var button = list_item.instance()
			var tex : AtlasTexture = AtlasTexture.new()
			
			var path = level_editor.item_textures[item_id]["List"]
			if path == null:
				path = level_editor.item_textures[item_id]["Placed"]
			
			var stream: StreamTexture = load(path)
			tex.atlas = stream
			var min_size = Vector2(
				min(
					stream.get_width(),
					32
				),
				min(
					stream.get_height(),
					32
				)
			)
			tex.region = Rect2(
				stream.get_size() / 2 - min_size / 2,
				min_size
			)
			button.rect_min_size = Vector2(32, 32)
			button.get_node("Icon").texture = tex
			button.item_id = item_id
			item_grid.add_child(button)
