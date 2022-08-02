extends NinePatchRect

const BYLIGHT = preload("res://fonts/bylight/bylight.tres")

var being_dragged = false

func get_text_width(text: String) -> Vector2:
	var width = 0
	for c in text:
		width += BYLIGHT.get_char_size(c as int).x
	return Vector2(width, BYLIGHT.get_height())

func setup(text: String):
	# Create the labels within the block
	var segments = text.split(" ", false)
	var x_position = 0
	for segment in segments:
		var text_size = get_text_width(segment)
		match segment:
			"$expression":
				print("Woo!")
			"$label":
				print("Variable labels, cool!")
			"$variable":
				print("Wow this is a variable.")
			_:
				var label = Label.new()
				label.add_font_override("font", BYLIGHT)
				label.text = segment
				label.rect_size = text_size
				label.rect_position.x = x_position
				add_child(label)
		x_position += text_size.x
	
	# Resize the main block
	rect_size = Vector2(x_position + 20, BYLIGHT.get_height())
	match name:
		"Holster":
			rect_size.y += 100
		_:
			pass

# Handle being dragged.
func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		being_dragged = true
	if event is InputEventMouseButton and not event.pressed:
		being_dragged = false
	if being_dragged and event is InputEventMouseMotion:
		rect_position += event.relative
