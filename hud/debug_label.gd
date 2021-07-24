extends Label

func _process(_delta):
	text = "Classic: " + ("On" if $"/root/Singleton".classic else "Off")
	#text = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ!?'\""
	#text = String(get_parent().get_parent().position)
