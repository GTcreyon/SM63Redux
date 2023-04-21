extends CanvasLayer
# Menu to send feedback to the development team.

var req = HTTPRequest.new()

onready var feedback_container = $FeedbackContainer
onready var description = $FeedbackContainer/List/Description
onready var contact = $FeedbackContainer/List/Contact
onready var traffic = $FeedbackContainer/List/Traffic
onready var checkboxes = $FeedbackContainer/List/Checkboxes


func _ready():
	visible = false
	add_child(req)


func _process(_delta):
	var scalar = Singleton.get_screen_scale()
	feedback_container.rect_size = OS.window_size / scalar
	feedback_container.rect_scale = Vector2.ONE * scalar
	if Input.is_action_just_pressed("feedback"):
		visible = !visible
		get_tree().paused = visible or Singleton.pause_menu
		Singleton.set_pause("feedback", visible)


func add_data(tag: String, data) -> String:
	return tag + ":" + str(data) + "\n"


func _on_Submit_pressed():
	if description.text == "":
		Singleton.get_node("SFX/Back").play()
	else:
		visible = false
		if !Singleton.pause_menu:
			get_tree().paused = false
		var msg = _assemble_message()

		var data = _assemble_package()
		var img = yield(_take_screenshot(), "completed")
		var contact_info = contact.text
		var username
		if contact_info == "":
			username = "Feedback [unnamed]"
		else:
			username = "Feedback [%s]" % contact_info
			
		
		var payload = ("--boundary\nContent-Disposition:form-data; name=\"content\"\n\n"
		+ msg
		+ "\n--boundary\nContent-Disposition:form-data; name=\"username\"\n\n"
		+ username
		+ "\n--boundary\nContent-Disposition: form-data; name=\"files[0]\"; filename=\"data.txt\"\nContent-Type: text/plain\n\n"
		+ data
		+ "\n--boundary\nContent-Disposition: form-data; name=\"files[1]\"; filename=\"screenshot.png\"\nContent-Type: image/png\n\n").to_utf8()
		payload.append_array(img)
		payload.append_array("\n--boundary--".to_utf8())
		#req.connect("request_completed", self, "_on_request_completed")
		req.request_raw(
			"http://feedback.sm63redux.com",
			["Content-Type:multipart/form-data; boundary=boundary"],
			true,
			HTTPClient.METHOD_POST,
			payload
		)
		Singleton.get_node("SFX/Confirm").play()
		reset_data()


# Take a screenshot of the gameplay screen
func _take_screenshot() -> PoolByteArray:
	yield(VisualServer, "frame_post_draw")
	var img = get_viewport().get_texture().get_data()
	img.flip_y()
	var buffer = img.save_png_to_buffer()
	return buffer


func _assemble_message() -> String:
	var msg: String = "**Description:**\n> "
	var desc_text = description.text
	msg += desc_text
	
	msg += "\n**Categories:**"
	var categories = ""
	for check in _get_checkboxes():
		if check.pressed:
			categories += "\n> " + check.get_parent().name
	if categories == "":
		categories = "\n> `none`"
	msg += categories
	
	msg += "\n**Mood:**\n> "
	var mood_emote = "`none`"
	for mood in traffic.get_children():
		if mood.pressed:
			match mood.get_name():
				"Negative":
					mood_emote = ":blue_square: Negative"
				"Neutral":
					mood_emote = ":yellow_square: Neutral"
				"Positive":
					mood_emote = ":green_square: Positive"
	msg += mood_emote
	
	var contact_info = contact.text
	if contact_info == "":
		contact_info = "`none`"
	
	msg += "\n**Contact:**\n> " + contact_info
	var hash_text = desc_text + str(Time.get_ticks_msec())
	msg += "\n**Reference:**\n> &" + hash_text.sha1_text().substr(0, 5)
	return msg


func _assemble_package() -> String:
	var package = ""
	package += add_data("platform", OS.get_name())
	package += add_data("version", Singleton.VERSION)
	package += add_data("timestamp", Time.get_ticks_msec())
	package += add_data("window_size", OS.window_size)
	package += add_data("fullscreen", OS.window_fullscreen)
	package += add_data("room", get_tree().get_current_scene().get_filename())
	var player = $"/root/Main/Player"
	if player == null:
		package += add_data("no_player", "")
	else:
		package += add_data("pos", player.position)
		package += add_data("rot", player.rotation)
		package += add_data("zoom", player.get_node("Camera").zoom)
	return package
	

func reset_data():
	description.text = ""
	contact.text = ""
	for check in _get_checkboxes():
		check.pressed = false
	for mood in traffic.get_children():
		mood.pressed = false


func _get_checkboxes() -> Array:
	var output = []
	for box in checkboxes.get_children():
		output.append(box.get_node("Tickbox"))
	return output


func _on_Cancel_pressed():
	visible = false
	get_tree().paused = Singleton.pause_menu
	Singleton.set_pause("feedback", false)
