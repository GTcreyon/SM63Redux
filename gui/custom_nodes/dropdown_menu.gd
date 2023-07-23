@tool
class_name DropdownMenu
extends Container

signal button_pressed

@export var options: PackedStringArray = []: set = update_options
@export var spacing: float = 4: set = update_spacing
@export var margin: float = 6: set = update_margin
@export var color: Color = Color(1, 1, 1)
@export var seperator_color: Color = Color(0.8, 0.8, 0.8)

var should_update = false


func clear_all_children():
	for child in get_children():
		child.queue_free()

func press(index, text):
	emit_signal("button_pressed", index, text)
	queue_free()

func update_options(new):
	new.append("---")
	new.append("Close")
	options = new
	refresh()

func update_margin(new):
	margin = new
	refresh()

func update_spacing(new):
	spacing = new
	refresh()

func refresh():
	clear_all_children()
	
	var transparent_background = StyleBoxFlat.new()
	transparent_background.bg_color = Color(0, 0, 0, 0)
	
	var panel = Panel.new()
	add_child(panel)
	
	for option_idx in len(options):
		var option = options[option_idx]
		if option == "---" || option.begins_with("---#"):
			if option == "---":
				var line = ColorRect.new()
				line.size.y = 2
				line.color = seperator_color
				add_child(line)
			else:
				var text = Label.new()
				text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				text.text = option.substr(4)
				
				# Inner lines
				var left = ColorRect.new()
				left.color = seperator_color
				left.size.y = 2
				text.add_child(left)
				var right = ColorRect.new()
				right.color = seperator_color
				right.size.y = 2
				text.add_child(right)
				
				add_child(text)
		else:
			var label = Button.new()
			label.alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.text = option
			# Handle disabled options
			if option.begins_with("---!"):
				label.disabled = true
			
			# Make sure the background is transparent
			label.add_theme_stylebox_override("normal", transparent_background)
			label.add_theme_stylebox_override("focus", transparent_background)
			label.add_theme_stylebox_override("hover", transparent_background)
			label.add_theme_stylebox_override("disabled", transparent_background)
			label.add_theme_stylebox_override("pressed", transparent_background)
			label.connect("pressed", Callable(self, "press").bind(option_idx, option))
			add_child(label)
	should_update = true
	
func _notification(what):
	if what != NOTIFICATION_SORT_CHILDREN:
		return
	if !should_update:
		return
	should_update = false
	
	# Find the biggest x size
	var biggest_width = 0
	for child in get_children():
		biggest_width = max(biggest_width, child.size.x)
	
	# Move every node
	var pos_y = margin
	for child in get_children():
		# We skip the panel
		if child is Panel:
			continue
		
		var og_size = child.size.x
		child.position = Vector2(margin, pos_y)
		child.size.x = biggest_width
		if child is Label:
			var left = child.get_child(0)
			var right = child.get_child(1)
			var full = child.size.x - 2 * margin
			var base = og_size + margin
			left.size.x = (full - base) / 2
			left.position = Vector2(
				margin,
				child.size.y / 2 - 1
			)
			right.size.x = (full - base) / 2
			right.position = Vector2(
				child.size.x - right.size.x - margin,
				child.size.y / 2 - 1
			)
		if child is ColorRect:
			child.size.x -= 2 * margin
			child.position.x += margin
		pos_y += child.size.y + spacing
	size = Vector2(biggest_width + 2 * margin, pos_y + margin - spacing)
	
	# Make sure our background panel is the same size as the actual container
	get_child(0).size = size


func _unhandled_input(event):
	if event.is_action_pressed("ld_place"):
		queue_free()
