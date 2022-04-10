extends Control

var req = HTTPRequest.new()

func _ready():
	visible = false
	add_child(req)

func _process(_delta):
	rect_pivot_offset = Vector2(OS.window_size.x / 2, 0)
	rect_scale = Vector2.ONE * max(floor(OS.window_size.x / Singleton.DEFAULT_SIZE.x), 1)
	if Input.is_action_just_pressed("feedback"):
		visible = !visible
		get_tree().paused = visible || Singleton.pause_menu
		Singleton.feedback = visible


func add_data(tag : String, data) -> String:
	return tag + ":" + str(data) + "\n"


func _on_Submit_pressed():
	visible = false
	if !Singleton.pause_menu:
		get_tree().paused = false
	var msg = "**Description:**\n> "
	var desc = $Panel/TextEdit.text
	if desc == "":
		desc = "`none`"
	msg += desc
	
	msg += "\n**Categories:**"
	var categories = ""
	for check in $Checkboxes.get_children():
		if check.pressed:
			categories += "\n> " + check.get_name()
	if categories == "":
		categories = "\n> `none`"
	msg += categories
	
	msg += "\n**Mood:**\n> "
	var mood_emote = "`none`"
	for mood in $Traffic.get_children():
		if mood.pressed:
			match mood.get_name():
				"Negative":
					mood_emote = ":blue_square: Negative"
				"Neutral":
					mood_emote = ":yellow_square: Neutral"
				"Positive":
					mood_emote = ":green_square: Positive"
	msg += mood_emote
	
	var username
	var contact = $Panel2/LineEdit.text
	if contact == "":
		username = "Feedback [unnamed]"
		contact = "`none`"
	else:
		username = "Feedback [%s]" % contact
	
	msg += "\n**Contact:**\n> " + contact

	var data = assemble_package()
	
	yield(VisualServer, "frame_post_draw")
	var img = get_viewport().get_texture().get_data()
	img.flip_y()
	img = img.save_png_to_buffer()
	var payload = ("--boundary\nContent-Disposition:form-data; name=\"content\"\n\n"
	+ msg
	+ "\n--boundary\nContent-Disposition:form-data; name=\"username\"\n\n"
	+ username
	+ "\n--boundary\nContent-Disposition: form-data; name=\"files[0]\"; filename=\"data.txt\"\nContent-Type: text/plain\n\n"
	+ data
	+ "\n--boundary\nContent-Disposition: form-data; name=\"files[1]\"; filename=\"screenshot.png\"\nContent-Type: image/png\n\n").to_ascii()
	payload.append_array(img)
	payload.append_array("\n--boundary--".to_ascii())
	#req.connect("request_completed", self, "_on_request_completed")
	req.request_raw(
		"https://discord.com/api/webhooks/937358472788475934/YQppuK8SSgYv_v0pRosF3AWBufPiVZui2opq5msMKJ1h-fNhVKsvm3cBRhvHOZ9XqSad",
		["Content-Type:multipart/form-data; boundary=boundary"],
		true,
		HTTPClient.METHOD_POST,
		payload
	)
	Singleton.get_node("SFX/Confirm").play()
	reset_data()


func assemble_package() -> String:
	var package = ""
	package += add_data("platform", OS.get_name())
	package += add_data("version", Singleton.VERSION)
	package += add_data("timestamp", OS.get_ticks_msec())
	package += add_data("window_size", OS.get_window_size())
	package += add_data("fullscreen", OS.window_fullscreen)
	package += add_data("room", get_tree().get_current_scene().get_filename())
	var player = $"/root/Main/Player"
	if player == null:
		package += add_data("no_player", "")
	else:
		package += add_data("pos", player.position)
		package += add_data("rot", player.rotation)
		package += add_data("zoom", player.get_node("Camera2D").zoom)
	return package
	

func reset_data():
	$Panel/TextEdit.text = ""
	$Panel2/LineEdit.text = ""
	for check in $Checkboxes.get_children():
		check.pressed = false
	for mood in $Traffic.get_children():
		mood.pressed = false


func _on_Cancel_pressed():
	visible = false
	get_tree().paused = Singleton.pause_menu
	Singleton.feedback = false
