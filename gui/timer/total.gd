extends Label

@onready var ms = $"../TotalMS"
@onready var rect = $"../MainRect"

func _process(_delta):
	var ms_width = ms.get_theme_font("font").get_string_size(".000").x
	var sec_mask
	if text.length() < 5:
		sec_mask = "0:00"
	elif text.length() < 6:
		sec_mask = "00:00"
	else:
		sec_mask = ":00:00"
		for _i in range(text.length() - 6):
			sec_mask = "0" + sec_mask
	var sec_width = ms.get_theme_font("font").get_string_size(sec_mask).x * 2
	var full_width = (
		sec_width
		+ 1
		+ ms_width
	)
	var rect_offset = full_width / 2 + 2
	rect.offset_left = -rect_offset
	rect.offset_right = rect_offset
	
	ms.offset_left = rect_offset - ms_width - 2
	offset_left = rect_offset - ms_width - sec_width - 2
	offset_right = rect_offset - ms_width - sec_width / 2 - 2
