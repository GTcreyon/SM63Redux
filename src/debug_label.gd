extends Label

func _process(delta):
	text = "Classic: " + ("On" if $"/root/Main".classic else "Off")
	#text = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!?'\""
	#text = String(get_parent().get_parent().position)
