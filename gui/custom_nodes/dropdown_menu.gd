tool
extends Container

class_name DropdownMenu

signal button_pressed

export(PoolStringArray) var options = [] setget update_options
export(float) var spacing = 4 setget update_spacing
export(float) var margin = 6 setget update_margin
export(Color) var color = Color(1, 1, 1)
export(Color) var seperator_color = Color(0.8, 0.8, 0.8)

var should_update = false


func clear_all_children():
	for child in get_children():
		child.queue_free()

func button_pressed(index, text):
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
				line.rect_size.y = 2
				line.color = seperator_color
				add_child(line)
			else:
				var text = Label.new()
				text.align = Label.ALIGN_CENTER
				text.text = option.substr(4)
				
				# Inner lines
				var left = ColorRect.new()
				left.color = seperator_color
				left.rect_size.y = 2
				text.add_child(left)
				var right = ColorRect.new()
				right.color = seperator_color
				right.rect_size.y = 2
				text.add_child(right)
				
				add_child(text)
		else:
			var label = Button.new()
			label.align = Button.ALIGN_CENTER
			label.text = option
			# Handle disabled options
			if option.begins_with("---!"):
				label.disabled = true
			
			# Make sure the background is transparent
			label.add_stylebox_override("normal", transparent_background)
			label.add_stylebox_override("focus", transparent_background)
			label.add_stylebox_override("hover", transparent_background)
			label.add_stylebox_override("disabled", transparent_background)
			label.add_stylebox_override("pressed", transparent_background)
			label.connect("pressed", self, "button_pressed", [option_idx, option])
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
		biggest_width = max(biggest_width, child.rect_size.x)
	
	# Move every node
	var pos_y = margin
	for child in get_children():
		# We skip the panel
		if child is Panel:
			continue
		
		var og_size = child.rect_size.x
		child.rect_position = Vector2(margin, pos_y)
		child.rect_size.x = biggest_width
		if child is Label:
			var left = child.get_child(0)
			var right = child.get_child(1)
			var full = child.rect_size.x - 2 * margin
			var base = og_size + margin
			left.rect_size.x = (full - base) / 2
			left.rect_position = Vector2(
				margin,
				child.rect_size.y / 2 - 1
			)
			right.rect_size.x = (full - base) / 2
			right.rect_position = Vector2(
				child.rect_size.x - right.rect_size.x - margin,
				child.rect_size.y / 2 - 1
			)
		if child is ColorRect:
			child.rect_size.x -= 2 * margin
			child.rect_position.x += margin
		pos_y += child.rect_size.y + spacing
	rect_size = Vector2(biggest_width + 2 * margin, pos_y + margin - spacing)
	
	# Make sure our background panel is the same size as the actual container
	get_child(0).rect_size = rect_size


func _unhandled_input(event):
	if event.is_action_pressed("ld_place"):
		queue_free()
