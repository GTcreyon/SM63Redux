extends Control

var req = HTTPRequest.new()

func _ready():
	add_child(req)
	

func _process(delta):
	if Input.is_action_just_pressed("feedback"):
		visible = !visible
		print("a")
		get_tree().paused = visible


func _on_Submit_pressed():
	visible = false
	var msg = "```Description:\n\t" + $Panel/TextEdit.text
	msg += "\nCategories:"
	for check in $Checkboxes.get_children():
		if check.pressed:
			msg += "\n\t" + check.get_name()
	
	msg += "\nMood:\n\t"
	for mood in $Traffic.get_children():
		if mood.pressed:
			msg += mood.get_name()
	
	var username
	var contact = $Panel2/LineEdit.text
	if contact != "":
		username = "Feedback [%s]" % contact
	else:
		username = "Feedback [unnamed]"
	
	msg += "\nContact:\n\t" + contact + "```"
	print(msg)
#	yield(VisualServer, "frame_post_draw")
#	var img = get_viewport().get_texture().get_data()
#	img.flip_y()
#	img.save_png("user://screenie.png")
	req.request("https://discord.com/api/webhooks/937358472788475934/YQppuK8SSgYv_v0pRosF3AWBufPiVZui2opq5msMKJ1h-fNhVKsvm3cBRhvHOZ9XqSad", ["Content-Type:application/json"], true, HTTPClient.METHOD_POST, to_json({"content": msg, "username": username}))
