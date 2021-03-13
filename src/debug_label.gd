extends Label

func _process(delta):
	text = "Classic, " + String($"/root/Main".classic)
	#text = String(get_parent().get_parent().position)
