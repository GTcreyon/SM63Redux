extends Control

var req = HTTPRequest.new()

func _ready():
	add_child(req)
	

func _process(delta):
	if Input.is_action_just_pressed("feedback"):
		visible = !visible
		get_tree().paused = visible || Singleton.pause_menu
		Singleton.feedback = visible


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
	#print(msg)
	yield(VisualServer, "frame_post_draw")
	var img = get_viewport().get_texture().get_data()
	img.flip_y()
	img = img.save_png_to_buffer()
	var payload = ("--boundary\nContent-Disposition:form-data; name=\"content\"\n\n"
	+ msg
	+ "\n--boundary\nContent-Disposition:form-data; name=\"username\"\n\n"
	+ username
	+ "\n--boundary\nContent-Disposition: form-data; name=\"files[0]\"; filename=\"screenshot.png\"\nContent-Type: image/png\n\n").to_ascii()
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
	#req.request("https://discord.com/api/webhooks/937358472788475934/YQppuK8SSgYv_v0pRosF3AWBufPiVZui2opq5msMKJ1h-fNhVKsvm3cBRhvHOZ9XqSad", ["Content-Type:application/json"], true, HTTPClient.METHOD_POST, to_json({"content": msg, "username": username}))
#func _on_request_completed(result, response_code, headers, body):
#	var json = JSON.parse(body.get_string_from_utf8())
#	print(json.result)
